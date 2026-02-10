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

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;

    # This ensures the user/role exists
    ensureUsers = [{
      name = "matrix-synapse";
      ensureDBOwnership = true;
    }];

    ensureDatabases = [ "matrix-synapse" ];
  };

  services.caddy = {
    enable = true;
    virtualHosts."${fqdn}".extraConfig = ''
      # Proxy all Matrix API and client requests to Synapse
      reverse_proxy /_matrix/* http://127.0.0.1:8008
      reverse_proxy /_synapse/client/* http://127.0.0.1:8008

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

      # Fallback: proxy everything else (like the root) to Synapse
      handle {
        reverse_proxy http://127.0.0.1:8008
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

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "matrix.footvaalvica.com";
      # ! switch this when people wanna register, else just use matrix.org
      enable_registration = false;
      public_baseurl = baseUrl;

      # Security & Verification
      macaroon_secret_key = secrets.matrix.macaroon_secret_key; # Generate with: openssl rand -hex 32
      registration_shared_secret = secrets.matrix.registration_shared_secret;
      suppress_key_server_warning = true;

      # Verification: Email
      registrations_require_3pid = ["email"];
      email = {
        enable_notifs = true;
        notif_from = "Matrix <matrix@footvaalvica.com>";
        smtp_host = "smtp.gmail.com";
        smtp_port = 587;
        smtp_user = "mateusleitepinho@gmail.com";
        smtp_pass = secrets.overleaf.smtp.password; # Using your Overleaf SMTP secret
        require_transport_security = true;
      };

      database = {
        name = "psycopg2";
        args = {
          user = "matrix-synapse";
          database = "matrix-synapse";
          host = "/run/postgresql";
        };
        allow_unsafe_locale = true;
      };

      app_service_config_files = [
        (pkgs.writeText "ooye-registration.json" (builtins.toJSON {
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
        }))
      ];

      listeners = [
      {
        port = 8008;
        bind_addresses = [ "0.0.0.0" ];
        type = "http";
        tls = false;
        x_forwarded = true;
        resources = [
          {
            names = [
              "client"
              "federation"
            ];
            compress = true;
          }
        ];
      }
    ];
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  systemd.services.ooye-bridge = {
    description = "Out of Your Element (Matrix-Discord Bridge)";
    after = [ "network.target" "matrix-synapse.service" ];
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
