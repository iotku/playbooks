{ config, pkgs, ... }:
{

  imports = [
    ./containers/securebox.nix
  ];

  # Override firmware until https://gitlab.freedesktop.org/drm/amd/-/work_items/5615 is fixed in nixpkgs version

  hardware.firmware = [
    (pkgs.linux-firmware.overrideAttrs (oldAttrs: {
      src = pkgs.fetchgit {
        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
        rev = "b2722d241309a1872446c1d00c2e812bad055f89";
        sha256 = "sha256-nSoJhgI4hAxtNmnj5M6ticzuBSt9uNAYcmc1VR/yXxE=";
      };
    }))
  ];

  nixpkgs.config.rocmSupport = true;

  environment.systemPackages = with pkgs; [
    blender-rocm
    rocmPackages.clr
    rocmPackages.hipcc
    rocmPackages.rocminfo
    rocmPackages.amdsmi
    rocmPackages.hiprt
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
  systemd.sleep.settings = {
    Sleep = {
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspend = "no";
      AllowSuspendThenHibernate = "no";
    };
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
