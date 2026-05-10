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

  # Copy monitor configurationg from `luser`, ideally we would use a varible for the user.
  systemd.services.copyGdmMonitorsXml = {
    description = "Copy monitors.xml to GDM config";
    after = [
      "network.target"
      "systemd-user-sessions.service"
      "display-manager.service"
    ];

    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /run/gdm/.config && [ \"/home/luser/.config/monitors.xml\" -ef \"/run/gdm/.config/monitors.xml\" ] || cp /home/luser/.config/monitors.xml /run/gdm/.config/monitors.xml && chown gdm:gdm /run/gdm/.config/monitors.xml'";
      Type = "oneshot";
    };

    wantedBy = [ "multi-user.target" ];
  };

}
