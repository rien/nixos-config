{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.vpnc;
  vpnc = pkgs.vpnc;
  vu = pkgs.writeScriptBin "vu"
  ''
    sudo ${vpnc}/bin/vpnc --script ${vpnc}/etc/vpnc/vpnc-script /run/secrets/vpnc
  '';
  vd = pkgs.writeScriptBin "vd"
  ''
    sudo ${vpnc}/bin/vpnc-disconnect
  '';
in {
  options.custom.vpnc.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {
    age.secrets."vpnc".file = ./vpnc.age;
    home-manager.users.rien = { ... }: {
      home.packages = [ vu vd ];
    };
  };
}
