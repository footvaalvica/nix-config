{
  config,
  pkgs,
  lib,
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

  home.username = lib.mkForce "deck";
  home.homeDirectory = lib.mkForce "/home/deck";

  targets.genericLinux.enable = true;

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
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
      git.repos = [ "/home/deck/nix-config" ];
      linux.home_manager_arguments = [
        "--flake"
        "/home/deck/nix-config/#deck@kiryu"
      ];
    };
  };

  # programs.fish.interactiveShellInit = "source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish";

}
