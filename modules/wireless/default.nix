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

    dhcp = mkOption {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;

    users.users.${config.custom.user}.extraGroups = [ "networkmanager" ];
  };
}
