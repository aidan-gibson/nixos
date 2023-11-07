{
  description = "My NixOS config";

  inputs = {
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*.tar.gz";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, fh, ... } @ inputs:
    let
      allSystems = nixpkgs.lib.systems.flakeExposed;
      forAllSystems = nixpkgs.lib.genAttrs allSystems;
    in {
      nixosConfigurations = {
        trix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            ({ pkgs, ... }: {
              environment.systemPackages = [ fh.packages.x86_64-linux.default ];
            })
            # ... any additional modules ...
          ];
          specialArgs = { inherit inputs; };
        };
      };

      formatter =
        forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
