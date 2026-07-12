{ pkgs, ... }:
{
  home.stateVersion = "25.11";

  programs.plasma = {
    enable = true;

    #
    # Some high-level settings:
    #
    workspace = {
      clickItemTo = "open"; # If you liked the click-to-open default from plasma 5
      lookAndFeel = "org.kde.breezedark.desktop";
           cursor = {
             #theme = "Bibata-Modern-Ice";
            size = 24;
          };
      #     iconTheme = "Papirus-Dark";
      #     wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };

    hotkeys.commands = {
      launch-ghostty = {
        name = "Launch Ghostty";
        key = "Meta+Return";
        command = "ghostty";
      };
    };

    shortcuts = {
      kwin = {
        "Window Fullscreen" = "Meta+F";
      };
    };

    fonts = {
 #     general = {
 #       family = "JetBrains Mono";
 #       pointSize = 10;
 #     };
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        height = 30;
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General = {
                icon = "nix-snowflake-white";
                alphaSort = true;
              };
            };
          }
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default with widget-specific options.
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:com.mitchellh.ghostty.desktop"
                "applications:org.mozilla.firefox.desktop"
                "applications:org.telegram.desktop.desktop"
                "applications:signal.desktop"
		"applications:steam.desktop"
              ];
            };
          }
          # Or you can do it manually, for example:
          # widget will add them with the default configuration.
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              # We explicitly show bluetooth and battery
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
              ];
              hidden = [
                "org.kde.plasma.networkmanagement"
              ];
            };
          }

          {
            digitalClock = {
              calendar.firstDayOfWeek = "sunday";
              time.format = "24h";
            };
          }
        ];
        hiding = "none";
      }
    ];

    window-rules = [ ];

    kwin = {
      edgeBarrier = 0; # Disables the edge-barriers introduced in plasma 6.1
      cornerBarrier = false;
    };

    kscreenlocker = {
      lockOnResume = true;
      timeout = 10;
    };

    #
    # Some mid-level settings:
    #
    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+Ctrl+Alt+L"
        ];
      };

    };
  };
}
