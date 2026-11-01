{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # Enable plasma6
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "luser";
  };

  services.desktopManager.plasma6.enable = true;
  environment.systemPackages = with pkgs; [
    kdePackages.kclock
    kdePackages.kcalc
    kdePackages.qtwebsockets # needed for https://github.com/korapp/plasma-homeassistant
    kdePackages.xdg-desktop-portal-kde
  ];

}
