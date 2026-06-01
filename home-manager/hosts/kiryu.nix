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
    ../profiles/non-nixos-system.nix
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

  programs.nh.flake = lib.mkForce "/home/deck/nix-config";

  targets.genericLinux.enable = true;

  programs.topgrade = {
    enable = true;
    settings = {
      misc.disable = [
        "system"
        "nix"
      ];
      git.repos = [ "${config.home.homeDirectory}/nix-config" ];
      linux.home_manager_arguments = [
        "--flake"
        "${config.home.homeDirectory}/nix-config/#${config.home.username}@kiryu"
      ];
    };
  };
}
