{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.openchamber;
  image = "compose2nix/openchamber";
  network = "openchamber_default";
  buildService = "docker-build-openchamber.service";
  networkService = "docker-network-${network}.service";
  targetName = "docker-compose-openchamber-root";
  target = "${targetName}.target";

  mounts = [
    {
      host = "${cfg.dataDir}/config/openchamber";
      container = "/home/openchamber/.config/openchamber";
      mode = "0750";
    }
    {
      host = "${cfg.dataDir}/config/opencode";
      container = "/home/openchamber/.config/opencode";
      mode = "0750";
    }
    {
      host = "${cfg.dataDir}/share/opencode";
      container = "/home/openchamber/.local/share/opencode";
      mode = "0750";
    }
    {
      host = "${cfg.dataDir}/state/opencode";
      container = "/home/openchamber/.local/state/opencode";
      mode = "0750";
    }
    {
      host = "${cfg.dataDir}/ssh";
      container = "/home/openchamber/.ssh";
      mode = "0700";
    }
    {
      host = "${cfg.dataDir}/workspaces";
      container = "/home/openchamber/workspaces";
      mode = "0750";
    }
  ];
in {
  options.services.openchamber = {
    sourceDir = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.str;
      default = inputs.openchamber;
      description = ''
        Path to the OpenChamber source repository used to build the Docker image.

        Defaults to the openchamber flake input. This can also be a regular host
        path or a checked-in git submodule path such as ./openchamber.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openchamber";
      description = "Persistent writable OpenChamber data directory.";
    };
  };

  config = {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };
    virtualisation.oci-containers.backend = "docker";

    services.caddy = {
      enable = true;
      virtualHosts."openchamber.footvaalvica.com".extraConfig = ''
        reverse_proxy 127.0.0.1:3535 {
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
      acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    };

    virtualisation.oci-containers.containers."openchamber" = {
      inherit image;
      volumes = map (mount: "${mount.host}:${mount.container}:rw") mounts;
      ports = ["3535:3000/tcp"];
      log-driver = "journald";
      environment.UI_PASSWORD = "";
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
        "--network-alias=openchamber"
        "--network=${network}"
      ];
    };

    systemd.tmpfiles.rules = map (mount: "d ${mount.host} ${mount.mode} root root -") mounts;

    systemd.services = {
      "docker-openchamber" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
          RestartMaxDelaySec = lib.mkOverride 90 "1m";
          RestartSec = lib.mkOverride 90 "100ms";
          RestartSteps = lib.mkOverride 90 9;
        };
        after = [
          buildService
          networkService
        ];
        requires = [
          buildService
          networkService
        ];
        partOf = [target];
        wantedBy = [target];
      };

      "docker-network-${network}" = {
        path = [pkgs.docker];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "docker network rm -f ${network}";
        };
        script = ''
          docker network inspect ${network} || docker network create ${network}
        '';
        partOf = [target];
        wantedBy = [target];
      };

      "docker-build-openchamber" = {
        path = [
          pkgs.coreutils
          pkgs.docker
          pkgs.git
          pkgs.gnused
        ];
        serviceConfig = {
          Type = "oneshot";
          TimeoutSec = 300;
        };
        script = ''
          build_dir=$(mktemp -d)
          trap 'rm -rf "$build_dir"' EXIT

          cp -R --no-preserve=mode,ownership ${lib.escapeShellArg (toString cfg.sourceDir)}/. "$build_dir"
          chmod -R u+w "$build_dir"
          sed -i 's/FROM oven\/bun:1/FROM oven\/bun:1.3.5/g' "$build_dir/Dockerfile"

          docker build -t ${image} "$build_dir"
        '';
      };
    };

    systemd.targets.${targetName} = {
      unitConfig = {
        Description = "OpenChamber containers.";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
