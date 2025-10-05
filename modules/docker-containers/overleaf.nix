# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  secrets,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."overleaf.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:4465
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["overleaf.footvaalvica.com"];

  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."mongo" = {
    image = "mongo:6.0";
    environment = {
      "MONGO_INITDB_DATABASE" = "sharelatex";
    };
    volumes = [
      "/home/mateusp/mongo_data:/data/db:rw"
      "/home/mateusp/nix-config/modules/docker-containers/bin/shared/mongodb-init-replica-set.js:/docker-entrypoint-initdb.d/mongodb-init-replica-set.js:rw"
    ];
    cmd = ["--replSet" "overleaf"];
    log-driver = "journald";
    extraOptions = [
      "--add-host=mongo:127.0.0.1"
      "--health-cmd=echo 'db.stats().ok' | mongosh localhost:27017/test --quiet"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=10s"
      "--network-alias=mongo"
      "--network=overleaf_default"
    ];
  };
  systemd.services."docker-mongo" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-overleaf_default.service"
    ];
    requires = [
      "docker-network-overleaf_default.service"
    ];
    partOf = [
      "docker-compose-overleaf-root.target"
    ];
    wantedBy = [
      "docker-compose-overleaf-root.target"
    ];
  };
  virtualisation.oci-containers.containers."redis" = {
    image = "redis:6.2";
    volumes = [
      "/home/mateusp/redis_data:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=overleaf_default"
    ];
  };
  systemd.services."docker-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-overleaf_default.service"
    ];
    requires = [
      "docker-network-overleaf_default.service"
    ];
    partOf = [
      "docker-compose-overleaf-root.target"
    ];
    wantedBy = [
      "docker-compose-overleaf-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sharelatex" = {
    image = "sharelatex/sharelatex:v1-texlive-full";
    environment = {
      # "DOCKER_RUNNER" = "true";
      "EMAIL_CONFIRMATION_DISABLED" = "true";
      "ENABLED_LINKED_FILE_TYPES" = "project_file,project_output_file";
      "ENABLE_CONVERSIONS" = "true";
      "OVERLEAF_APP_NAME" = "Overleaf Community Edition";
      "OVERLEAF_MONGO_URL" = "mongodb://mongo/sharelatex";
      "OVERLEAF_REDIS_HOST" = "redis";
      "REDIS_HOST" = "redis";

      "OVERLEAF_EMAIL_FROM_ADDRESS" = "mateusleitepinho@gmail.com";
      "OVERLEAF_SITE_URL" = "https://overleaf.footvaalvica.com";
      "OVERLEAF_NAV_TITLE" = "Overleaf Community Edition";
      "OVERLEAF_ADMIN_EMAIL" = "mateusleitepinho@gmail.com";
      "ENABLE_CRON_RESOURCE_DELETION" = "true";
      "OVERLEAF_EMAIL_SMTP_HOST" = "smtp.gmail.com";
      "OVERLEAF_EMAIL_SMTP_PORT" = "587";
      "OVERLEAF_EMAIL_SMTP_SECURE" = "false";
      "OVERLEAF_EMAIL_SMTP_USER" = "mateusleitepinho@gmail.com";
      "OVERLEAF_EMAIL_SMTP_PASS" = "${secrets.overleaf.smtp.password}";
      "OVERLEAF_EMAIL_SMTP_TLS_REJECT_UNAUTH" = "true";
      "OVERLEAF_EMAIL_SMTP_IGNORE_TLS" = "false";
      "OVERLEAF_EMAIL_SMTP_LOGGER" = "true";
      "OVERLEAF_CUSTOM_EMAIL_FOOTER" = "This system is run by Mateus Pinho";

      # "SANDBOXED_COMPILES" = "true";
      # "SANDBOXED_COMPILES_HOST_DIR_COMPILES" = "/home/user/sharelatex_data/data/compiles";
      # "SANDBOXED_COMPILES_HOST_DIR_OUTPUT" = "/home/user/sharelatex_data/data/output";
      # "SANDBOXED_COMPILES_SIBLING_CONTAINERS" = "true";
    };
    volumes = [
      "/home/mateusp/sharelatex_data:/var/lib/overleaf:rw"
      "/var/run/docker.sock:/var/run/docker.sock"
    ];
    ports = [
      "4465:80/tcp"
    ];
    dependsOn = [
      "mongo"
      "redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sharelatex"
      "--network=overleaf_default"
    ];
  };
  systemd.services."docker-sharelatex" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-overleaf_default.service"
    ];
    requires = [
      "docker-network-overleaf_default.service"
    ];
    partOf = [
      "docker-compose-overleaf-root.target"
    ];
    wantedBy = [
      "docker-compose-overleaf-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-overleaf_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f overleaf_default";
    };
    script = ''
      docker network inspect overleaf_default || docker network create overleaf_default
    '';
    partOf = ["docker-compose-overleaf-root.target"];
    wantedBy = ["docker-compose-overleaf-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-overleaf-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
