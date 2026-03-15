{
  pkgs,
  lib,
  secrets,
  ...
}: {
  # mount network drive as local drive for backups, and cache it as well
  services.cachefilesd = {
    enable = true;
    extraConfig = ''
      brun 30%
      bcull 27%
      bstop 23%
    '';
  };

  fileSystems."/mnt/nextcloud" = {
    device = "//192.168.1.250/Mateus/NextCloud";
    fsType = "cifs";
    options = ["username=${secrets.smb.username}" "password=${secrets.smb.password}" "fsc" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "rw" "mfsymlinks" "seal" "uid=33" "gid=0" "file_mode=0777" "dir_mode=0777"];
  };

  fileSystems."/mnt/immich" = {
    device = "//192.168.1.250/Mateus/Immich";
    fsType = "cifs";
    options = ["username=${secrets.smb.username}" "password=${secrets.smb.password}" "fsc" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "rw" "mfsymlinks" "seal" "uid=1000" "gid=100" "file_mode=0777" "dir_mode=0777"];
  };

  fileSystems."/mnt/borg" = {
    device = "//192.168.1.250/Mateus/Backup/";
    fsType = "cifs";
    options = ["username=${secrets.smb.username}" "password=${secrets.smb.password}" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "rw" "mfsymlinks" "seal" "uid=1000" "gid=100" "file_mode=0777" "dir_mode=0777"];
  };

  fileSystems."/mnt/backup" = {
    device = "100.93.108.50:/mnt/backup/OtherServicesBackup";
    fsType = "nfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "rw"
      "soft" # Prevents omi from freezing if tojo goes offline
    ];
  };

  # Backups in tojo
  fileSystems."/mnt/immich_backup" = {
    device = "100.93.108.50:/mnt/backup/ImmichBackup";
    fsType = "nfs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "rw"
      "soft" # Prevents omi from freezing if tojo goes offline
    ];
  };
}
