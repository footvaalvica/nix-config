# Auto-generated using compose2nix v0.2.2-pre.
{ pkgs, lib, config, ... }:

{
  # Reverse proxy config for Docker
  services.caddy = {
    enable = true;
    virtualHosts."nextcloud.casa-vlc.duckdns.org:443".extraConfig = ''
      reverse_proxy localhost:11000
    '';
    virtualHosts."nextcloud.casa-vlc.duckdns.org:8443".extraConfig = ''
      reverse_proxy https://localhost:8080 {
        transport http {
            tls_insecure_skip_verify
        }
      }
    ''; 
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };
 
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";
    
  # Containers
  virtualisation.oci-containers.containers."nextcloud-aio-mastercontainer" = {
    image = "nextcloud/all-in-one:latest";
    environment = {
      "APACHE_PORT" = "11000";
      "APACHE_IP_BINDING" = "127.0.0.1"; 
      "NEXTCLOUD_DATADIR" = "/mnt/nextcloud";
      "NEXTCLOUD_ENABLE_DRI_DEVICE" = "true"; 
    };
    volumes = [
      "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
      "/mnt/immich:/mnt/immich:ro"
    ];
    ports = [
      "8080:8080"
    ];
    extraOptions = [
      "--init"
      "--sig-proxy=false"
    ];
    autoStart = true;
  };
}