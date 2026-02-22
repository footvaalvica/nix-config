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
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./network-filesystems.nix
    ../../profiles/server.nix
    ../../profiles/desktop.nix
    ../../profiles/default.nix
    ../../modules/healthchecks.nix
    ../../modules/docker-containers/nextcloud.nix
    ../../modules/docker-containers/immich.nix
    ../../modules/docker-containers/watchtower.nix
    ../../modules/webserver.nix
    ../../modules/matrix-server.nix
    ../../modules/glance.nix
    ../../modules/monitoring.nix
    # # ../../modules/vscode-server.nix
    ../../modules/docker-containers/homeassistant.nix
    ../../modules/docker-containers/firefly-iii.nix
    ../../modules/docker-containers/overleaf.nix
    ../../modules/docker-containers/stremio-server.nix
  ];

  home-manager = {
    users.mateusp.imports = [../../home-manager/hosts/omi.nix];
    backupFileExtension = "backup";
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Enable zram.
  networking.hostName = "omi"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    package = pkgs.bluez;
  };

  users.users.borg = {
    isSystemUser = true;
    description = "Borg Backup User";
    group = "borg";
    home = "/var/lib/borg";
    createHome = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfjFl103Fyq71fCKpmCPsoPRNPDJqqwi7idOt+tPIxa borg@omi"
    ];
  };

  users.groups.borg = {};

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [80 443 3478 8080 8384 8443 22000];
    allowedUDPPorts = [9 443 3478 22000 21027];
  };

  # Enable Wake-on-LAN for the main ethernet interface
  networking.interfaces.eno1.wakeOnLan.enable = true;
  environment.systemPackages = with pkgs; [
    wireguard-tools
    cifs-utils
    sshfs
    inputs.agenix.packages."${system}".default
  ];

  power.ups = {
    enable = true;
    mode = "netserver";
    openFirewall = true;

    # WD NAS forces a lookup for "usbhid", so we must name it exactly that.
    ups."usbhid" = {
      driver = "usbhid-ups";
      port = "auto";
      description = "VLC UPS ";
      directives = [
        "maxretry = 3"
        "pollinterval = 5"
        "lowbatt = 50"
        "ignorelb"
      ];
    };

    upsd.listen = [
      {
        address = "0.0.0.0";
        port = 3493;
      }
    ];

    upsmon.monitor."usbhid" = {
      user = "upsmon";
      powerValue = 1;
      system = "usbhid@omi";
    };

    # 4. USERS DEFINITION
    users = {
      upsmon = {
        passwordFile = "/home/mateusp/nix-config/hosts/omi/upsmon.pass";
        upsmon = "primary";
      };
    };
  };
  

  services.cloudflare-dyndns = {
    enable = true;
    frequency = "*:0/5";
    domains = ["omi.footvaalvica.com" "thesis.footvaalvica.com" "backend-thesis.footvaalvica.com"];
    apiTokenFile = "/home/mateusp/nix-config/hosts/omi/cloudflaretoken.txt";
  };

  ##############################  
  ## THESIS STUFFS
  ##############################

  # remove the thesis domains above

  services.caddy = {
    enable = true;
    virtualHosts."thesis.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:6565
    '';
    virtualHosts."backend-thesis.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:8000
    '';
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
  };

####
########################### THESIS STUFF END ################################
####


  # # # mount local drive for borg backup
  # # fileSystems."/mnt/borg" = {
  # #   device = "/dev/disk/by-uuid/ae313132-7882-4c05-ae24-fd07e9ce6a00";
  # #   fsType = "ext4";
  # #   options = ["defaults" "x-systemd.automount" "noauto" "users" "rw"];
  # # };

  # # # Ensure borg backup directory has correct ownership
  # # systemd.tmpfiles.rules = [
  # #   "d /mnt/borg 0755 root root -"
  # #   "d /mnt/borg/musicbackup 0750 borg borg -"
  # # ];

  # # services.borgbackup = {
  # #   repos."musicbackup" = {
  # #     path = "/mnt/borg/musicbackup";
  # #     authorizedKeys = [
  # #       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfjFl103Fyq71fCKpmCPsoPRNPDJqqwi7idOt+tPIxa borg@omi"
  # #     ];
  # #     user = "borg";
  # #   };
  # # };

  # # services.dnsmasq.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
