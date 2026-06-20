{
  config,
  lib,
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
      "omi tojo raidou joker" = {
        user = "mateusp";
      };
    };
  };

  # # THIS MIGHT BREAK IF VALVE UPDATES KDE TO WAYLAND ONLY???? HOPE THEY DONT
  # home.file.".Xmodmap".text = ''
  #   keycode 108 = Super_R
  #   keycode 134 = ISO_Level3_Shift

  #   clear mod4
  #   clear mod5

  #   add mod4 = Super_R
  #   add mod5 = ISO_Level3_Shift
  # '';

  # home.file.".xprofile".text = ''
  #   if ${pkgs.xinput}/bin/xinput list --name-only | ${pkgs.gnugrep}/bin/grep -qi 'keychron'; then
  #     ${pkgs.setxkbmap}/bin/setxkbmap
  #   else
  #     ${pkgs.xmodmap}/bin/xmodmap ~/.Xmodmap
  #   fi
  # '';

  # xdg.configFile."autostart-scripts/keychron-keymap.sh" = {
  #   executable = true;
  #   text = ''
  #     #!${pkgs.bash}/bin/bash
  #     sleep 2

  #     log="$HOME/.local/state/keychron-keymap.log"
  #     ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$log")"

  #     if ${pkgs.xinput}/bin/xinput list --name-only | ${pkgs.gnugrep}/bin/grep -qi 'keychron'; then
  #       ${pkgs.setxkbmap}/bin/setxkbmap
  #       printf '%s Keychron detected: ran setxkbmap\n' "$(${pkgs.coreutils}/bin/date -Is)" >> "$log"
  #     else
  #       ${pkgs.xmodmap}/bin/xmodmap ~/.Xmodmap
  #       printf '%s Keychron not detected: ran xmodmap\n' "$(${pkgs.coreutils}/bin/date -Is)" >> "$log"
  #     fi
  #   '';
  # };

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
