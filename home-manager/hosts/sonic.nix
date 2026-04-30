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

  home = {
    homeDirectory = lib.mkForce "/Users/mateusp";
  };

  services.home-manager.autoUpgrade.enable = lib.mkForce false;

  programs = {
    fish.interactiveShellInit = "ulimit -n 4096";
    zed-editor = {
      enable = true;
      userSettings = {
        load_direnv = "shell_hook";
        colorize_brackets = true;
        agent_servers = {
          opencode = {
            type = "registry";
          };
          codex-acp = {
            type = "registry";
          };
          github-copilot-cli = {
            type = "registry";
          };
        };
        ui_font_size = 16;
        buffer_font_size = 15;
        theme = {
          mode = "system";
          light = "Ayu Light";
          dark = "Ayu Dark";
        };
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "borg@*" = {
        user = "borg";
        identityFile = "~/.ssh/borg_key";
      };
    };
  };
}
