{
  config,
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

  home.sessionVariables = {
    # moon deck buddy bullshit
    NO_GUI = "1";
  };

  programs.topgrade = {
    enable = true;
    settings = {
      linux.bootc = true;
      git.repos = ["${config.home.homeDirectory}/nix-config"];
      linux.home_manager_arguments = [
        "--flake"
        "${config.home.homeDirectory}/nix-config/#${config.home.username}@raidou"
      ];
    };
  };

  targets.genericLinux.enable = true;
}
