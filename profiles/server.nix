{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  secrets,
  ...
}: {
  virtualisation.podman = {
    enable = true;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    borgbackup
  ];

  # Fail2Ban
  services.fail2ban.enable = true;

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
        KbdInteractiveAuthentication yes

      Match all
        PasswordAuthentication no
        KbdInteractiveAuthentication no
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
