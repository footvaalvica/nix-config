{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: {
  # Update DUCKDNS
  systemd.timers."update-duckdns" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "update-duckdns.service";
    };
  };

  systemd.services."update-duckdns" = {
    script = ''
      source ${config.system.build.setEnvironment}
      echo url="${secrets.duckdns.url}" | curl -k -K -
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "mateusp";
    };
  };
}
