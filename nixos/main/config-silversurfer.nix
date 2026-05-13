{ config, pkgs, lib, lanzaboote, ... }:
{
  networking.hostName = "silversurfer"; # Define your hostname.
  environment.variables.JAVA_TOOL_OPTIONS = "-Dsun.java2d.uiScale=2.0"; # Fractional scaling support when?

  environment.systemPackages = [
    pkgs.sbctl
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

}
