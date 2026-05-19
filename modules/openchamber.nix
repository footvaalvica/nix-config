{
  config,
  lib,
  options,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.openchamber;
  containerServiceName = "docker-${cfg.containerName}";
  caddyUpstream = "127.0.0.1:${toString cfg.port}";
in
{
  options.services.openchamber = {
    enable = mkEnableOption "OpenChamber web server";

    source = mkOption {
      type = types.nullOr types.path;
      default = ./.;
      description = ''
        Source tree used to build the OpenChamber container image. Set to null
        to skip the local build and use `services.openchamber.image` as-is.
      '';
    };

    image = mkOption {
      type = types.str;
      default = "openchamber:local";
      description = "Container image used for OpenChamber.";
    };

    containerName = mkOption {
      type = types.str;
      default = "openchamber";
      description = "OCI container name.";
    };

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Host-local port exposed to the reverse proxy.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/openchamber";
      description = "Persistent OpenChamber data directory.";
    };

    environment = mkOption {
      type = types.attrsOf types.str;
      default = { };
      example = {
        UI_PASSWORD = "change-me";
        OH_MY_OPENCODE = "true";
      };
      description = "Extra environment variables passed to the container.";
    };

    environmentFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = [ "/run/secrets/openchamber.env" ];
      description = ''
        Environment files passed to the container. Use this for secrets, e.g.
        a file containing `UI_PASSWORD=...`.
      '';
    };

    reverseProxy = {
      enable = mkEnableOption "Caddy reverse proxy for OpenChamber";

      hostName = mkOption {
        type = types.str;
        example = "openchamber.example.com";
        description = "Caddy virtual host name for OpenChamber.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open ports 80 and 443 for Caddy.";
      };
    };

    cloudflareDdns = {
      enable = mkEnableOption "adding the OpenChamber reverse proxy hostname to services.cloudflare-ddns.domains";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
      };
      virtualisation.oci-containers.backend = "docker";

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0750 1000 1000 -"
        "d ${cfg.dataDir}/openchamber 0750 1000 1000 -"
        "d ${cfg.dataDir}/opencode 0750 1000 1000 -"
        "d ${cfg.dataDir}/opencode/config 0750 1000 1000 -"
        "d ${cfg.dataDir}/opencode/share 0750 1000 1000 -"
        "d ${cfg.dataDir}/opencode/state 0750 1000 1000 -"
        "d ${cfg.dataDir}/ssh 0700 1000 1000 -"
        "d ${cfg.dataDir}/workspaces 0750 1000 1000 -"
      ];

      virtualisation.oci-containers.containers.${cfg.containerName} = {
        image = cfg.image;
        ports = [ "127.0.0.1:${toString cfg.port}:3000/tcp" ];
        volumes = [
          "${cfg.dataDir}/openchamber:/home/openchamber/.config/openchamber:rw"
          "${cfg.dataDir}/opencode/config:/home/openchamber/.config/opencode:rw"
          "${cfg.dataDir}/opencode/share:/home/openchamber/.local/share/opencode:rw"
          "${cfg.dataDir}/opencode/state:/home/openchamber/.local/state/opencode:rw"
          "${cfg.dataDir}/ssh:/home/openchamber/.ssh:rw"
          "${cfg.dataDir}/workspaces:/home/openchamber/workspaces:rw"
        ];
        environment = {
          OPENCHAMBER_HOST = "0.0.0.0";
        }
        // cfg.environment;
        environmentFiles = cfg.environmentFiles;
        log-driver = "journald";
        extraOptions = [
          "--add-host=host.docker.internal:host-gateway"
        ];
      };

      systemd.services.${containerServiceName}.serviceConfig = {
        Restart = mkOverride 90 "always";
        RestartMaxDelaySec = mkOverride 90 "1m";
        RestartSec = mkOverride 90 "100ms";
        RestartSteps = mkOverride 90 9;
      };
    }

    (mkIf (cfg.source != null) {
      systemd.services.openchamber-image = {
        description = "Build OpenChamber container image";
        wantedBy = [ "multi-user.target" ];
        before = [ "${containerServiceName}.service" ];
        requiredBy = [ "${containerServiceName}.service" ];
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        path = [
          pkgs.docker
          pkgs.git
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          TimeoutSec = 900;
        };
        script = ''
          docker build -t ${escapeShellArg cfg.image} ${escapeShellArg (toString cfg.source)}
        '';
      };
    })

    (mkIf cfg.reverseProxy.enable {
      services.caddy = {
        enable = true;
        virtualHosts.${cfg.reverseProxy.hostName}.extraConfig = ''
          reverse_proxy ${caddyUpstream} {
              # WebSocket support is automatic in Caddy

              # Flush SSE responses immediately
              flush_interval -1

              # Pass through Host and proxy headers
              header_up Host {host}
              header_up X-Real-IP {remote_host}
              header_up X-Forwarded-For {remote_host}
              header_up X-Forwarded-Proto {scheme}

              # Increase timeouts for long-lived streams
              transport http {
                  read_timeout 3600s
                  write_timeout 3600s
              }
          }
        '';
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.reverseProxy.openFirewall [
        80
        443
      ];
    })

    (mkIf
      (cfg.cloudflareDdns.enable && cfg.reverseProxy.enable && options ? services.cloudflare-ddns.domains)
      {
        services.cloudflare-ddns.domains = [ cfg.reverseProxy.hostName ];
      }
    )
  ]);
}
