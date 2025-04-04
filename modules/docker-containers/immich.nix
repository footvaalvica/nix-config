# Auto-generated using compose2nix v0.2.3-pre.
{
  pkgs,
  lib,
  secrets,
  ...
}: let
  immichVersion = "v1.129.0";
in {
  # Create a variable for the current immich version
  # Caddy config for Immich
  services.caddy = {
    enable = true;
    virtualHosts."photos.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:2283
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["photos.footvaalvica.com"];

  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Run the script every day at 3:00 AM as root
  systemd.services."immich_backup_script" = {
    script = ''
      /bin/sh -lc 'cd /mnt/immich_backup'
      /bin/sh -lc 'cd ~'
      /bin/sh -lc 'docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres > /home/mateusp/ImmichDB/database-backup/immich-database.sql'
      /bin/sh -lc 'borg create /mnt/immich_backup/immich-borg::{now} /home/mateusp/ImmichDB/database-backup/immich-database.sql'
      /bin/sh -lc 'borg create /mnt/immich_backup/immich-borg::{now} /mnt/immich/Library --exclude /mnt/immich/Library/thumbs/ --exclude /mnt/immich/Library/encoded-video/'
      /bin/sh -lc 'borg prune --keep-weekly=4 --keep-monthly=3 /mnt/immich_backup/immich-borg'
      /bin/sh -lc 'borg compact /mnt/immich_backup/immich-borg'
    '';
    serviceConfig = {
      User = "root";
      Type = "oneshot";
    };
  };

  systemd.timers."immich_backup_script" = {
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      Unit = "immich_backup_script.service";
    };
    wantedBy = ["timers.target"];
  };

  # Containers
  virtualisation.oci-containers.containers."immich_machine_learning" = {
    image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "/home/mateusp/ImmichDB";
      "DB_PASSWORD" = "${secrets.immich.postgres.password}";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "${immichVersion}";
      "UPLOAD_LOCATION" = "/mnt/immich/Library";
    };
    volumes = [
      "immich_model-cache:/cache:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-machine-learning"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_machine_learning" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
      "docker-volume-immich_model-cache.service"
    ];
    requires = [
      "docker-network-immich_default.service"
      "docker-volume-immich_model-cache.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_postgres" = {
    image = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0";
    environment = {
      "POSTGRES_DB" = "immich";
      "POSTGRES_INITDB_ARGS" = "--data-checksums";
      "POSTGRES_PASSWORD" = "${secrets.immich.postgres.password}";
      "POSTGRES_USER" = "postgres";
    };
    volumes = [
      "/home/mateusp/ImmichDB:/var/lib/postgresql/data:rw"
    ];
    cmd = ["postgres" "-c" "shared_preload_libraries=vectors.so" "-c" "search_path=\"$user\", public, vectors" "-c" "logging_collector=on" "-c" "max_wal_size=2GB" "-c" "shared_buffers=512MB" "-c" "wal_compression=on"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready --dbname='immich' --username='postgres' || exit 1; Chksum=\"$(psql --dbname='immich' --username='postgres' --tuples-only --no-align --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')\"; echo \"checksum failure count is $Chksum\"; [ \"$Chksum\" = '0' ] || exit 1"
      "--health-interval=5m0s"
      "--health-start-interval=30s"
      "--health-start-period=5m0s"
      "--network-alias=database"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_postgres" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_redis" = {
    image = "docker.io/redis:6.2-alpine@sha256:2d1463258f2764328496376f5d965f20c6a67f66ea2b06dc42af351f75248792";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "/home/mateusp/ImmichDB";
      "DB_PASSWORD" = "${secrets.immich.postgres.password}";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "${immichVersion}";
      "UPLOAD_LOCATION" = "/mnt/immich/Library";
    };
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=redis-cli ping || exit 1"
      "--network-alias=redis"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };
  virtualisation.oci-containers.containers."immich_server" = {
    image = "ghcr.io/immich-app/immich-server:${immichVersion}";
    environment = {
      "DB_DATABASE_NAME" = "immich";
      "DB_DATA_LOCATION" = "/home/mateusp/ImmichDB";
      "DB_PASSWORD" = "${secrets.immich.postgres.password}";
      "DB_USERNAME" = "postgres";
      "IMMICH_VERSION" = "${immichVersion}";
      "UPLOAD_LOCATION" = "/mnt/immich/Library";
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/mnt/immich/Library:/usr/src/app/upload:rw"
      "/mnt/nextcloud:/mnt/nextcloud:rw"
    ];
    ports = [
      "2283:2283/tcp"
    ];
    dependsOn = [
      "immich_postgres"
      "immich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=immich-server"
      "--network=immich_default"
    ];
  };
  systemd.services."docker-immich_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-immich_default.service"
    ];
    requires = [
      "docker-network-immich_default.service"
    ];
    partOf = [
      "docker-compose-immich-root.target"
    ];
    wantedBy = [
      "docker-compose-immich-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-immich_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f immich_default";
    };
    script = ''
      docker network inspect immich_default || docker network create immich_default
    '';
    partOf = ["docker-compose-immich-root.target"];
    wantedBy = ["docker-compose-immich-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-immich_model-cache" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect immich_model-cache || docker volume create immich_model-cache
    '';
    partOf = ["docker-compose-immich-root.target"];
    wantedBy = ["docker-compose-immich-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-immich-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
