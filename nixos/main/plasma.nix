{ config, pkgs, ... }:
{
  # Enable plasma6
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.systemPackages = with pkgs; [
    kdePackages.kclock
    kdePackages.kcalc
  ];
}
