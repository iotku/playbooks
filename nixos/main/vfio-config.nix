# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

{
  system.nixos.label = "vfio";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 134217728;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
#boot.kernelPackages = pkgs.linuxPackages_latest;
boot.kernelPackages = pkgs.linuxPackages_6_18;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "mitigations=off" # Super insecure! Nice!
    "default_hugepagesz=2M"
    "hugepagesz=2M"
    "hugepages=8192"
    "isolcpus=2-11"
    "nohz_full=2-11"
    "rcu_nocbs=2-11"
    "pcie_acs_override=downstream,multifunction" # Probably not needed
    "vfio-pci.ids=1002:7550,1002:ab40" # AMD GPU VGA/AUDIO
    "vfio-pci.disable_idle_d3=1"
  ];

  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7550", ATTR{resource0_resize}="14"
  ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x7550", ATTR{resource2_resize}="8"
'';
  powerManagement.cpuFreqGovernor = "performance";

  boot.blacklistedKernelModules = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "vfio_pci" "vfio" "vfio_iommu_type1" ];
 
  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  security.allowUserNamespaces = true;
  
  # DONT enable the X11 windowing system.
  services.xserver.enable = false;
  hardware.graphics.enable = false;

  programs.steam.enable = false;

  programs.nix-ld = {
  	enable = true;
	libraries = pkgs.steam-run.args.multiPkgs pkgs;
	};
  # Disable Sleep
  systemd.sleep.extraConfig = ''
  AllowSuspend=no
  AllowHibernation=no
  AllowHybridSleep=no
  AllowSuspendThenHibernate=no
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable sound with pipewire. # We probably wand to disable this
  services.pulseaudio.enable = false;
  services.pipewire.enable = false;
  security.rtkit.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.defaultUserShell = pkgs.zsh;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.luser = {
    isNormalUser = true;
    description = "Local User";
    extraGroups = [ "networkmanager" "wheel" "kvm" "adbusers" "libvirtd" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # or "prohibit-password" (safer)
      PasswordAuthentication = true; # or false if using keys
    };
  };

  systemd.services.winvm = {
    description = "Start Windows 11 VM with GPU passthrough and reboot host on VM shutdown";
  
    after = [ "network.target" "libvirtd.service" "network-online.target" "sshd.service" ];
    wants = [ "libvirtd.service" ];
  
    serviceConfig = {
      Type = "simple";
      Restart = "no";  # We don't auto-restart the service itself
      ExecStart = "${pkgs.libvirt}/bin/virsh start win11-ltsc-gpu";
      ExecStop = "${pkgs.libvirt}/bin/virsh shutdown win11-ltsc-gpu";
    };
  
    wantedBy = [ "multi-user.target" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = false; # We're using the flatpak instead :)
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    tmux

    # Virtualization / Containers
   # spice-gtk
    pciutils
    dmidecode
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
    histSize = 10000;
  };

  # To add the zsh package to /etc/shells you must update environment.shells. 
  environment.shells = with pkgs; [ zsh ];


  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

   system.stateVersion = "25.11"; # Did you read the comment?
}
