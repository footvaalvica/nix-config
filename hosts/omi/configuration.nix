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
    ../../modules/glance.nix
    # # ../../modules/vscode-server.nix
    ../../modules/docker-containers/homeassistant.nix
    ../../modules/docker-containers/firefly-iii.nix
    ../../modules/docker-containers/overleaf.nix
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
  zramSwap.enable = true;
  networking.hostName = "omi"; # Define your hostname.
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    package = pkgs.bluez;
  };

  # Enable firefox
  programs.firefox.enable = true;

  users.users.mateusp = {
    isNormalUser = true;
    description = "Mateus Pinho";
    extraGroups = ["networkmanager" "wheel" "docker" "ydotool"];
    packages = with pkgs; [];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzd+9n5/Y34hs5Q5+mSEAW9jCLOr7zQw/AMZwW68jBB mateusp@omi"
    ];
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    gh
    wireguard-tools
    cifs-utils
    sshfs
  ];

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [80 443 3478 8080 8384 8443 22000];
    allowedUDPPorts = [443 3478 22000 21027];
  };

  power.ups = {
    enable = true;
    mode = "netserver";
    openFirewall = true; # Opens port 3493
    
    # Define the UPS device
    ups."cyberpower-ups" = {
      driver = "usbhid-ups";
      port = "auto";
      description = "VLC UPS";
      directives = [
        "maxretry = 3"
        "pollinterval = 5"
      ];
    };

    # 1. LISTEN CONFIGURATION
    # By default, NixOS might only listen on localhost (127.0.0.1).
    # We need to tell upsd to listen on all interfaces (0.0.0.0) or your specific LAN IP.
    upsd.listen = [
      { address = "0.0.0.0"; port = 3493; } 
    ];

    # 2. LOCAL MONITOR (For the PC itself)
    upsmon.monitor."cyberpower-ups" = {
      user = "upsmon";
      powerValue = 3;
      system = "cyberpower-ups@omi"; # Explicitly define system
    };

    # 3. USERS DEFINITION
    users = {
      # The local user for the PC
      upsmon = {
        passwordFile = "/home/mateusp/nix-config/hosts/omi/upsmon.pass";
        upsmon = "primary"; # "primary" is the new term for "master" in NUT 2.8+
      };
      
      # The remote user for the WD NAS
      wdnas = {
        passwordFile = "/home/mateusp/nix-config/hosts/omi/wdnas.pass"; # Create this file with a simple password
        upsmon = "secondary"; # "secondary" is the new term for "slave"
      };
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    disabledCollectors = [
      "textfile"
    ];
    openFirewall = true;
    firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };

  services.cloudflare-dyndns = {
    enable = true;
    frequency = "*:0/5";
    domains = ["omi.footvaalvica.com" "thesis.footvaalvica.com" "backend-thesis.footvaalvica.com"];
    apiTokenFile = "/home/mateusp/nix-config/hosts/omi/cloudflaretoken.txt";
  };

  # mount local drive for borg backup
  fileSystems."/mnt/borg" = {
    device = "/dev/disk/by-uuid/ae313132-7882-4c05-ae24-fd07e9ce6a00";
    fsType = "ext4";
    options = ["defaults" "x-systemd.automount" "noauto" "users" "rw"];
  };

  # Ensure borg backup directory has correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/borg 0755 root root -"
    "d /mnt/borg/musicbackup 0750 borg borg -"
  ];

  services.borgbackup = {
    repos."musicbackup" = {
      path = "/mnt/borg/musicbackup";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfjFl103Fyq71fCKpmCPsoPRNPDJqqwi7idOt+tPIxa borg@omi"
      ];
      user = "borg";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
