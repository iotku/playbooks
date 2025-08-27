{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
  };

  outputs = { self, nixpkgs, unstable, nix-flatpak }: 
    let
      system = "x86_64-linux";

      # Configure unstable with allowUnfree
      unstablePkgs = import unstable {
        system = system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations.nixit = nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix

          {
            nixpkgs = {
              overlays = [
                (final: prev: {
                  readest = unstablePkgs.readest;
                  zed-editor = unstablePkgs.zed-editor;
                  reaper = unstablePkgs.reaper; 
		  vscode = unstablePkgs.vscode;
                })
              ];
              config.allowUnfree = true;
            };
          }
        ];
      };
    };
}
