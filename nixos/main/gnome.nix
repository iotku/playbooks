{ config, pkgs, ... }:
{
  # Gnome stuff
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-developer-tools.enable = true;
  services.gnome.games.enable = false; # No fun allowed
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
  '';
  
  environment.systemPackages = with pkgs; [
  # Gnome
    gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.kimpanel
    gnomeExtensions.caffeine
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.tiling-assistant
    dconf2nix
    gnome-solanum
  ];

}
