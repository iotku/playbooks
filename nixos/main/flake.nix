{
  inputs = {
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    small.url = "github:NixOS/nixpkgs/nixos-26.05-small";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      #url = "github:nix-community/home-manager/release-25.11";
      url = "github:nix-community/home-manager/release-26.05";
      #url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      unstable,
      small,
      nix-flatpak,
      sops-nix,
      home-manager,
      plasma-manager,
      lanzaboote,
      ...
    }:
    let
      system = "x86_64-linux";

      unstablePkgs = import unstable {
        system = system;
        config.allowUnfree = true;
      };

      smallPkgs = import small {
        system = system;
        config.allowUnfree = true;
      };

      secureboot = [
        lanzaboote.nixosModules.lanzaboote
        {
          boot.loader.systemd-boot.enable = nixpkgs.lib.mkForce false;

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
          };
        }
      ];

      sopsModules = [
        sops-nix.nixosModules.sops
        {
          sops.defaultSopsFile = ./secrets/secrets.yaml;
          sops.defaultSopsFormat = "yaml";
          sops.age.keyFile = "/home/luser/.config/sops/age/keys.txt";
          sops.secrets."wireguard_yeet/privkey" = { };
          sops.secrets."wireguard_yeet/pubkey" = { };
          sops.secrets."wireguard_yeet/endpoint" = { };
        }
      ];

      gnome = [ ./gnome.nix ];
      plasma = [ ./plasma.nix ];

      commonModules = [
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
                osu-lazer-bin = smallPkgs.osu-lazer-bin;
                neovim = unstablePkgs.neovim;
		opentabletdriver = unstablePkgs.opentabletdriver;
              })
            ];
            config.allowUnfree = true;
          };
        }
      ];

    in
    {
      nixosConfigurations = {
        blackbox = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = plasma ++ secureboot ++ sopsModules ++ commonModules ++ [ ./config-blackbox.nix ];
        };

        silversurfer = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = gnome ++ secureboot ++ commonModules ++ [ ./config-silversurfer.nix ];
        };
        vfio = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = secureboot ++ [
            (import ./config-vfio.nix { winVmName = "win11-ltsc-gpu"; })
          ];
        };

        vfio2 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = secureboot ++ [
            (import ./config-vfio.nix { winVmName = "win11-ltsc-gpu-vn"; })
          ];
        };
      };
    };
}
