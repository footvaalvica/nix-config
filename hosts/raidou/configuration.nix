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
    ./hardware-configuration.nix
    ../../profiles/default.nix
    ../../profiles/desktop.nix
    ../../profiles/nvidia.nix
  ];

  # Enable docker for AGISIT
  virtualisation.docker.enable = true;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking = {
    hostName = "raidou"; # Define your hostname.    
    firewall.enable = lib.mkForce false;
    interfaces.enp4s0 = {
      ipv4 = {
        addresses = [{
          address = "193.136.164.196";
          prefixLength = 27;
        }];
      };
      ipv6 = {
        addresses = [{
          address = "2001:690:2100:82::196";
          prefixLength = 64;
        }];
      };
    };
    defaultGateway = "193.136.164.222";
    nameservers = [ "193.136.164.1" "193.136.164.2" ];
  };  

  security.pam.sshAgentAuth.enable = true;
  programs.ssh.startAgent = true;

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
    extraGroups = ["networkmanager" "wheel" "docker" "libvirtd"];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  # Enable virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  programs = {
    java.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  ########################### JAPANESE 
 
  fonts = {
    fonts = with pkgs; [
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
      corefonts
      vistafonts
    ];
    fontconfig.defaultFonts = {
      serif = [ "Source Han Serif" ];
      sansSerif = [ "Source Han Sans" ];
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-configtool
      ];
      waylandFrontend = true;
      # TODO quickPhrase
    };
  };

  environment.sessionVariables = rec {
    NIX_PROFILES =
        "${lib.concatStringsSep " " (lib.reverseList config.environment.profiles)}";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };
  environment.variables.QT_PLUGIN_PATH = [ "${pkgs.fcitx5-with-addons}/${pkgs.qt6.qtbase.qtPluginPrefix}" ];

  ########################### END JAPANESE
  programs.firefox.enable = true;	
  
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    bind
    pandoc
    vlc
    wsmancli
    anki-bin
    onlyoffice-bin
    xorg.xrandr
    stdenv.cc.cc.lib
    xdg-utils
    arc-theme
    kdePackages.plasma-browser-integration
    papirus-icon-theme
    vorta
    reptyr
    texlive.combined.scheme-full
    pciutils
    mattermost-desktop
    dracula-theme
    spotify
    ntfs3g
    zoom-us
    google-chrome
    nerdfonts
    remmina
    discord
    libreoffice-qt6-fresh
    hunspell
    hunspellDicts.pt_PT
    hunspellDicts.en_US
    rustdesk-flutter
    exo
    obsidian
    code-cursor
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 31555 ];
  # networking.firewall.allowedUDPPorts = [ 31555 ];
  # or disable the firewall

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
