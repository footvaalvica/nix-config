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
  }
}
