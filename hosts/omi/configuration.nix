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
    ./healthchecks.nix
    ./update-duck-dns.nix
    ../../profiles/syncthing-server.nix
    ../../profiles/default.nix
    ../../profiles/desktop.nix
    ../../modules/docker-containers/mealie.nix
    ../../modules/docker-containers/nextcloud.nix
    ../../modules/docker-containers/immich.nix
    ../../modules/docker-containers/watchtower.nix
    ../../modules/docker-containers/sillytavern.nix
    ../../modules/docker-containers/authelia.nix
    ../../modules/docker-containers/memos.nix
    ../../modules/webserver.nix
    ../../modules/ollama.nix
    ../../modules/docker-containers/firefly-iii.nix
    ../../modules/docker-containers/overleaf.nix
  ];

  # TEMPORARY THESIS STUFFS
  services.caddy = {
    enable = true;
    virtualHosts."thesis.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:6565
    '';
    virtualHosts."backend-thesis.footvaalvica.com".extraConfig = ''
      reverse_proxy localhost:8000
    '';
  };
  
  systemd.services.fsrs-optimizer = {
    description = "FSRS Parameter Optimizer Service";
    script = ''
      echo "Starting FSRS optimization script scheduled by systemd timer..."
      ${config.languages.python.package}/bin/python backend/scripts/optimize_fsrs.py --scope global
      echo "FSRS optimization script finished."
    '';
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = config.devenv.root;
      # Log to journal on failure
      ExecStartPost = ''
        -/bin/sh -c 'echo "FSRS Optimizer service completed successfully."'
      '';
    };
    # Add OnFailure to log a specific message or trigger a script
    # For simplicity, we'll log a message. A more complex action could be a script.
    onFailure = [ "systemd-cat -p err echo FSRS Optimizer Service FAILED" ];
    wantedBy = [ "default.target" ];
    partOf = [ "default.target" ];
  };

  systemd.timers.fsrs-optimizer-weekly = {
    description = "Weekly FSRS Parameter Optimizer Timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 03:00:00";
      Unit = "fsrs-optimizer.service";
      Persistent = true;
    };
    partOf = [ "default.target" ];
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gh
    git
    wireguard-tools
    cifs-utils
    sshfs
  ];

  # Firewall
  networking.firewall = {
    allowedTCPPorts = [80 443 3478 8080 8384 8443 22000];
    allowedUDPPorts = [443 3478 22000 21027];
  };

  # Fail2Ban
  services.fail2ban.enable = true;

  programs.ydotool.enable = true;
  systemd.services.press-unknown = {
    description = "Press UNKNOWN key every minute";
    after = ["ydotoold.service"]; # Ensure ydotoold is running
    wants = ["ydotoold.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -lc '${pkgs.ydotool}/bin/ydotool key 190:1 190:0'";
      User = "mateusp"; # Change this if needed
    };
  };

  systemd.timers.press-unknown = {
    description = "Timer for UNKNOWN keypress";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:0/1"; # Every minute
      Persistent = true;
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
    domains = [ "omi.footvaalvica.com" "thesis.footvaalvica.com" "backend-thesis.footvaalvica.com" ];
    apiTokenFile = "/home/mateusp/nix-config/hosts/omi/cloudflaretoken.txt";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
