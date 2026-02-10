{
  pkgs,
  lib,
  secrets,
  inputs,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."www.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:8787
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["www.footvaalvica.com"];

  services.static-web-server = {
    enable = true;
    root = inputs.website;
  };
}
