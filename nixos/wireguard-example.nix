{
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp11s0"; # eth0 or simular...
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    wg0 = { # wg interface name
      ips = [ "10.8.0.6/24" ]; # System's IP for wg tunnel
      listenPort = 51820; # Extenernal wg listenPort
      #postSetup = '' #
      #${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
      #'';

      # This undoes the above command when bringing down tunnel
      #postShutdown = ''
      #${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
      #'';

      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable;
      privateKeyFile = "/home/wireguard/privkey";

      peers = [
        # List of allowed peers.
        {
          # Feel free to give a meaningful name
          name = "Peer 1";
          # Public key of the peer (not a file path).
          publicKey = "...";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.8.0.0/24" ];
          endpoint = "..."; # EXTERNAL Endpoint IP e.g. to another system or jumpbox
        }
        {
          name = "Peer 2";
          publicKey = "...";
          allowedIPs = [ "10.8.0.2/32" "10.8.0.3/32" ];
          endpoint = "...";
        }
      ];
    };
  };
}

