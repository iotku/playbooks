{ config, pkgs, ... }:
{
  networking.hostName = "blackbox"; # Define your hostname.
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 24800 ]; # open port for deskflow server
  # Firewall ports for KDEConnect/GSconnect
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 1716;
      to = 1764;
    }
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 1716;
      to = 1764;
    }
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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

  # Disable Sleep
  #  systemd.sleep.extraConfig = ''
  #  AllowSuspend=no
  #  AllowHibernation=no
  #  AllowHybridSleep=no
  #  AllowSuspendThenHibernate=no
  #  '';


}
