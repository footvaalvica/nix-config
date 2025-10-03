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
  imports = [
    ../../home-manager/hosts/sonic.nix  
  ];

  system.stateVersion = 6;
  system.primaryUser = "mateusp";

  programs = {
    fish.enable = true;  # default shell on catalina
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
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };  
  
  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
     "discord"
     "firefox"
     "visual-studio-code"
    ];  
 };

  nix.enable = false;
}
