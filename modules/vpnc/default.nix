{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.vpnc;
in {
  options.custom.vpnc.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {
    age.secrets."vpnc".file = ./vpnc.age;

    systemd.services.vpnc = let
      vpnc = pkgs.vpnc;
      script = pkgs.writeScript "vpnc-script"
      ''
        export INTERNAL_IP4_NETADDR=157.193.0.0
        export INTERNAL_IP4_NETMASK=255.255.0.0
        export INTERNAL_IP4_NETMASKLEN=16
        exec ${vpnc}/etc/vpnc/vpnc-script
      '';
    in {
      unitConfig = {
        Description = "VPNC Connection";
        After = "network.target";
      };

      serviceConfig = {
        Type = "forking";
        ExecStart = "${vpnc}/bin/vpnc --pid-file=/run/vpnc.pid --script ${script} /run/secrets/vpnc";

        PIDFile = "/run/vpnc.pid";
        Restart = "always";

      };

      path = [ pkgs.nettools ];
    };
  };
}
