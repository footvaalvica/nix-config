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
}
