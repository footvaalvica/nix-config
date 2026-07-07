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
    username = lib.mkForce "mpinho";
    homeDirectory = lib.mkForce "/Users/mpinho";
  };

  services.home-manager.autoUpgrade.enable = lib.mkForce false;

  programs = {
    # # mcp = {
    # #   servers = {
    # #     codebase-memory-mcp = {
    # #       type = "stdio";
    # #       command = "/Users/mpinho/.local/bin/codebase-memory-mcp";
    # #     };
    # #   };
    # # };
    fish.interactiveShellInit = "ulimit -n 4096";
    nh.flake = lib.mkForce "/Users/mpinho/nix-config"; # sets NH_OS_FLAKE variable for you
    zed-editor = {
      enable = true;
      package = null;
      mutableUserSettings = true;
      userSettings = {
        buffer_font_family = "Liga SFMono Nerd Font";
        icon_theme = "Zed (Default)";
        languages = {
          LaTeX = {
            show_edit_predictions = false;
            soft_wrap = "editor_width";
          };
          Markdown = {
            show_edit_predictions = false;
            soft_wrap = "editor_width";
          };
        };
        project_panel.dock = "left";
        git_panel.dock = "right";
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
}
