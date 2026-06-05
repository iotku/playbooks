{ config, pkgs, ... }:
{

  imports = [
    ./containers/securebox.nix
  ];
  networking.hostName = "blackbox"; # Define your hostname.
  powerManagement.cpuFreqGovernor = "performance";
  nix.gc = {
    automatic = true;
    dates = "weekly"; # Runs once a week; can also be "daily" or a specific time like "03:15"
    options = "--delete-older-than 14d"; # Deletes packages and profiles older than 30 days
  };

  system.autoUpgrade = {
    enable = true;
    operation = "boot";
    flags = [ "--print-build-logs" ];
    flake = "path:///etc/nixos";
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 24800 ]; # open port for deskflow server
  programs.kdeconnect.enable = true; # Note that it will open the TCP and UDP port from 1714 to 1764 
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
}
