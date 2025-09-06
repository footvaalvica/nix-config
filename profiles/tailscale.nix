{
  config,
  pkgs,
  ...
}: {
  # make the tailscale command usable to users
  environment.systemPackages = [pkgs.unstable.tailscale];

  # enable the tailscale service
  services.tailscale = { 
    enable = true;
    package = pkgs.unstable.tailscale;
  };

  services.resolved.enable = true;

  networking.interfaces.tailscale0.useDHCP = false;

  networking.firewall = {
    # always allow traffic from your Tailscale network
    trustedInterfaces = ["tailscale0"];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
