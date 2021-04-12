{ lib, config, ... }:
with lib;
let
  cfg = config.custom.wireless;
in
{
  options.custom.wireless = {
    enable = mkOption {
      default = false;
      example = true;
    };

    device = mkOption {
      type = types.str;
      example = "wlan0";
    };
  };

  config = mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      networks = import ./networks.secret.nix;
      interfaces = [ cfg.device ];
    };
    networking.interfaces."${cfg.device}".useDHCP = true;
  };
}
