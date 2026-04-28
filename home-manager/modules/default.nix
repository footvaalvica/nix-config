{
  config,
  pkgs,
  inputs,
  ...
}: {
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
      settings = {
        plugin =  [ "@simonwjackson/opencode-direnv" ]
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

        Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

        # Debug Process

        When presented with a problem, follow this process:

        1. Write failing test (if applicable)
        2. Explain what the bug is, describing the root cause, not just the symptoms
        3. Explain what the fix is
        4. Find similar usages in the codebase and fix them too
      '';
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
