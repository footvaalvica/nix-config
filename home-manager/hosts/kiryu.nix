{
  config,
  pkgs,
  lib,
  self,
  ...
}: {
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
  home.sessionPath = ["/opt/tailscale"];

  targets.genericLinux.enable = true;

  programs.ssh = {
    enableDefaultConfig = false;
    enable = true;
    extraConfig = ''
      Host omi raidou joker
        User mateusp
    '';
  };

  programs.topgrade = {
    enable = true;
    settings = {
      misc.disable = [
        "system"
        "nix"
      ];
      git.repos = ["${config.home.homeDirectory}/nix-config"];
      linux.home_manager_arguments = [
        "--flake"
        "${config.home.homeDirectory}/nix-config/#${config.home.username}@kiryu"
      ];
    };
  };
}
