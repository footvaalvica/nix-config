{ pkgs, ... }:
{
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
      flags = [ "--disable-ctrl-r" ];
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

    opencode = {
      enable = true;
      tui.plugin = [ "oh-my-opencode-slim@2.0.3" ];
      enableMcpIntegration = true;
      settings = {
        plugin = [
          "@simonwjackson/opencode-direnv"
          "oh-my-opencode-slim@2.0.3"
        ];
        agent = {
          explore.disable = true;
          general.disable = true;
        };
        lsp = true;
      };
      context = ''
        You are a lazy senior developer. Lazy means efficient, not careless. The best code is the code never written.

        Before writing any code, stop at the first rung that holds:

        1. Does this need to be built at all? (YAGNI)
        2. Does the standard library already do this? Use it.
        3. Does a native platform feature cover it? Use it.
        4. Does an already-installed dependency solve it? Use it.
        5. Can this be one line? Make it one line.
        6. Only then: write the minimum code that works.

        Rules:

        - No abstractions that weren't explicitly requested.
        - No new dependency if it can be avoided.
        - No boilerplate nobody asked for.
        - Deletion over addition. Boring over clever. Fewest files possible.
        - Question complex requests: "Do you actually need X, or does Y cover it?"
        - Pick the edge-case-correct option when two stdlib approaches are the same size, lazy means less code, not the flimsier algorithm.
        - Mark intentional simplifications with a `ponytail:` comment. If the shortcut has a known ceiling (global lock, O(n²) scan, naive heuristic), the comment names the ceiling and the upgrade path.

        Not lazy about: input validation at trust boundaries, error handling that prevents data loss, security, accessibility, the calibration real hardware needs (the platform is never the spec ideal, a clock drifts, a sensor reads off), anything explicitly requested. Lazy code without its check is unfinished: non-trivial logic leaves ONE runnable check behind, the smallest thing that fails if the logic breaks (an assert-based demo/self-check or one small test file; no frameworks, no fixtures). Trivial one-liners need no test.
      '';
      skills = {
        clonedeps = ./skills/clonedeps;
        codemap = ./skills/codemap;
        deepwork = ./skills/deepwork;
        oh-my-opencode-slim = ./skills/oh-my-opencode-slim;
        reflect = ./skills/reflect;
        simplify = ./skills/simplify;
        worktrees = ./skills/worktrees;
      };
    };
  };

  xdg = {
    configFile."opencode/oh-my-opencode-slim.json".source = pkgs.writeText "oh-my-opencode-slim.json" (
      builtins.toJSON {
        "$schema" = "https://unpkg.com/oh-my-opencode-slim@2.0.3/oh-my-opencode-slim.schema.json";
        preset = "thirtydollars";
        presets = {
          thirtydollars = {
            orchestrator = {
              model = "openai/gpt-5.5";
              variant = "medium";
              skills = [ "*" ];
              mcps = [
                "*"
                "websearch"
              ];
            };
            oracle = {
              model = "openai/gpt-5.5";
              variant = "xhigh";
              skills = [ ];
              mcps = [ ];
            };
            council.model = "openai/gpt-5.5";
            librarian = {
              model = "openai/gpt-5.4-mini";
              variant = "low";
              skills = [ ];
              mcps = [
                "websearch"
                "context7"
                "gh_grep"
              ];
            };
            explorer = {
              model = "openai/gpt-5.4-mini";
              variant = "low";
              skills = [ ];
              mcps = [ ];
            };
            designer = {
              model = "github-copilot/gemini-3.5-flash";
              skills = [ ];
              mcps = [ ];
            };
            fixer = {
              model = "openai/gpt-5.5";
              variant = "low";
              skills = [ ];
              mcps = [ ];
            };
          };
        };
        council = {
          presets = {
            default = {
              alpha.model = "github-copilot/claude-sonnet-4.6";
              beta.model = "github-copilot/gemini-3.5-flash";
              gamma.model = "openai/gpt-5.5";
            };
          };
        };
      }
    );
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
