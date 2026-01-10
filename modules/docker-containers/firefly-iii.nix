# Auto-generated using compose2nix v0.3.2-pre.
{
  pkgs,
  lib,
  secrets,
  ...
}: {
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  services.caddy = {
    enable = true;
    virtualHosts."firefly.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:44212
    '';
    virtualHosts."firefly-data-importer.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:8181
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

  services.cloudflare-dyndns.domains = ["firefly.footvaalvica.com" "firefly-data-importer.footvaalvica.com"];

  # Containers
  virtualisation.oci-containers.containers."firefly_iii_core" = {
    image = "fireflyiii/core:latest";
    environment = {
      "ALLOW_WEBHOOKS" = "false";
      "APP_DEBUG" = "false";
      "APP_ENV" = "production";
      "APP_KEY" = "SomeRandomStringOf32CharsExactly";
      "APP_LOG_LEVEL" = "notice";
      "APP_NAME" = "FireflyIII";
      "APP_URL" = "http://localhost";
      "AUDIT_LOG_CHANNEL" = "";
      "AUDIT_LOG_LEVEL" = "emergency";
      "AUTHENTICATION_GUARD" = "web";
      "AUTHENTICATION_GUARD_EMAIL" = "";
      "AUTHENTICATION_GUARD_HEADER" = "REMOTE_USER";
      "BROADCAST_DRIVER" = "log";
      "CACHE_DRIVER" = "file";
      "CACHE_PREFIX" = "firefly";
      "COOKIE_DOMAIN" = "";
      "COOKIE_PATH" = "/";
      "COOKIE_SAMESITE" = "lax";
      "COOKIE_SECURE" = "false";
      "CUSTOM_LOGOUT_URL" = "";
      "DB_CONNECTION" = "mysql";
      "DB_DATABASE" = "firefly";
      "DB_HOST" = "db";
      "DB_PASSWORD" = "${secrets.firefly.db.password}";
      "DB_PORT" = "3306";
      "DB_SOCKET" = "";
      "DB_USERNAME" = "firefly";
      "DEFAULT_LANGUAGE" = "en_US";
      "DEFAULT_LOCALE" = "equal";
      "DEMO_PASSWORD" = "";
      "DEMO_USERNAME" = "";
      "DISABLE_CSP_HEADER" = "false";
      "DISABLE_FRAME_HEADER" = "false";
      "DKR_BUILD_LOCALE" = "false";
      "DKR_CHECK_SQLITE" = "true";
      "ENABLE_EXCHANGE_RATES" = "false";
      "ENABLE_EXTERNAL_MAP" = "false";
      "ENABLE_EXTERNAL_RATES" = "false";
      "FIREFLY_III_LAYOUT" = "v1";
      "IPINFO_TOKEN" = "";
      "LOG_CHANNEL" = "stack";
      "MAILERSEND_API_KEY" = "";
      "MAILGUN_DOMAIN" = "";
      "MAILGUN_ENDPOINT" = "api.mailgun.net";
      "MAILGUN_SECRET" = "";
      "MAIL_ALLOW_SELF_SIGNED" = "false";
      "MAIL_ENCRYPTION" = "null";
      "MAIL_FROM" = "changeme@example.com";
      "MAIL_HOST" = "null";
      "MAIL_MAILER" = "log";
      "MAIL_PASSWORD" = "null";
      "MAIL_PORT" = "2525";
      "MAIL_SENDMAIL_COMMAND" = "";
      "MAIL_USERNAME" = "null";
      "MAIL_VERIFY_PEER" = "true";
      "MAIL_VERIFY_PEER_NAME" = "true";
      "MANDRILL_SECRET" = "";
      "MAP_DEFAULT_LAT" = "51.983333";
      "MAP_DEFAULT_LONG" = "5.916667";
      "MAP_DEFAULT_ZOOM" = "6";
      "MYSQL_SSL_CA" = "";
      "MYSQL_SSL_CAPATH" = "/etc/ssl/certs/";
      "MYSQL_SSL_CERT" = "";
      "MYSQL_SSL_CIPHER" = "";
      "MYSQL_SSL_KEY" = "";
      "MYSQL_SSL_VERIFY_SERVER_CERT" = "true";
      "MYSQL_USE_SSL" = "false";
      "PAPERTRAIL_HOST" = "";
      "PAPERTRAIL_PORT" = "";
      "PASSPORT_PRIVATE_KEY" = "";
      "PASSPORT_PUBLIC_KEY" = "";
      "PGSQL_SCHEMA" = "public";
      "PGSQL_SSL_CERT" = "null";
      "PGSQL_SSL_CRL_FILE" = "null";
      "PGSQL_SSL_KEY" = "null";
      "PGSQL_SSL_MODE" = "prefer";
      "PGSQL_SSL_ROOT_CERT" = "null";
      "PUSHER_ID" = "";
      "PUSHER_KEY" = "";
      "PUSHER_SECRET" = "";
      "QUERY_PARSER_IMPLEMENTATION" = "legacy";
      "QUEUE_DRIVER" = "sync";
      "REDIS_CACHE_DB" = "1";
      "REDIS_DB" = "0";
      "REDIS_HOST" = "127.0.0.1";
      "REDIS_PASSWORD" = "";
      "REDIS_PATH" = "";
      "REDIS_PORT" = "6379";
      "REDIS_SCHEME" = "tcp";
      "REDIS_USERNAME" = "";
      "SEND_ERROR_MESSAGE" = "true";
      "SEND_REPORT_JOURNALS" = "true";
      "SESSION_DRIVER" = "file";
      "SITE_OWNER" = "mail@example.com";
      "SPARKPOST_SECRET" = "";
      "STATIC_CRON_TOKEN" = "";
      "TRACKER_SITE_ID" = "";
      "TRACKER_URL" = "";
      "TRUSTED_PROXIES" = "*";
      "TZ" = "Europe/Lisbon";
      "USE_RUNNING_BALANCE" = "false";
      "VALID_URL_PROTOCOLS" = "";
    };
    volumes = [
      "firefly-iii_firefly_iii_upload:/var/www/html/storage/upload:rw"
    ];
    ports = [
      "44212:8080/tcp"
    ];
    dependsOn = [
      "firefly_iii_db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--hostname=app"
      "--network-alias=app"
      "--network=firefly-iii-data-importer_firefly_iii"
    ];
  };
  systemd.services."docker-firefly_iii_core" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
      "docker-volume-firefly-iii_firefly_iii_upload.service"
    ];
    requires = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
      "docker-volume-firefly-iii_firefly_iii_upload.service"
    ];
    partOf = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
    wantedBy = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
  };
  virtualisation.oci-containers.containers."firefly_iii_cron" = {
    image = "alpine";
    cmd = ["sh" "-c" " apk add tzdata && ln -s /usr/share/zoneinfo/Europe/Lisbon /etc/localtime | echo \"0 3 * * * wget -qO- http://app:8080/api/v1/cron/${secrets.firefly.token};echo\" | crontab - && crond -f -L /dev/stdout"];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=cron"
      "--network=firefly-iii-data-importer_firefly_iii"
    ];
  };
  systemd.services."docker-firefly_iii_cron" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
    ];
    requires = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
    ];
    partOf = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
    wantedBy = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
  };
  virtualisation.oci-containers.containers."firefly_iii_db" = {
    image = "mariadb:lts";
    environment = {
      "MYSQL_DATABASE" = "firefly";
      "MYSQL_PASSWORD" = "${secrets.firefly.db.password}";
      "MYSQL_RANDOM_ROOT_PASSWORD" = "yes";
      "MYSQL_USER" = "firefly";
    };
    volumes = [
      "firefly-iii_firefly_iii_db:/var/lib/mysql:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--hostname=db"
      "--network-alias=db"
      "--network=firefly-iii-data-importer_firefly_iii"
    ];
  };
  systemd.services."docker-firefly_iii_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
      "docker-volume-firefly-iii_firefly_iii_db.service"
    ];
    requires = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
      "docker-volume-firefly-iii_firefly_iii_db.service"
    ];
    partOf = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
    wantedBy = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
  };
  virtualisation.oci-containers.containers."firefly_iii_importer" = {
    image = "fireflyiii/data-importer:latest";
    environment = {
      "APP_DEBUG" = "false";
      "APP_ENV" = "local";
      "APP_NAME" = "DataImporter";
      "APP_URL" = "http://localhost";
      "ASSET_URL" = "";
      "AUTO_IMPORT_SECRET" = "";
      "BROADCAST_DRIVER" = "log";
      "CACHE_DRIVER" = "file";
      "CAN_POST_AUTOIMPORT" = "false";
      "CAN_POST_FILES" = "false";
      "CONNECTION_TIMEOUT" = "31.41";
      "ENABLE_MAIL_REPORT" = "false";
      "EXPECT_SECURE_URL" = "false";
      "FALLBACK_IN_DIR" = "false";
      "FIREFLY_III_ACCESS_TOKEN" = "";
      "FIREFLY_III_CLIENT_ID" = "";
      "FIREFLY_III_URL" = "http://app:8080";
      "GOCARDLESS_GET_ACCOUNT_DETAILS" = "false";
      "GOCARDLESS_GET_BALANCE_DETAILS" = "false";
      "IGNORE_DUPLICATE_ERRORS" = "false";
      "IGNORE_NOT_FOUND_TRANSACTIONS" = "false";
      "IMPORT_DIR_ALLOWLIST" = "";
      "IS_EXTERNAL" = "false";
      "JSON_CONFIGURATION_DIR" = "";
      "LOG_CHANNEL" = "stack";
      "LOG_LEVEL" = "debug";
      "LOG_RETURN_JSON" = "false";
      "MAILGUN_DOMAIN" = "";
      "MAILGUN_ENDPOINT" = "";
      "MAILGUN_SECRET" = "";
      "MAIL_DESTINATION" = "noreply@example.com";
      "MAIL_ENCRYPTION" = "null";
      "MAIL_FROM_ADDRESS" = "noreply@example.com";
      "MAIL_HOST" = "smtp.mailtrap.io";
      "MAIL_MAILER" = "";
      "MAIL_PASSWORD" = "password";
      "MAIL_PORT" = "2525";
      "MAIL_USERNAME" = "username";
      "NORDIGEN_ID" = "";
      "NORDIGEN_KEY" = "";
      "NORDIGEN_SANDBOX" = "false";
      "POSTMARK_TOKEN" = "";
      "QUEUE_CONNECTION" = "sync";
      "REDIS_CACHE_DB" = "1";
      "REDIS_DB" = "0";
      "REDIS_HOST" = "127.0.0.1";
      "REDIS_PASSWORD" = "null";
      "REDIS_PORT" = "6379";
      "RESPOND_TO_GOCARDLESS_LIMIT" = "wait";
      "SESSION_DRIVER" = "file";
      "SESSION_LIFETIME" = "120";
      "SPECTRE_APP_ID" = "";
      "SPECTRE_SECRET" = "";
      "TRACKER_SITE_ID" = "";
      "TRACKER_URL" = "";
      "TRUSTED_PROXIES" = "*";
      "TZ" = "Europe/Lisbon";
      "USE_CACHE" = "true";
      "VANITY_URL" = "https://firefly.footvaalvica.com";
      "VERIFY_TLS_SECURITY" = "true";
    };
    ports = [
      "8181:8080/tcp"
    ];
    dependsOn = [
      "firefly_iii_core"
    ];
    log-driver = "journald";
    extraOptions = [
      "--hostname=importer"
      "--network-alias=importer"
      "--network=firefly-iii-data-importer_firefly_iii"
    ];
  };
  systemd.services."docker-firefly_iii_importer" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
    ];
    requires = [
      "docker-network-firefly-iii-data-importer_firefly_iii.service"
    ];
    partOf = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
    wantedBy = [
      "docker-compose-firefly-iii-data-importer-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-firefly-iii-data-importer_firefly_iii" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f firefly-iii-data-importer_firefly_iii";
    };
    script = ''
      docker network inspect firefly-iii-data-importer_firefly_iii || docker network create firefly-iii-data-importer_firefly_iii --driver=bridge
    '';
    partOf = ["docker-compose-firefly-iii-data-importer-root.target"];
    wantedBy = ["docker-compose-firefly-iii-data-importer-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-firefly-iii_firefly_iii_db" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect firefly-iii_firefly_iii_db || docker volume create firefly-iii_firefly_iii_db
    '';
    partOf = ["docker-compose-firefly-iii-data-importer-root.target"];
    wantedBy = ["docker-compose-firefly-iii-data-importer-root.target"];
  };
  systemd.services."docker-volume-firefly-iii_firefly_iii_upload" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect firefly-iii_firefly_iii_upload || docker volume create firefly-iii_firefly_iii_upload
    '';
    partOf = ["docker-compose-firefly-iii-data-importer-root.target"];
    wantedBy = ["docker-compose-firefly-iii-data-importer-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-firefly-iii-data-importer-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };

  # Backup service
  systemd.services.firefly-db-backup = {
    description = "Backup Firefly III database";
    script = ''
      ${pkgs.docker}/bin/docker run --rm -v "firefly-iii_firefly_iii_db:/tmp" -v "/mnt/backup/firefly-iii:/backup" ubuntu tar -czvf /backup/firefly_db_$(date +%Y-%m-%d).tar /tmp
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    requires = ["docker-volume-firefly-iii_firefly_iii_db.service"];
    after = ["docker-volume-firefly-iii_firefly_iii_db.service"];
  };

  # Backup timer
  systemd.timers.firefly-db-backup = {
    description = "Run Firefly III database backup daily at 4AM";
    timerConfig = {
      OnCalendar = "04:00";
      Persistent = true;
    };
    wantedBy = ["timers.target"];
  };
}
