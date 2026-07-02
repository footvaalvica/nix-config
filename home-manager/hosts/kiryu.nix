{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../modules/default.nix
  ];

  home.username = lib.mkForce "deck";
  home.homeDirectory = lib.mkForce "/home/deck";
  home.sessionPath = [ "/opt/tailscale" ];

  programs.ssh = {
    enableDefaultConfig = false;
    enable = true;
    settings = {
      "omi tojo joker" = {
        user = "mateusp";
      };
    };
  };

  home.packages = [ pkgs.xremap ];

  xdg.configFile."xremap/keychron-keymap.yml".text = ''
    modmap:
      - name: Right Alt/Super fix for non-Keychron keyboards
        remap:
          KEY_RIGHTALT: KEY_RIGHTMETA
          KEY_RIGHTMETA: KEY_RIGHTALT
  '';

  systemd.user.services.keychron-keymap = {
    Unit = {
      Description = "Remap right Alt/Super when no Keychron keyboard is connected";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecCondition = ''${pkgs.bash}/bin/bash -c "! ${pkgs.gnugrep}/bin/grep -qi keychron /proc/bus/input/devices"'';
      ExecStart = "${pkgs.xremap}/bin/xremap --watch=device %h/.config/xremap/keychron-keymap.yml";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."autostart-scripts/keychron-keymap-log.sh" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      log="$HOME/.local/state/keychron-keymap.log"
      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$log")"

      if ${pkgs.gnugrep}/bin/grep -qi 'keychron' /proc/bus/input/devices; then
        printf '%s Keychron detected: xremap service skipped\n' "$(${pkgs.coreutils}/bin/date -Is)" >> "$log"
      else
        printf '%s Keychron not detected: xremap service should be active\n' "$(${pkgs.coreutils}/bin/date -Is)" >> "$log"
      fi
    '';
  };

  programs.nh.flake = lib.mkForce "${config.home.homeDirectory}/nix-config";
  programs.nh.homeFlake = lib.mkForce "${config.home.homeDirectory}/nix-config/";

  targets.genericLinux.enable = true;

  programs.topgrade = {
    enable = true;
    settings = {
      misc.disable = [
        "system"
        "nix"
      ];
      linux.home_manager_arguments = [
        "--flake"
        "${config.home.homeDirectory}/nix-config/#${config.home.username}@kiryu"
      ];
    };
  };
}
