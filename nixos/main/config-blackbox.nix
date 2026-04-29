{ config, pkgs, ... }:
{
  networking.hostName = "blackbox"; # Define your hostname.
  # Disable Sleep
  #  systemd.sleep.extraConfig = ''
  #  AllowSuspend=no
  #  AllowHibernation=no
  #  AllowHybridSleep=no
  #  AllowSuspendThenHibernate=no
  #  '';

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/alsa.conf" ''
      monitor.alsa.rules = [
        {
          matches = [
            {
              device.name = "~alsa_card.*"
            }
          ]
          actions = {
            update-props = {
              # Device settings
              api.alsa.use-acp = true
            }
          }
        }
        {
          matches = [
            {
              node.name = "~alsa_input..*"
            }
            {
              node.name = "~alsa_output.*"
            }
          ]
          actions = {
          # Node settings
            update-props = {
              session.suspend-timeout-seconds = 0
            }
          }
        }
      ]
    '')
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
