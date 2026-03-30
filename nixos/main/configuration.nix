# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 134217728;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./wireguard.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelModules = [
    "v4l2loopback"
  ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable NTFS support
  boot.supportedFilesystems = [ "ntfs" ];
  services.udisks2.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  i18n.inputMethod.fcitx5.waylandFrontend = true; # Supress wayland messages

  environment.variables = {
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
 #   JAVA_TOOL_OPTIONS = "-Dsun.java2d.uiScale=2.0"; # Fractional scaling support when?
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  programs.steam.enable = false;

  programs.nix-ld = {
  	enable = true;
	libraries = pkgs.steam-run.args.multiPkgs pkgs;
	};
  # Copy monitor configurationg from `luser`, ideally we would use a varible for the user.
  systemd.services.copyGdmMonitorsXml = {
    description = "Copy monitors.xml to GDM config";
    after = [ "network.target" "systemd-user-sessions.service" "display-manager.service" ];
    
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /run/gdm/.config && [ \"/home/luser/.config/monitors.xml\" -ef \"/run/gdm/.config/monitors.xml\" ] || cp /home/luser/.config/monitors.xml /run/gdm/.config/monitors.xml && chown gdm:gdm /run/gdm/.config/monitors.xml'";
      Type = "oneshot";
    };
    
    wantedBy = [ "multi-user.target" ];
  };

  # Disable Sleep
  systemd.sleep.extraConfig = ''
  AllowSuspend=no
  AllowHibernation=no
  AllowHybridSleep=no
  AllowSuspendThenHibernate=no
  '';

  # Gnome stuff
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-developer-tools.enable = true;
  services.gnome.games.enable = false; # No fun allowed
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.mutter]
    experimental-features=['scale-monitor-framebuffer', 'xwayland-native-scaling']
  '';

  # They see me scrollin' they hatin'
  programs.niri.enable = true;
 
  # Enable plasma6
  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.wayland.enable = true;
  #services.desktopManager.plasma6.enable = true;
  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.profont
    noto-fonts-color-emoji
    vista-fonts
    # CJK Fonts
    source-han-sans
    source-han-mono
    source-han-serif
    source-han-code-jp
    # Good TTF font for supersonic/Japanse fallback
    mplus-outline-fonts.githubRelease 
    #/run/current-system/sw/share/X11/fonts/Mplus2-Black.ttf
    #/run/current-system/sw/share/X11/fonts/Mplus2-Regular.ttf
  ];

  # Font Styling
  fonts = {
    fontconfig = {
      # Fixes pixelation
      antialias = true;

      # Color emojis
      useEmbeddedBitmaps = true;
  
      # Fixes antialiasing blur
      hinting = {
        enable = true;
        style = "slight";
      };
  
      subpixel = {
        # Makes it bolder
        rgba = "rgb";
        lcdfilter = "light";
      };

      defaultFonts = {
        sansSerif = [ "Calibri" "Noto Sans" ];
        serif = [ "Cambria" "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font Mono" "Source Han Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    wireplumber.configPackages = [
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
  };

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = false; # We're using the flatpak instead :)

  # Configure nix-flatpak
  services.flatpak = {
    enable = true;
  };

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "daily"; # Default value
  };

  # Wait for network before running flatpak update
  systemd.services."flatpak-managed-install-timer" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };

  services.flatpak.packages = [
      "org.deskflow.deskflow" # KB/Mouse Sharing
      "com.github.tchx84.Flatseal" # Flatpak sandbox configuration
      # Browser / Email
      "org.mozilla.firefox" # xdg-settings set default-web-browser org.mozilla.firefox.desktop
      "org.mozilla.Thunderbird"
      "com.logseq.Logseq"
      "com.sublimemerge.App"
      "net.ankiweb.Anki"
      # Communication Platforms
      "org.telegram.desktop"
      "com.discordapp.Discord"
      "us.zoom.Zoom"
      "info.mumble.Mumble"
      # Compatibility
      "com.usebottles.bottles"
      "io.podman_desktop.PodmanDesktop"
   #   "it.mijorus.gearlever" # GTK Manage Appimages
      # Media
      "com.calibre_ebook.calibre"
      "com.yacreader.YACReader"
      "com.obsproject.Studio"
  ];

  # Podman containers
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs.java.enable = true;
  programs.adb.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    tmux
    fzf
    nnn
    git
    git-lfs
    unzip
    btop
    rclone
    lftp
    distrobox
    bitwarden-desktop
    ghostty
    wireguard-tools
 
    # for niri
    alacritty
    fuzzel
    swaylock
    waybar

    # Multimedia
    supersonic
    mpv
    jellyfin-mpv-shim
    yt-dlp
    streamlink

    # Communication
    signal-desktop

    # Gnome
    gnome-tweaks
    gnomeExtensions.dash-to-dock
    gnomeExtensions.kimpanel
    gnomeExtensions.caffeine
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.tiling-assistant
    dconf2nix
    gnome-solanum

    # Virtualization / Containers
    podman-compose
    spice-gtk
    pciutils

    # Hardware specific
    solaar # Logitech Mice
    #nvtopPackages.nvidia 

    # non-free
    reaper
    reaper-sws-extension
    reaper-reapack-extension
    # Unstable overlays
    readest
    zed-editor
    vscode
    slack
    # Programming Languages
    jetbrains-toolbox
    gcc
    go
    lua
    maven
    python3
    zig
    rustup
    clang-tools
    nodejs
    powershell # why not
    antimicrox

    # Language Servers
    nil
    nixd
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


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 24800 ]; # open port for deskflow server
  # Firewall ports for KDEConnect/GSconnect
  networking.firewall.allowedTCPPortRanges = [ 
  	{ from = 1716; to = 1764; } 
  ];
  networking.firewall.allowedUDPPortRanges = [ 
  	{ from = 1716; to = 1764; } 
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
