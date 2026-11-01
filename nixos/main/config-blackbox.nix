{
  config,
  pkgs,
  ...
}:
{

  imports = [
    ./containers/securebox.nix
  ];

  # Override firmware until https://gitlab.freedesktop.org/drm/amd/-/work_items/5615 is fixed in nixpkgs version

  #  hardware.firmware = [
  #    (pkgs.linux-firmware.overrideAttrs (oldAttrs: {
  #      src = pkgs.fetchgit {
  #        url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
  #        rev = "b2722d241309a1872446c1d00c2e812bad055f89";
  #        sha256 = "sha256-nSoJhgI4hAxtNmnj5M6ticzuBSt9uNAYcmc1VR/yXxE=";
  #      };
  #    }))
  #  ];

  boot.kernelParams = [
    #   "preempt=full"
  ];

  nixpkgs.config.rocmSupport = true;

  environment.systemPackages = with pkgs; [
    blender-rocm
    rocmPackages.clr
    rocmPackages.hipcc
    rocmPackages.rocminfo
    rocmPackages.amdsmi
    rocmPackages.hiprt
    zluda
    (pkgs.wrapOBS { plugins = [ pkgs.obs-studio-plugins.obs-vaapi ]; })
  ];
  networking.hostName = "blackbox"; # Define your hostname.
  powerManagement.cpuFreqGovernor = "balanced";
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

  # systemd.sleep.settings = {
  #   Sleep = {
  #      AllowHibernation = "no";
  #      AllowHybridSleep = "no";
  #      AllowSuspend = "no";
  #      AllowSuspendThenHibernate = "no";
  #    };
  #  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    24800
    53317
  ]; # open port for deskflow server and localsend
  programs.kdeconnect.enable = true; # Note that it will open the TCP and UDP port from 1714 to 1764

  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    "context.properties" = {
      "default.clock.rate" = 48000;
      "default.clock.quantum" = 128;
      "default.clock.min-quantum" = 128;
      "default.clock.max-quantum" = 128;
    };
  };

  # Prevent alsa idle (noisy open audio on motherboard)
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
