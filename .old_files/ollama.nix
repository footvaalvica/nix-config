{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama;
    # Optional: load models on startup
    loadModels = ["qwen3.5:2b"];
    openFirewall = true;
    host = "0.0.0.0";
  };

  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui;
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

  services.cloudflare-ddns.domains = ["chat.footvaalvica.com"];
}
