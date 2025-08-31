{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable, nix-flatpak, lanzaboote, ... }:
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
          lanzaboote.nixosModules.lanzaboote

          {
            nixpkgs = {
              overlays = [
                (final: prev: {
                  readest = unstablePkgs.readest;
                  zed-editor = unstablePkgs.zed-editor;
                  reaper = unstablePkgs.reaper;
		  vscode = unstablePkgs.vscode;
		  android-studio = unstablePkgs.android-studio;
		  jetbrains.idea-community = unstablePkgs.jetbrains.idea-community;
		  jetbrains.pycharm-community = unstablePkgs.jetbrains.pycharm-community;
                })
              ];
              config.allowUnfree = true;
            };
          }

          ({ pkgs, lib, ... }: {
            environment.systemPackages = [
              pkgs.sbctl
            ];

            boot.loader.systemd-boot.enable = lib.mkForce false;

            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          })
        ];
      };
    };
}

