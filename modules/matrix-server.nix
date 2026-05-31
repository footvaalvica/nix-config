{
  pkgs,
  config,
  secrets,
  ...
}:
let
  domain = "footvaalvica.com";
  fqdn = "matrix.footvaalvica.com";
  livekitFqdn = "livekit.${domain}";

  baseUrl = "https://${fqdn}";
  livekitUrl = "https://${livekitFqdn}";
  livekitKeyFile = "/home/mateusp/nix-config/modules/matrix-key-file.txt";

  continuwuityPort = 6167;
  livekitPort = 7880;
  livekitJwtPort = 8081;

  clientConfig."m.homeserver".base_url = baseUrl;
  serverConfig."m.server" = "${fqdn}:443";

  mautrixHomeserver = {
    address = baseUrl;
    domain = fqdn;
  };
  mautrixPermissions = {
    "${fqdn}" = "user";
    "@footvaalvica:${fqdn}" = "admin";
  };

  mautrixSettings = {
    homeserver = mautrixHomeserver;
    bridge.permissions = mautrixPermissions;
  };

  maubotSonglinkPlugin = pkgs.maubot.plugins.buildMaubotPlugin rec {
    pname = "com.cyber.songlinkbot";
    version = "1.2.3";

    src = pkgs.fetchFromGitHub {
      owner = "tstrijdhorst";
      repo = "maubot-songlink-plugin";
      rev = "185fc2435b3599b55db332eb00c47394355cc6b9";
      sha256 = "0l2r2wjhvibgfa3m9z7dsvlfm60f6xdwvgm6m7xlwl3b4rr0130i";
    };
  };
in
{
  services.cloudflare-ddns.domains = [
    fqdn
    livekitFqdn
  ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "${fqdn}".extraConfig = ''
        # Proxy all Matrix API and client requests to Continuwuity
        reverse_proxy /_matrix/* http://127.0.0.1:${toString continuwuityPort}

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

        # Fallback: proxy everything else (like the root) to Continuwuity
        handle {
          reverse_proxy http://127.0.0.1:${toString continuwuityPort}
        }
      '';

      "${livekitFqdn}".extraConfig = ''
        @lk-jwt-service path /sfu/get* /healthz* /get_token*
        route @lk-jwt-service {
          reverse_proxy 127.0.0.1:${toString livekitJwtPort}
        }

        reverse_proxy 127.0.0.1:${toString livekitPort}
      '';
    };
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  # open the firewall
  networking.firewall = {
    allowedUDPPorts = [
      3478
    ];
    allowedUDPPortRanges = [
      {
        from = 50300;
        to = 50400;
      }
    ];
    allowedTCPPorts = [
      80
      443
    ];
  };

  services.matrix-continuwuity = {
    enable = true;
    settings.global = {
      server_name = fqdn;
      trusted_servers = [ "matrix.org" ];
      database_backend = "rocksdb";
      url_preview_domain_explicit_allowlist = [ "*" ];
      url_preview_allow_audio_video = true;
      matrix_rtc.foci = [
        {
          type = "livekit";
          livekit_service_url = livekitUrl;
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    nodejs
  ];

  services.mautrix-whatsapp = {
    enable = true;
    settings = mautrixSettings;
  };

  services.mautrix-discord = {
    enable = true;
    settings = mautrixSettings // {
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

  services.livekit = {
    enable = true;
    openFirewall = true;
    keyFile = livekitKeyFile;
    settings = {
      port = livekitPort;
      rtc = {
        tcp_port = 7881;
        port_range_start = 50100;
        port_range_end = 50200;
        use_external_ip = true;
        enable_loopback_candidate = false;
      };
      turn = {
        enabled = true;
        udp_port = 3478;
        relay_range_start = 50300;
        relay_range_end = 50400;
        domain = livekitFqdn;
      };
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  services.lk-jwt-service = {
    enable = true;
    port = livekitJwtPort;
    livekitUrl = "wss://${livekitFqdn}";
    keyFile = livekitKeyFile;
  };

  services.maubot = {
    enable = true;
    plugins = [ maubotSonglinkPlugin ];
    settings = {
      admins = {
        footvaalvica = "${secrets.matrix.discord_bridge.web_password}";
      };
      server.hostname = "0.0.0.0";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/maubot/plugins 0750 maubot maubot -"
    "d /var/lib/maubot/trash 0750 maubot maubot -"
  ];
}
