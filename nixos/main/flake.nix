{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable, nix-flatpak, home-manager, ... }:
    let
      system = "x86_64-linux";

      unstablePkgs = import unstable {
        system = system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix
	  home-manager.nixosModules.home-manager
	  ./home-manager.nix

          {
            nixpkgs = {
              overlays = [
                (final: prev: {
                  readest = unstablePkgs.readest;
                  zed-editor = unstablePkgs.zed-editor;
                  reaper = unstablePkgs.reaper;
		  vscode = unstablePkgs.vscode;
		  slack = unstablePkgs.slack;
                })
              ];
              config.allowUnfree = true;
            };
          }
        ];
      };
    };
}

