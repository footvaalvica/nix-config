{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    # Optional: load models on startup
    loadModels = [ "deepseek-r1:1.5b" "deepseek-r1:7b" "taozhiyuai/llama-3-8b-ultra-instruct:q2_k"];
    openFirewall = true;
    host = "0.0.0.0";
  };

  services.open-webui = {
    enable = true;
    openFirewall = true;
    port = 11111;
  };

  services.caddy = {
    enable = true;
    virtualHosts."chat.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:11111
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = [ "chat.footvaalvica.com" ];
}
