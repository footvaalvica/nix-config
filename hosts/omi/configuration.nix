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
    ../../modules/docker-containers/firefly-iii.nix
    ../../modules/docker-containers/overleaf.nix
  ];

  home-manager = {
    users.mateusp.imports = [../../home-manager/hosts/omi.nix];
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Enable zram.
  zramSwap.enable = true;
  networking.hostName = "omi"; # Define your hostname.

  # Enable firefox
  programs.firefox.enable = true;

  users.users.mateusp = {
    isNormalUser = true;
    description = "Mateus Pinho";
    extraGroups = ["networkmanager" "wheel" "docker" "ydotool"];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  users.users.borg = {
    isSystemUser = true;
    description = "Borg Backup User";
    group = "borg";
    home = "/var/lib/borg";
    createHome = true;
    shell = pkgs.bash;
  };

  users.groups.borg = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    unstable.claude-code
    wireguard-tools
    cifs-utils
    sshfs
  ];

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [80 443 3478 8080 8384 8443 22000];
    allowedUDPPorts = [443 3478 22000 21027];
  };

  # # programs.ydotool.enable = true;
  # # systemd.services.press-unknown = {
  # #   description = "Press UNKNOWN key every minute";
  # #   after = ["ydotoold.service"]; # Ensure ydotoold is running
  # #   wants = ["ydotoold.service"];
  # #   serviceConfig = {
  # #     Type = "oneshot";
  # #     ExecStart = "/bin/sh -lc '${pkgs.ydotool}/bin/ydotool key 190:1 190:0'";
  # #     User = "mateusp"; # Change this if needed
  # #   };
  # # };

  # # systemd.timers.press-unknown = {
  # #   description = "Timer for UNKNOWN keypress";
  # #   wantedBy = ["timers.target"];
  # #   timerConfig = {
  # #     OnCalendar = "*:0/1"; # Every minute
  # #     Persistent = true;
  # #   };
  # # };

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
