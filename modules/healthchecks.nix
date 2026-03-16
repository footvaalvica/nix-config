{
  pkgs,
  lib,
  config,
  secrets,
  ...
}: let
  # Resolve host-specific healthchecks URL from secrets.healthchecks.<hostname>.url
  # and fail during evaluation if the host key is missing.
  healthchecksUrl = lib.getAttrFromPath ["healthchecks" config.networking.hostName "url"] secrets;
in {

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
      curl ${healthchecksUrl}
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "mateusp";
    };
  };
}
