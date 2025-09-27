{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  secrets,
  ...
}: {
  imports = [
    ./tailscale.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      trusted-users = ["root" "mateusp"];
      auto-optimise-store = true;
    };
    # Opinionated: disable channels
    channel.enable = false;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    
    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  virtualisation.podman = {
    enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  boot.loader.grub.memtest86.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    
  environment.systemPackages = with pkgs; [
    wget
    git
    inputs.home-manager.packages.${pkgs.system}.default
    htop
    tmux
    curl
    kdePackages.filelight
    borgbackup
    fastfetch
  ];

  programs.fish.enable = true;

  # Enable SSH server
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PubkeyAuthentication = true;
      X11Forwarding = true;
    };

    # Custom configuration for different authentication methods
    extraConfig = ''
      # For Tailscale connections (assuming Tailscale uses 100.x.x.x)
      Match Address 100.0.0.0/8
        PasswordAuthentication yes

      Match all
        PasswordAuthentication no
        PubkeyAuthentication yes
    '';
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqacUuGE1cwsquurVTRnW2Ixa5108dMwlKoUEdwZZPs deployment_key"
    ];
  };

  # # system.autoUpgrade = {
  # #   enable = true;
  # #   flake = inputs.self.outPath;
  # #   flags = [
  # #     "--update-input"
  # #     "nixpkgs"
  # #     "--no-write-lock-file"
  # #     "-L" # print build logs
  # #   ];
  # #   dates = "02:00";
  # #   randomizedDelaySec = "45min";
  # # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
