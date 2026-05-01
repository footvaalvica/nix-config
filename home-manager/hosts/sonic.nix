{
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

  home = {
    homeDirectory = lib.mkForce "/Users/mateusp";
  };

  services.home-manager.autoUpgrade.enable = lib.mkForce false;

  programs = {
    fish.interactiveShellInit = "ulimit -n 4096";
    zed-editor = {
      enable = true;
      mutableUserSettings = true;
      userSettings = {
        icon_theme = "Zed (Default)";
        edit_predictions = {
          provider = "copilot";
        };
        agent = {
          dock = "right";
          favorite_models = [ ];
          model_parameters = [ ];
          default_model = {
            provider = "copilot_chat";
            model = "gpt-5.4";
          };
          inline_alternatives = [
            {
              provider = "copilot_chat";
              model = "gpt-5-mini";
            }
            {
              provider = "copilot_chat";
              model = "claude-haiku-4.5";
            }
          ];
          commit_message_model = {
            provider = "copilot_chat";
            model = "gpt-5-mini";
          };
          thread_summary_model = {
            provider = "copilot_chat";
            model = "gpt-5-mini";
          };
        };
        project_panel.dock = "left";
        git_panel.dock = "left";
        agent_servers = {
          github-copilot-cli.type = "registry";
          codex-acp.type = "registry";
          opencode.type = "registry";
        };
        base_keymap = "VSCode";
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
