# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  secrets,
  ...
}: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../profiles/server.nix
      ../../profiles/desktop.nix
      ../../profiles/default.nix
      ../../modules/docker-containers/homeassistant.nix
    ];

  home-manager = {
    users.mateusp.imports = [../../home-manager/hosts/omi.nix];
    backupFileExtension = "backup";
  };

  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/backup";
    fsType = "btrfs";
    options = [ 
      "compress=zstd"   # Automatically compresses data to save space
      "nosuid"          # Security: prevents set-user-identifier bits from working
      "nodev"           # Security: prevents interpreting character or block special devices
      "nofail"          # CRITICAL: allows the PC to boot even if the drive is unplugged
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
    ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/backup omi(rw,nohide,insecure,no_subtree_check,no_root_squash)
    '';
  };

  services.borgbackup.repos."omi-backups" = {
    path = "/mnt/backup/borg-repo";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH47ttBWUSRZ9W/m07YAVjxtZfBjSqTOJXOoQx16zXuV root@nextcloud-aio-borgbackup" # You will get this key from the Omi UI
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tojo"; # Define your hostname.
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    package = pkgs.bluez;
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}
