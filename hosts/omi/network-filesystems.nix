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
      brun 20%
      bcull 17%
      bstop 13%
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

  # mount network drive as syncthing drive
  fileSystems."/mnt/syncthing" = {
    device = "//192.168.1.250/Mateus/Syncthing/";
    fsType = "cifs";
    options = ["username=${secrets.smb.username}" "password=${secrets.smb.password}" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "rw" "mfsymlinks" "seal" "uid=1000" "gid=100" "file_mode=0777" "dir_mode=0777"];
  };

  fileSystems."/mnt/backup" = {
    device = "//192.168.1.250/Mateus/Backup/";
    fsType = "cifs";
    options = ["username=${secrets.smb.username}" "password=${secrets.smb.password}" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=60" "x-systemd.device-timeout=5s" "x-systemd.mount-timeout=5s" "rw" "mfsymlinks" "seal" "uid=1000" "gid=100" "file_mode=0777" "dir_mode=0777"];
  };

  # Backups in StorageBox
  fileSystems."/mnt/nextcloud_backup" = {
    device = "//${secrets.hetzner.username}.your-storagebox.de/backup/NextCloudBackup";
    fsType = "cifs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "rw"
      "username=${secrets.hetzner.username}"
      "password=${secrets.hetzner.password}"
      "uid=33"
      "gid=0"
      "file_mode=0660"
      "dir_mode=0770"
    ];
  };

  # Backups in StorageBox
  fileSystems."/mnt/immich_backup" = {
    device = "//${secrets.hetzner.username}.your-storagebox.de/backup/ImmichBackup";
    fsType = "cifs";
    options = [
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "rw"
      "username=${secrets.hetzner.username}"
      "password=${secrets.hetzner.password}"
      "uid=1000"
      "gid=100"
      "file_mode=0660"
      "dir_mode=0770"
    ];
  };
}
