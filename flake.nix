{
  description = "NixOS and Home manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosConfigurations = {
        "homelab@k3s-cluster" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ 
            disko.nixosModules.disko 
            ./hosts/k3s-cluster
          ];
        };
      };

      homeConfigurations = {
        "james@wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home-manager/james/wsl.nix ];
          extraSpecialArgs = { inherit self; };
        };

        "james@mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [ ./home-manager/james/mac.nix ];
          extraSpecialArgs = { inherit self; };
        };

        "rajan@wsl" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./home-manager/rajan/wsl.nix ];
          extraSpecialArgs = { inherit self; };
        };
      };
    };
}