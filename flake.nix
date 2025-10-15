{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # Use `github:nix-darwin/nix-darwin/nix-darwin-25.05` to use Nixpkgs 25.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Home manager
    home-manager-2505.url = "github:nix-community/home-manager/release-25.05";
    home-manager-2505.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Website
    website = {
      url = "github:footvaalvica/footvaalvica.com/gh-pages";
      flake = false;
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    tjsousa-cask = {
      url = "github:tjsousa/homebrew-cask";
      flake = false;
    };

    deploy-rs.url = "github:serokell/deploy-rs";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    home-manager-2505,
    nix-darwin,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    nur,
    website,
    deploy-rs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    # TODO this line below should be used, the current solution sucks
    # # nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./home-manager/modules;

    nixosConfigurations = {
      omi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs secrets;};
        modules = [
          nur.modules.nixos.default
          home-manager-2505.nixosModules.home-manager
          # Import the previous configuration.nix we used,
          # so the old configuration file still takes effect
          ./hosts/omi/configuration.nix
        ];
      };
    };

    deploy = {
      nodes = {
        omi = {
          hostname = "omi.footvaalvica.com";
          profiles.system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.omi;
            remoteBuild = true;
          };
        };
      };
    };

    darwinConfigurations."sonic" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = {inherit inputs outputs secrets homebrew-cask homebrew-core;};
      modules = [
        ./hosts/sonic/sonic.nix
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager
      ];
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "mateusp@raidou" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/hosts/raidou.nix
        ];
      };
      "deck@kiryu" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs self;};
        modules = [
          ./home-manager/hosts/kiryu.nix
        ];
      };
      "mateusp@joker" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home-manager/hosts/joker.nix
        ];
      };
    };
  };
}
