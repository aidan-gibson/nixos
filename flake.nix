{
  description = "My NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      allSystems = nixpkgs.lib.systems.flakeExposed;
      forAllSystems = nixpkgs.lib.genAttrs allSystems;
    in {
      nixosConfigurations = {
        mySystemName = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
          ];
          specialArgs = { inherit inputs; };
        };
      };

      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}