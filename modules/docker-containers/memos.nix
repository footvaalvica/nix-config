{
  pkgs,
  lib,
  secrets,
  ...
}: {
  # # # Create a variable for the current immich version
  # # # Caddy config for Immich
  # # services.caddy = {
  # #   enable = true;
  # #   virtualHosts."memos.footvaalvica.com".extraConfig = ''
  # #     reverse_proxy localhost:5230
  # #   '';
  # #   acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  # # };

  # # services.cloudflare-dyndns.domains = ["memos.footvaalvica.com"];

  
  # # # # # Memo service configuration
  # # # # services.memos = {
  # # # #   enable = true;
  # # # #   image = "neosmemo/memos:stable";
  # # # #   ports = [ "5230:5230" ];
  # # # #   volumes = [ "~/.memos:/var/opt/memos" ];
  # # # #   restart = "always";
  # # # # };

}
