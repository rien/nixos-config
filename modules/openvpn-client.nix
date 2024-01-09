{ config, lib, pkgs, ... }:
with lib;
let
  personal = import ./personal.secret.nix;
  cfg = config.custom.ugent-vpn;
in {
  options.custom.ugent-vpn = {
    enable = mkOption {
      default = false;
      example = true;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ugent-sshuttle = {
      unitConfig = {
        Description = "UGent VPN lookalike using sshuttle";
        After = [ "network.target" ];
      };
      serviceConfig = {
        Type = "notify";
        ExecStart = "${pkgs.sshuttle}/bin/sshuttle --remote ${personal.ugentVPN} 157.193.0.0/16";
      };
    };
  };
}
