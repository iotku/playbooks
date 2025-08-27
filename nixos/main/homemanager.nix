{ config, pkgs, lib, ... }:

let
  home-manager = builtins.fetchTarball {
  	url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
	sha256 = "sha256:1wl2plp37a8qw26h6cj3ah6rq8bd3awl2938h5cm9b8ncxn4s1k8";
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
