{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: 
let
  fqdn = "matrix.footvaalvica.com";
  baseUrl = "https://${fqdn}";
  clientConfig."m.homeserver".base_url = baseUrl;
  serverConfig."m.server" = "${fqdn}:443";
  
  ooye-registration = pkgs.writeText "ooye-registration.json" (builtins.toJSON {
          id = "ooye";
          as_token = secrets.matrix.discord_bridge.as_token;
          hs_token = secrets.matrix.discord_bridge.hs_token;
          namespaces = {
            users = [
              {
                exclusive = true;
                regex = "@_ooye_.*:${fqdn}";
              }
            ];
            aliases = [
              {
                exclusive = true;
                regex = "#_ooye_.*:${fqdn}";
              }
            ];
          };
          protocols = [ "discord" ];
          sender_localpart = "_ooye_bot";
          rate_limited = false;
          socket = 6693;
          ooye = {
            namespace_prefix = "_ooye_";
            server_name = fqdn;
            max_file_size = 5000000;
            content_length_workaround = false;
            include_user_id_in_mxid = false;
            invite = [ ];
            receive_presences = true;
            bridge_origin = "https://discord-bridge.footvaalvica.com";
            server_origin = baseUrl;
            discord_token = secrets.matrix.discord_bridge.discord_token;
            discord_client_secret = secrets.matrix.discord_bridge.client_secret;
            web_password = secrets.matrix.discord_bridge.web_password;
          };
          url = "https://discord-bridge.footvaalvica.com";
        });
in
{
  services.cloudflare-dyndns.domains = ["matrix.footvaalvica.com" "turn.footvaalvica.com" "discord-bridge.footvaalvica.com" ];

  services.caddy = {
    enable = true;
    virtualHosts."${fqdn}".extraConfig = ''
      # Proxy all Matrix API and client requests to Conduit
      reverse_proxy /_matrix/* http://127.0.0.1:6167

      # Discovery endpoints with proper CORS for web clients
      handle /.well-known/matrix/* {
        header Access-Control-Allow-Origin *
        header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization"
        header Content-Type application/json

        handle /.well-known/matrix/server {
          respond `${builtins.toJSON serverConfig}`
        }

        handle /.well-known/matrix/client {
          respond `${builtins.toJSON clientConfig}`
        }
      }

      # Fallback: proxy everything else (like the root) to Conduit
      handle {
        reverse_proxy http://127.0.0.1:6167
      }
    '';
    virtualHosts."discord-bridge.footvaalvica.com".extraConfig = ''
      reverse_proxy http://localhost:6693
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  # open the firewall
  networking.firewall = {
    allowedUDPPortRanges = [
      { from = 49000; to = 50000; }
    ];
    allowedUDPPorts = [ 3478 5349 ];
    allowedTCPPortRanges = [ ];
    allowedTCPPorts = [ 3478 5349 80 443 8448];
  };

  services.matrix-conduit = {
    enable = true;
    settings.global = {
      server_name = "matrix.footvaalvica.com";
      allow_registration = true;
      address = "127.0.0.1";
      port = 6167;
      trusted_servers = [ "matrix.org" ];
      database_backend = "rocksdb";
      appservice_configs = [ "${ooye-registration}" ];
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  systemd.services.ooye-bridge = {
    description = "Out of Your Element (Matrix-Discord Bridge)";
    after = [ "network.target" "matrix-conduit.service" ];
    wantedBy = [ "multi-user.target" ];
    script = "/bin/sh -lc 'npm run start'";
    serviceConfig = {
      User = "mateusp";
      WorkingDirectory = "/home/mateusp/Documents/out-of-your-element";
      Restart = "always";
      RestartSec = "10";
    };
  };
}
