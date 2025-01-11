{
  description = "My main NixOS flake";

  inputs = {
    # NixOS official package source
    # I got errors when this version was different than system.stateVersion in configuration.nix
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyinit = {
      url = "github:corinfinite/pyinit";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llmify = {
      url = "github:corinfinite/llmify";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      pyinit,
      llmify,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix

          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.backupFileExtension = "bak";

            home-manager.users.corinne = import ./home.nix;

            home-manager.extraSpecialArgs = {
              inherit inputs;
            };
          }
        ];
      };
    };
}
