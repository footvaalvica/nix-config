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

  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      server_name = "matrix.footvaalvica.com";
      trusted_servers = [ "matrix.org" ];
      database_backend = "rocksdb";
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  services.mautrix-discord = {
    enable = true;
    settings = {
        homeserver = {
          address = "https://matrix.footvaalvica.com";
          domain = "matrix.footvaalvica.com";
        };

        bridge.permissions = {
          "matrix.footvaalvica.com" = "user";
          "@footvaalvica:matrix.footvaalvica.com" = "admin";
        };
        
        appservice = {
          address = "http://localhost:29334";
          hostname = "0.0.0.0";
          port = 29334;
          database = {
            type = "sqlite3";
            uri = "file:${config.services.mautrix-discord.dataDir}/mautrix-discord.db?_txlock=immediate";
            max_open_conns = 20;
            max_idle_conns = 2;
            max_conn_idle_time = null;
            max_conn_lifetime = null;
          };
          id = "discord";
          bot = {
            username = "discordbot";
            displayname = "Discord bridge bot";
            avatar = "mxc://maunium.net/nIdEykemnwdisvHbpxflpDlC";
          };
          ephemeral_events = true;
          async_transactions = false;
          as_token = "${secrets.matrix.discord_bridge.as_token}";
          hs_token = "${secrets.matrix.discord_bridge.hs_token}";
        };
      };
    
  };

  nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
  ];
}
