{
  inputs,
  pkgs,
  home-manager,
  lib,
  ...
}:
let
  sys = pkgs.stdenv.hostPlatform.system;
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{

  systemd.user.services.polkit-agent =
    let
      polkitAgentScript = pkgs.writeShellScript "polkit-agent" ''
        if [ -x "${lib.getExe pkgs.hyprpolkitagent}" ]; then
          exec "${lib.getExe pkgs.hyprpolkitagent}"
        fi
        if [ -x "${lib.getExe' pkgs.mate-polkit "polkit-mate-authentication-agent-1"}" ]; then
          exec "${lib.getExe' pkgs.mate-polkit "polkit-mate-authentication-agent-1"}"
        fi
        echo "No supported polkit agent found." >&2
        exit 1
      '';
    in
    {
      description = "Polkit authentication agent";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = polkitAgentScript;
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

  hardware.graphics = {
    #  package = pkgs-unstable.mesa;

    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    #   package32 = pkgs-unstable.pkgsi686Linux.mesa;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland; # xdph-git
    package = inputs.hyprland.packages.${sys}.hyprland;
    #   portalPackage = inputs.hyprland.packages.${sys}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      inputs.hyprland.packages.${sys}.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
      #pkgs.xdg-desktop-portal
    ];
    config = {
      common.default = "gtk";

      hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };
  systemd.user.services.xdg-desktop-portal.restartIfChanged = true;
  systemd.user.services.xdg-desktop-portal-hyprland.restartIfChanged = true;
  # xdg.portal = {
  #   enable = true;
  # };

  home-manager.users.luser = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      #    portalPackage = null;
      systemd.enable = false;
      configType = "lua";
    };
    programs.vicinae = {
      enable = true; # Enables the vicinae launcher daemon
      systemd = {
        enable = true;
        autoStart = true;
      };
      settings = {
        popToRootOnClose = true;
      };

    };
  };

  security.polkit.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    foot # Terminal
    kdePackages.dolphin # File manager
    hyprlauncher # Launcher
    vicinae
    quickshell

    hyprpolkitagent # auth agent
    hyprpaper # wallpaper
    mako # notifications
    cliphist # clipboard history
    wl-clipboard # cliphist dependency
  ];

}
