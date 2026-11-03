{pkgs, ...}: {
  imports = [
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mateusp";
  home.homeDirectory = "/home/mateusp";

  home.stateVersion = "24.05"; # Please read the comment before changing.
  home.enableNixpkgsReleaseCheck = false;

  home.packages = with pkgs; [
    nano
    git-crypt
    git-lfs
    yq
    ugrep
    wget
    fastfetch
  ];

  # ...other config, other config...

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    devenv.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/mateusp/nix-config";
      homeFlake = "/home/mateusp/nix-config";
      darwinFlake = "/Users/mateusp/nix-config";
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--disable-ctrl-r"];
    };

    eza = {
      enable = true;
      enableFishIntegration = true;
    };

    fd.enable = true;

    ripgrep.enable = true;
    # # tealdeer.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableFishIntegration = true;

      settings = {
        aws.symbol = "  ";
        buf.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        crystal.symbol = " ";
        dart.symbol = " ";
        directory.read_only = " 󰌾";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fennel.symbol = " ";
        fossil_branch.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = " ";
        hg_branch.symbol = " ";
        hostname.ssh_symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        kotlin.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = "󰍛 ";
        meson.symbol = "󰔷 ";
        nim.symbol = "󰆥 ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";
        ocaml.symbol = " ";
        package.symbol = "󰏗 ";
        perl.symbol = " ";
        php.symbol = " ";
        pijul_channel.symbol = " ";
        python.symbol = " ";
        rlang.symbol = "󰟔 ";
        ruby.symbol = " ";
        rust.symbol = "󱘗 ";
        scala.symbol = " ";
        swift.symbol = " ";
        zig.symbol = " ";
      };
    };

    micro.enable = true;

    gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
      };
    };

    git = {
      enable = true;
      lfs.enable = true;
      signing.format = null;
    };

    fish = {
      enable = true; # see note on other shells below
      shellAliases = {
        nano = "micro";
      };
    };

    zellij = {
      enable = true;
      # enableFishIntegration = true;
    };

    mcp = {
      enable = true;
      # place future mcp configuration here
    };
  };

  home.sessionVariables = {
    EDITOR = "nano";
  };

  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };

  systemd.user.startServices = "sd-switch";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
}
