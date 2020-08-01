let
  wgConfig = import ./wireguard/config.secret.nix;
in
{
    # Enable Wireguard
    networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = wgConfig.ips;

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = "/etc/nixos/services/wireguard/privkey.secret";

      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = wgConfig.pubkey;

          # Or forward only particular subnets
          allowedIPs = wgConfig.allowedIPs;

          # Set this to the server IP and port.
          endpoint = wgConfig.endpoint;

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
