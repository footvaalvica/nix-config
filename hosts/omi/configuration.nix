# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
 
{ inputs, outputs, config, pkgs, lib, secrets, ... }:

{
  imports =[ # Include the results of the hardware scan.
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
  ];
   
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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wireguard-tools
    cifs-utils 
    sshfs
  ];
  
  # Firewall
  networking.firewall = {
    allowedTCPPorts = [ 80 443 3478 8080 8384 8443 22000 ];
    allowedUDPPorts = [ 443 3478 22000 21027 ];
  };

  # Fail2Ban
  services.fail2ban.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}

