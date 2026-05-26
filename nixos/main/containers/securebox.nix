{ config, pkgs, ... }:
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-securebox" ];
    externalInterface = "enp11s0"; # WAN interface
  };

  # -----------------------------
  # CONTAINER DEFINITION
  # -----------------------------
  containers.securebox = {
    autoStart = true;
    privateNetwork = true;

    # veth pair addressing between host <-> container
    hostAddress = "10.250.0.1";
    localAddress = "10.250.0.2";
    bindMounts = {
      "/etc/wireguard/private.key" = {
        hostPath = "/home/wireguard/privkey";
        isReadOnly = true;
      };
    };

    bindMounts = {
      "/data" = {
        hostPath = "/data";
        isReadOnly = false;
      };
    };

    bindMounts = {
      "/var/lib/transmission" = {
        hostPath = "/data/transmission";
        isReadOnly = false;
      };
    };

    bindMounts = {
      "/run/secrets/wireguard_yeet" = {
        hostPath = "/run/secrets/wireguard_yeet";
        isReadOnly = true;
      };
    };

    config =
      { pkgs, lib, ... }:
      {

        system.stateVersion = "25.11";
        systemd.services.data-keepawake = {
          description = "Keep /data drive awake (prevent USB spin-down)";

          script = ''
            ${pkgs.coreutils}/bin/stat /data >/dev/null
          '';
        };

        systemd.timers.data-keepawake = {
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnBootSec = "2min";
            OnUnitActiveSec = "4min";
            AccuracySec = "30s";
          };
        };

        # -----------------------------
        # BASIC NETWORKING
        # -----------------------------
        networking.useNetworkd = true;
        networking.useHostResolvConf = false;
        networking.firewall.enable = true;
        systemd.services.systemd-networkd-wait-online = {
          enable = lib.mkForce false;
        };


        # hack to get host connection working
        systemd.network.networks."40-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            Address = "10.250.0.2/32";
            DHCP = "no";
            IPv6PrivacyExtensions = "kernel";
          };
          routes = [
            {
              Gateway = "10.250.0.1";
              GatewayOnLink = true;
            }
            {
              Destination = "10.250.0.1";
              Scope = "link";
            }
          ];
        };
        systemd.services.generate-wg0 = {
          description = "Generate wg0.conf from mounted secrets";

          wantedBy = [ "multi-user.target" ];
          before = [ "wg-quick@wg0.service" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          path = [
            pkgs.iptables
            pkgs.coreutils
          ];

          script = ''
            set -euo pipefail

            install -m 700 -d /etc/wireguard

            PUBKEY=$(cat /run/secrets/wireguard_yeet/pubkey)
            ENDPOINT=$(cat /run/secrets/wireguard_yeet/endpoint)
            PRIVKEY=$(cat /run/secrets/wireguard_yeet/privkey)

            printf '%s\n' \
            "[Interface]" \
            "Address = 192.168.0.4/24" \
            "PrivateKey = $PRIVKEY" \
            "DNS = 1.1.1.1" \
            "" \
            "[Peer]" \
            "PublicKey = $PUBKEY" \
            "Endpoint = $ENDPOINT" \
            "AllowedIPs = 0.0.0.0/0" \
            "PersistentKeepalive = 25" \
            > /etc/wireguard/wg0.conf

            chmod 600 /etc/wireguard/wg0.conf
          '';

        };

        systemd.services.firewall-allow-wg = {
          description = "Allow WireGuard endpoint through firewall";
          wantedBy = [ "multi-user.target" ];

          requiredBy = [ "wg0.service" ];
          before = [ "wg0.service" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = ''
            set -euo pipefail

            ENDPOINT=$(cat /run/secrets/wireguard_yeet/endpoint)
            IFS=: read -r IP PORT <<< "$ENDPOINT"

            iptables -I OUTPUT 1 -p udp -d "$IP" --dport "$PORT" -j ACCEPT
          '';

          path = [ pkgs.iptables ];
        };

        systemd.services.wg0 = {
          after = [ "generate-wg0.service" ];
          requires = [ "generate-wg0.service" ];

          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;

            ExecStart = "${pkgs.wireguard-tools}/bin/wg-quick up /etc/wireguard/wg0.conf";
            ExecStop = "${pkgs.wireguard-tools}/bin/wg-quick down /etc/wireguard/wg0.conf";
          };
        };

        # -----------------------------
        # KILL SWITCH (critical)
        # -----------------------------
        networking.firewall.extraCommands = ''
                                        # Allow loopback
                                        iptables -A OUTPUT -o lo -j ACCEPT
          			      # Allow traffic to/from host veth address (for SSH and management)
            iptables -I OUTPUT 1 -d 10.250.0.1 -j ACCEPT
            iptables -I INPUT 1 -s 10.250.0.1 -j ACCEPT

                    		    # Allow connection to server (we do this through a systemd service now...)
                                        # iptables -A OUTPUT -d $WG_HOST -p udp --dport $WG_HOST_PORT -j ACCEPT

                                        # Allow established connections
                                        iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

                                        # Allow traffic over WireGuard interface
                                        iptables -A OUTPUT -o wg0 -j ACCEPT

                                        # Drop everything else (kill switch)
                                        iptables -A OUTPUT -j DROP

                              	  
                                # -----------------------------
                                # FORWARD (IMPORTANT FOR VPN/NAT)
                                # -----------------------------

                                # allow return traffic
                                iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

                                # allow traffic from VPN to WAN (typical NAT route)
                                iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT

                                # (optional) allow LAN/WAN responses back in reverse direction
                                iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT
                                
                                iptables -A INPUT -p tcp --dport 51427 -j ACCEPT
                                iptables -A INPUT -p udp --dport 51427 -j ACCEPT
        '';

        # -----------------------------
        # MINIMAL USEFUL PACKAGES
        # -----------------------------
        environment.systemPackages = with pkgs; [
          curl
          rsstail
          wireguard-tools
          iproute2
          speedtest-cli
        ];

        # -----------------------------
        # OPTIONAL: SSH for access
        # -----------------------------
        services.openssh.enable = true; # use key auth
        users.users.root.hashedPassword = "!";

        services.transmission = {
          enable = true; # Enable transmission daemon
          openRPCPort = true; # Open firewall for RPC
          settings = {
            # Override default settings
            download-dir = "/data/torrents";
            incomplete-dir = "/data/incomplete";
            watch-dir-enabled = true;
            rpc-bind-address = "10.250.0.2"; # Bind to own IP
            rpc-whitelist = "127.0.0.1,10.250.0.1"; # Whitelist your remote machine (10.0.0.1 in this example)
            peer-port = 51427; # Be sure to forward on wg!
          };
        };

        systemd.services.transmission = {
          serviceConfig = {
            PrivateTmp = lib.mkForce false;
            PrivateMounts = lib.mkForce false;
            ProtectSystem = lib.mkForce false;
            ProtectHome = lib.mkForce false;

            # critical: disables namespace sandbox features that break in containers
            PrivateNetwork = lib.mkForce false;
            RootDirectory = lib.mkForce "";
          };
        };

        systemd.services.fix-watchdir-perms = {
          description = "Fix transmission watchdir permissions";

          before = [ "transmission.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
          };

          script = ''
            chmod 2775 /data/transmission/watchdir
          '';
        };

      };
  };

}
