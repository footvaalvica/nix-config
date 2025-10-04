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
    ../../modules/home-manager/default.nix
  ];

  home.homeDirectory = lib.mkForce "/Users/mateusp";

  services.home-manager.autoUpgrade.enable = lib.mkForce false;

  programs.direnv = {
    enable = lib.mkForce false;
    nix-direnv.enable = lib.mkForce false;
  };
}
