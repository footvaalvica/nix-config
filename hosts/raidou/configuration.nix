{ inputs, outputs, config, pkgs, lib, secrets, ... }:

{

  imports = [
    ./hardware-configuration.nix
    ../../profiles/default.nix
    ../../profiles/desktop.nix
    ../../profiles/nvidia.nix
  ];

  # Enable docker for AGISIT
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_24;
  nixpkgs.config.permittedInsecurePackages = [ "docker-24.0.9" ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "raidou"; # Define your hostname.

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    package = pkgs.bluez;
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mateusp = {
    isNormalUser = true;
    description = "Mateus Pinho";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Allow flatpak
  services.flatpak = {
    enable = true;
    packages = ["flathub:app/com.valvesoftware.Steam//stable"];
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    bind
    vlc
    wsmancli
    xorg.xrandr
    stdenv.cc.cc.lib
    xdg-utils
    discord
    arc-theme
    kdePackages.plasma-browser-integration
    papirus-icon-theme
    vorta
    reptyr
    pciutils
    mattermost-desktop
    spotify
    ntfs3g
    google-chrome
    remmina
    rustdesk-flutter
    gnome.gnome-tweaks
    gnome.gnome-remote-desktop
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 31555 ];
  # networking.firewall.allowedUDPPorts = [ 31555 ];
  # or disable the firewall

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
