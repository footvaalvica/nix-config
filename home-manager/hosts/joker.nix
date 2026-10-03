{
  config,
  lib,
  pkgs,
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
  home.sessionPath = [ "/opt/tailscale" ];

  home.packages = [ pkgs.directx-shader-compiler ];

  home.sessionVariables = {
    # moon deck buddy bullshit
    NO_GUI = "1";
  };

  systemd.user.settings = {
    Manager = {
      DefaultLimitMEMLOCK = "infinity";
    };
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
        "${config.home.homeDirectory}/nix-config/#${config.home.username}@joker"
      ];
    };
  };
}
