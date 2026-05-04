{ pkgs, ... }:
{
  imports = [
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mateusp";
  home.homeDirectory = "/home/mateusp";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    devenv
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

    atuin = {
      enable = true;
      enableFishIntegration = true;
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

    opencode = {
      enable = true;
      tui.plugin = [ "oh-my-opencode-slim@1.0.6" ];
      agents = {
        thesis_writer = ''
          ---
          description: A model for writing LaTeX and searching through codebases and documentation to support thesis writing.
          mode: primary
          model: openai/gpt-5.4-mini-fast
          reasoningEffort: "low"
          temperature: 0.1
          ---
          You are Thesis Writer – a research assistant specialized in writing academic theses in LaTeX.

          **Role**: Write, revise, and structure thesis content based on code analysis and literature research. You never write executable code (Python, JavaScript, etc.) – only LaTeX, pseudocode, or natural language.

          **Capabilities**:
          - Search the local codebase to extract results, algorithms, data flows, or implementation details.
          - Look up official documentation (libraries, frameworks) and research papers.
          - Find relevant examples in open‑source repositories.
          - Produce well‑formatted LaTeX: sections, figures, tables, equations, citations, appendices.

          **Tools & When to Use**:
          - **grep** / **ast_grep_search** – Find variable names, function logic, configuration values, or comment‑based explanations inside the codebase.
          - **glob** – Locate source files by pattern (e.g., `*.py`, `src/**/*.rs`).
          - **context7** – Retrieve official library docs, API references, or best practices.
          - **grep_app** – Search GitHub for implementation patterns or usage examples.
          - **websearch** – Find general information, papers, or tutorials.

          **Behavior**:
          - Always answer with concrete evidence from the codebase or documentation. Quote relevant snippets (as LaTeX verbatim or inline code formatting) and provide file paths or URLs.
          - If information is missing or ambiguous, state the gap explicitly and suggest where to look next.
          - When asked to “explain how X works” from code, translate logic into clear academic language, optionally with pseudocode or a LaTeX algorithmic environment.
          - Never output raw code meant for execution. If a code snippet is needed for illustration, embed it in a LaTeX `\verb` or `\begin{lstlisting}` block.
          ```
        '';
      };
      settings = {
        plugin = [
          "@simonwjackson/opencode-direnv"
          "oh-my-opencode-slim@1.0.6"
          "true-mem"
        ];
        agent = {
          explore.disable = true;
          general.disable = true;
        };
        lsp = true;
      };
      context = ''
        # Code Quality

        ## 1. Think Before Coding
        **Don't assume. Don't hide confusion. Surface tradeoffs.**

        Before implementing:

        - State your assumptions explicitly. If uncertain, ask.
        - If multiple interpretations exist, present them - don't pick silently.
        - If a simpler approach exists, say so. Push back when warranted.
        - If something is unclear, stop. Name what's confusing. Ask.

        ## 2. Simplicity First

        **Minimum code that solves the problem. Nothing speculative.**

        - No features beyond what was asked.
        - No abstractions for single-use code.
        - No "flexibility" or "configurability" that wasn't requested.
        - No error handling for impossible scenarios.
        - If you write 200 lines and it could be 50, rewrite it.

        Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

        ## 3. Surgical Changes

        **Touch only what you must. Clean up only your own mess.**

        When editing existing code:

        - Don't "improve" adjacent code, comments, or formatting.
        - Don't refactor things that aren't broken.
        - Match existing style, even if you'd do it differently.
        - If you notice unrelated dead code, mention it - don't delete it.

        When your changes create orphans:

        - Remove imports/variables/functions that YOUR changes made unused.
        - Don't remove pre-existing dead code unless asked.

        The test: Every changed line should trace directly to the user's request.

        ## 4. Goal-Driven Execution

        **Define success criteria. Loop until verified.**

        Transform tasks into verifiable goals:

        - "Add validation" → "Write tests for invalid inputs, then make them pass"
        - "Fix the bug" → "Write a test that reproduces it, then make it pass"
        - "Refactor X" → "Ensure tests pass before and after"

        For multi-step tasks, state a brief plan:

        ```
        1. [Step] → verify: [check]
        2. [Step] → verify: [check]
        3. [Step] → verify: [check]
        ```

        Include delegation to other agents (especially Fixer) when appropriate.

        Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

        # Debug Process

        When presented with a problem, follow this process:

        1. Write failing test (if applicable)
        2. Explain what the bug is, describing the root cause, not just the symptoms
        3. Explain what the fix is
        4. Find similar usages in the codebase and fix them too
      '';
      skills = {
        codemap = ./skills/codemap;
        simplify = ./skills/simplify;
      };
    };
  };

  xdg = {
    configFile."opencode/oh-my-opencode-slim.json".source = pkgs.writeText "oh-my-opencode-slim.json" (
      builtins.toJSON {
        "$schema" = "https://unpkg.com/oh-my-opencode-slim@1.0.6/oh-my-opencode-slim.schema.json";
        preset = "thirtydollars";
        presets = {
          thirtydollars = {
            orchestrator = {
              model = "openai/gpt-5.5-fast";
              skills = [ "*" ];
              mcps = [
                "*"
                "!context7"
              ];
            };
            oracle = {
              model = "openai/gpt-5.5-fast";
              variant = "high";
              skills = [ ];
              mcps = [ ];
            };
            council.model = "openai/gpt-5.5-fast";
            librarian = {
              model = "openai/gpt-5.4-mini-fast";
              variant = "low";
              skills = [ ];
              mcps = [
                "websearch"
                "context7"
                "grep_app"
              ];
            };
            explorer = {
              model = "openai/gpt-5.4-mini-fast";
              variant = "low";
              skills = [ ];
              mcps = [ ];
            };
            designer = {
              model = "github-copilot/gemini-3.1-pro-preview";
              skills = [ "agent-browser" ];
              mcps = [ ];
            };
            fixer = {
              model = "openai/gpt-5.4-mini-fast";
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
              beta.model = "github-copilot/gemini-3.1-pro-preview";
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
