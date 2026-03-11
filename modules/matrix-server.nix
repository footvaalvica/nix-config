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
  keyFile = "/run/livekit.key";
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

      # LiveKit JWT service
      handle_path /livekit/jwt/* {
        reverse_proxy http://localhost:${toString config.services.lk-jwt-service.port}
      }

      # LiveKit SFU (WebSocket)
      handle_path /livekit/sfu/* {
        reverse_proxy http://localhost:${toString config.services.livekit.settings.port}
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
      turn_uris = [ "turn:turn.footvaalvica.com?transport=udp" "turn:turn.footvaalvica.com?transport=tcp" "turns:turn.footvaalvica.com:5349?transport=tcp" "turns:turn.footvaalvica.com?transport=udp" ];
      turn_secret = "${secrets.coturn.static_auth_secret}";
      turn_ttl = 86400;
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  services.mautrix-whatsapp = {
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
    };
  };

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

  # enable coturn
  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret = "${secrets.coturn.static_auth_secret}";
    realm = "turn.footvaalvica.com";
    cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };
  # get a certificate
  security.acme.certs.${config.services.coturn.realm} = {
    dnsProvider = "cloudflare";
    environmentFile = "/run/secrets/cloudflare-acme.env"; # CF_DNS_API_TOKEN=<token>
    postRun = "systemctl restart coturn.service";
    group = "turnserver";
  };
  services.livekit = {
    enable = true;
    openFirewall = true;
    settings.room.auto_create = false;
    inherit keyFile;
  };
  services.lk-jwt-service = {
    enable = true;
    # can be on the same virtualHost as synapse
    livekitUrl = "wss://${fqdn}/livekit/sfu";
    inherit keyFile;
  };
  # generate the key when needed
  systemd.services.livekit-key = {
    before = [ "lk-jwt-service.service" "livekit.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ livekit coreutils gawk ];
    script = ''
        echo "Key missing, generating key"
        echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "${keyFile}"
    '';
    serviceConfig.Type = "oneshot";
    unitConfig.ConditionPathExists = "!${keyFile}";
  };
  # restrict access to livekit room creation to a homeserver
  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = fqdn;


  nixpkgs.config.permittedInsecurePackages = [
      "olm-3.2.16"
  ];
}
