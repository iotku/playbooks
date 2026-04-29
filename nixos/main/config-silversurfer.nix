{ config, pkgs, ... }:
{
  networking.hostName = "silversurfer"; # Define your hostname.
  environment.variables.JAVA_TOOL_OPTIONS = "-Dsun.java2d.uiScale=2.0"; # Fractional scaling support when?
}
