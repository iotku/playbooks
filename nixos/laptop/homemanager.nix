{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball {
  	url = "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";
	sha256 = "sha256:1qr63a2izlp840ax3v31avji99yprw3rap2m8f1snfkxfnsh8syh";
	};
in
{
  imports =
    [
      (import "${home-manager}/nixos")
    ];

  users.users.luser.isNormalUser = true;
  home-manager.users.luser = { pkgs, ... }: {
    imports = [ ./dconf.nix ];
    home.packages = [ pkgs.ncdu ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.05";
  };
}
