{
  description = "My main NixOS flake";

  inputs = {
    # NixOS official package source
    # I got errors when this version was different than system.stateVersion in configuration.nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
