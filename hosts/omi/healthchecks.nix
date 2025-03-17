{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: {
  # Update DUCKDNs
  systemd.timers."ping-healthchecks" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "2m";
      Unit = "ping-healthchecks.service";
    };
  };

  systemd.services."ping-healthchecks" = {
    script = ''
      source ${config.system.build.setEnvironment}
      curl ${secrets.healthchecks.url}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "mateusp";
    };
  };
}
