{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  secrets,
  homebrew-core,
  homebrew-cask,
  ...
}: {
  home-manager = {
    users.mateusp.imports = [../../home-manager/hosts/sonic.nix];
    backupFileExtension = "backup";
  };

  networking.hostName = "sonic";

  users.knownUsers = ["mateusp"];
  users.users.mateusp = {
    home = "/Users/mateusp";
    shell = pkgs.fish;
    uid = 501;
  };

  services.tailscale.enable = true;

  programs = {
    fish.enable = true; # default shell on catalina
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "mateusp";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "tjsousa/homebrew-cask" = inputs.tjsousa-cask;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "mas"
      "openssl@3"
    ];
    casks = [
      "discord"
      "firefox"
      "visual-studio-code"
      "google-chrome"
      "altserver"
      "obsidian"
      "transmission"
      "reaper"
      "grandperspective"
      "font-sf-mono-nerd-font-ligaturized"
      "moonlight"
      "utm"
      "vorta"
      "betterdisplay"
      "tjsousa/cask/altgr-weur"
      "anki"
      "steam"
      "stremio"
      "zoom"
      "lookaway"
      "musicbrainz-picard"
    ];
    global.autoUpdate = false;
    masApps = {
      GarageBand = 682658836;
      NordVPN = 905953485;
      Mattermost = 1614666244;
      Wireguard = 1451685025;
      MicrosoftApp = 1295203466; # Microsoft Remote Desktop
      MicrosoftWord = 462054704;
      MicrosoftExcel = 462058435;
      MicrosoftPowerpoint = 462062816;
      Unarchiver = 425424353;
    };
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };

  nix.enable = false;

  system = {
    stateVersion = 6;
    primaryUser = "mateusp";
    defaults = {
      NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
      dock.show-recents = false;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      NSGlobalDomain."com.apple.swipescrolldirection" = false;
      iCal."first day of week" = "Monday";
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      controlcenter.BatteryShowPercentage = true;
      finder.AppleShowAllExtensions = true;
    };
  };
}
