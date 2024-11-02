# Auto-generated using compose2nix v0.2.2-pre.
{ pkgs, lib, secrets, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";
  
  # Caddy config for mealie
  services.caddy = {
    enable = true;
    virtualHosts."mealie.casa-vlc.duckdns.org".extraConfig = ''
      reverse_proxy localhost:9925
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };
  
  # Containers
  virtualisation.oci-containers.containers."mealie" = {
    image = "ghcr.io/mealie-recipes/mealie:v2.0.0";
    environment = {
      "ALLOW_SIGNUP" = "false";
      "BASE_URL" = "https://mealie.casa-vlc.duckdns.org";
      "DB_ENGINE" = "postgres";
      "MAX_WORKERS" = "1";
      "PGID" = "1000";
      "POSTGRES_DB" = "mealie";
      "POSTGRES_PASSWORD" = "${secrets.mealie.postgres.password}";
      "POSTGRES_PORT" = "5432";
      "POSTGRES_SERVER" = "postgres";
      "POSTGRES_USER" = "mealie";
      "PUID" = "1000";
      "SMTP_AUTH_STRATEGY" = "SSL";
      "SMTP_FROM_EMAIL" = "mateusleitepinho@gmail.com";
      "SMTP_FROM_NAME" = "mateusleitepinho@gmail.com";
      "SMTP_HOST" = "smtp.gmail.com";
      "SMTP_PASSWORD" = "${secrets.smtp.password}";
      "SMTP_PORT" = "465";
      "SMTP_USER" = "mateusleitepinho@gmail.com";
      "TZ" = "Europe/Lisbon";
      "WEB_CONCURRENCY" = "1";
    };
    volumes = [
      "mealieio_mealie-data:/app/data:rw"
    ];
    ports = [
      "9925:9000/tcp"
    ];
    dependsOn = [
      "postgres"
    ];
    log-driver = "journald";
    extraOptions = [
      "--memory=1048576000b"
      "--network-alias=mealie"
      "--network=mealieio_default"
    ];
  };
  systemd.services."docker-mealie" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-mealieio_default.service"
      "docker-volume-mealieio_mealie-data.service"
    ];
    requires = [
      "docker-network-mealieio_default.service"
      "docker-volume-mealieio_mealie-data.service"
    ];
    partOf = [
      "docker-compose-mealieio-root.target"
    ];
    wantedBy = [
      "docker-compose-mealieio-root.target"
    ];
  };
  virtualisation.oci-containers.containers."postgres" = {
    image = "postgres:15";
    environment = {
      "POSTGRES_PASSWORD" = "${secrets.mealie.postgres.password}";
      "POSTGRES_USER" = "mealie";
    };
    volumes = [
      "mealieio_mealie-pgdata:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"pg_isready\"]"
      "--health-interval=30s"
      "--health-retries=3"
      "--health-timeout=20s"
      "--network-alias=postgres"
      "--network=mealieio_default"
    ];
  };
  systemd.services."docker-postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
      RestartMaxDelaySec = lib.mkOverride 500 "1m";
      RestartSec = lib.mkOverride 500 "100ms";
      RestartSteps = lib.mkOverride 500 9;
    };
    after = [
      "docker-network-mealieio_default.service"
      "docker-volume-mealieio_mealie-pgdata.service"
    ];
    requires = [
      "docker-network-mealieio_default.service"
      "docker-volume-mealieio_mealie-pgdata.service"
    ];
    partOf = [
      "docker-compose-mealieio-root.target"
    ];
    wantedBy = [
      "docker-compose-mealieio-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-mealieio_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f mealieio_default";
    };
    script = ''
      docker network inspect mealieio_default || docker network create mealieio_default
    '';
    partOf = [ "docker-compose-mealieio-root.target" ];
    wantedBy = [ "docker-compose-mealieio-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-mealieio_mealie-data" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect mealieio_mealie-data || docker volume create mealieio_mealie-data
    '';
    partOf = [ "docker-compose-mealieio-root.target" ];
    wantedBy = [ "docker-compose-mealieio-root.target" ];
  };
  systemd.services."docker-volume-mealieio_mealie-pgdata" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect mealieio_mealie-pgdata || docker volume create mealieio_mealie-pgdata
    '';
    partOf = [ "docker-compose-mealieio-root.target" ];
    wantedBy = [ "docker-compose-mealieio-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-mealieio-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
