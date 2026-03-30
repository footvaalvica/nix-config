{
  pkgs,
  lib,
  secrets,
  config,
  agenix,
  ...
}: {

  services.cloudflare-dyndns.domains = ["freshrss.footvaalvica.com"];

  age.secrets.freshrss-password-file = {
    file = ../secrets/freshrss.age;
    mode = "777";
  };

  services.freshrss = {
    enable = true;
    webserver = "caddy";
    virtualHost = "freshrss.footvaalvica.com";
    extensions = with pkgs.freshrss-extensions; [
      youtube
      reddit-image
    ];
    baseUrl = "https://freshrss.footvaalvica.com"; 
	passwordFile = config.age.secrets.freshrss-password-file.path;
  };
}

