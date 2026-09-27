{activationPackage}: {
  systemd.services.home-manager-mateusp = {
    description = "Home Manager configuration for mateusp";
    wantedBy = ["multi-user.target"];
    after = ["nix-daemon.service"];
    wants = ["nix-daemon.service"];
    restartTriggers = [activationPackage];

    serviceConfig = {
      Type = "oneshot";
      User = "mateusp";
      RemainAfterExit = true;
      Environment = [
        "HOME=/home/mateusp"
        "USER=mateusp"
        "LOGNAME=mateusp"
      ];
      ExecStart = "${activationPackage}/activate --driver-version 1";
    };
  };
}
