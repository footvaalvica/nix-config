{
  pkgs,
  lib,
  secrets,
  ...
}: {

  services.caddy = {
    enable = true;
    virtualHosts."freshrss.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:5423
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["freshrss.footvaalvica.com"];

  services.freshrss = {
    enable = true;
    openFirewall = true;
    webserver = "caddy";
    virtualHost = "freshrss.footvaalvica.com";
    extensions = with freshrss-extensions; [
      youtube
      reddit-image
    ];
    api.enable = true;
    baseUrl = "https://freshrss.footvaalvica.com";

  
  };
}

