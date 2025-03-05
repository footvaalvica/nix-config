{ config, pkgs, ... }:

{

  services.ollama = {
    enable = true;
    # Optional: load models on startup
    loadModels = [ "deepseek-r1:1.5b" ];
    openFirewall = true;
  };

  services.open-webui = {
    enable = true;
    openFirewall = true;
    port = 11111;
  }

  services.caddy = {
    enable = true;
    virtualHosts."llm.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:11111
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = [ "llm.footvaalvica.com" ];
}
