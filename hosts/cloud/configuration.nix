{
  inputs,
  config,
  pkgs,
  ...
}:
{
  home-manager = {
    users.mpinho.imports = [ ../../home-manager/hosts/cloud.nix ];
    backupFileExtension = "backup";
  };

  # # networking.hostName = "sonic";

  users.knownUsers = [ "mpinho" ];
  users.users.mpinho = {
    home = "/Users/mpinho";
    shell = pkgs.fish;
    uid = 501;
  };

  programs = {
    fish.enable = true; # default shell on catalina
  };

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "mpinho";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "tjsousa/homebrew-cask" = inputs.tjsousa-cask;
      "otuerk/homebrew-sidebar" = inputs.oteurk-sidebar;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;

    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
      "zed"
      "dockdoor"
      "obsidian"
      "font-sf-mono-nerd-font-ligaturized"
      "betterdisplay"
      "tjsousa/cask/altgr-weur"
      "lookaway"
      "openchamber"
      "mos"
    ];
    global.autoUpdate = false;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };

  nix.enable = false;

  system = {
    stateVersion = 6;
    primaryUser = "mpinho";
    defaults = {
      NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
      dock.show-recents = false;
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      iCal."first day of week" = "Monday";
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
      controlcenter.BatteryShowPercentage = true;
      finder.AppleShowAllExtensions = true;
    };
  };
}
