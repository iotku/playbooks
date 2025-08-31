# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/a11y/applications" = {
      screen-reader-enabled = false;
    };


    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/amber-l.jxl";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/amber-d.jxl";
      primary-color = "#ff7800";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-size = 24;
      enable-animations = true;
      scaling-factor = mkUint32 1;
      toolbar-style = "text";
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/amber-l.jxl";
      primary-color = "#ff7800";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
    };

    "org/gnome/gnome-system-monitor" = {
      cpu-stacked-area-chart = true;
      current-tab = "resources";
      graph-data-points = 200;
      graph-update-interval = 50;
      maximized = false;
      resources-mem-expanded = true;
      resources-net-expanded = false;
      show-dependencies = false;
      show-whose-processes = "user";
      window-height = 720;
      window-width = 800;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      col-26-visible = false;
      col-26-width = 0;
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
      initial-size-file-chooser = mkTuple [ 890 550 ];
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      toggle-fullscreen = [ "<Super>f" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>Return";
      command = "ghostty";
      name = "Open Ghostty";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell" = {
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "kimpanel@kde.org" "appindicatorsupport@rgcjonas.gmail.com" ];
      favorite-apps = [ "org.mozilla.firefox.desktop" "org.mozilla.Thunderbird.desktop" "org.gnome.Calendar.desktop" "org.gnome.Music.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      background-color = "rgb(0,0,0)";
      background-opacity = 0.8;
      click-action = "focus-minimize-or-previews";
      custom-background-color = true;
      custom-theme-shrink = true;
      customize-alphas = true;
      dash-max-icon-size = 32;
      dock-fixed = true;
      dock-position = "LEFT";
      extend-height = true;
      height-fraction = 0.9;
      max-alpha = 0.75;
      min-alpha = 0.2;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-2";
      transparency-mode = "DYNAMIC";
    };
  };
}
