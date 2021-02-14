{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.minidlna;
in {
  options.custom.minidlna = {
    enable = mkOption {
      example = true;
      default = false;
    };

    dirs = mkOption {
      example = [ "/media" ];
      default = [];
    };
  };

  config = mkIf cfg.enable{
    networking.firewall.allowedTCPPorts = [ 8200 ];
    networking.firewall.allowedUDPPorts = [ 1900 56139];
    services.minidlna = {
      enable = true;
      mediaDirs = cfg.dirs;
      announceInterval = 30;
    };
  };
}
