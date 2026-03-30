{ config, pkgs, lib, home-manager, ... }:
{
  home-manager.users.luser = { pkgs, ... }: {
    imports = [ ./dconf.nix ];
    home.packages = [ pkgs.ncdu ];
    programs.bash.enable = true;

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "25.11";
  };
}
