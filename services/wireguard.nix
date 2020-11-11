{ lib, pkgs, config, ...  }:
with lib;
let
  cfg = config.custom.wireguard;
in
  {
    options.custom.wireguard = {
      namespace = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of the network namespace the wireguard interface should be located in. If none (null) is given, it doesn't put wireguard in a namespace.
        '';
      };
      ips = mkOption {
        type = types.listOf types.str;
      };
      privateKeyFile = mkOption {
        type = types.path;
      };
      publicKey = mkOption {
        type = types.str;
      };
      allowedIPs = mkOption {
        type = types.listOf types.str;
        default = [ "0.0.0.0/0" ];
      };
      endpoint = mkOption {
        type = types.str;
      };
    };

    config = let
      namespace = cfg.namespace;
      hasNamespace = namespace != null;
      vethGlobal = "veth${namespace}global";
      vethNs = "veth${namespace}local";
    in
      {
      # Enable Wireguard
      networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the client's end of the tunnel interface.
        ips = cfg.ips;

        preSetup = if hasNamespace then ''
          set -x
          ip netns del ${namespace} || true
          ip route del 10.10.10.0/24 || true
          ip netns add ${namespace}
          ip -n ${namespace} link set dev lo up
        ''
        else "";

        postSetup = if hasNamespace then ''
          ip link del ${vethGlobal} || true
          ip -n ${namespace} link del ${vethNs} || true

          ip link add ${vethGlobal} type veth peer name ${vethNs} netns ${namespace}

          ip addr add 10.10.10.1/24 dev ${vethGlobal}
          ip link set dev ${vethGlobal} up

          ip -n ${namespace} addr add 10.10.10.2/24 dev ${vethNs}
          ip -n ${namespace} link set dev ${vethNs} up

          ip route del 10.10.10.0/24 || true
          ip route add 10.10.10.0/24 via 10.10.10.1
        ''
        else "";

        postShutdown = if hasNamespace then ''
          ip link del ${vethGlobal} || true
          ip -n ${namespace} link del ${vethNs} || true
          ip netns del ${namespace} || true
          ip route del 10.10.10.0/24 || true
        ''
        else "";

        interfaceNamespace = mkIf hasNamespace cfg.namespace;

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        privateKeyFile = cfg.privateKeyFile;

        peers = [
          # For a client configuration, one peer entry for the server will suffice.
          {
            # Public key of the server (not a file path).
            publicKey = cfg.publicKey;

            allowedIPs = cfg.allowedIPs;

            # Set this to the server IP and port.
            endpoint = cfg.endpoint;

            # Send keepalives every 25 seconds. Important to keep NAT tables alive.
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };
}
