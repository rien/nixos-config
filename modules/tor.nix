{ config, lib, ... }:
with lib;
let
  cfg = config.custom.tor;
in {
  options.custom.tor.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {
    services.tor = {
      enable = true;
      client.enable = true;
    };
  };
}
