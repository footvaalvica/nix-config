{
  config,
  lib,
  pkgs,
  inputs,
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

  # The NixOS system switch owns Home Manager activation on this host.
  services.home-manager.autoUpgrade.enable = lib.mkForce false;
}
