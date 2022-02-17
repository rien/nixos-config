{ config, pkgs, lib, util, ... }:
let
  cfg = config.custom.matrix;
in {
  options.custom.matrix = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
    hostname = lib.mkOption {
      example = "example.com";
    };
  };
  config = lib.mkIf cfg.enable {
    services.matrix-synapse = {
      server_name = cfg.hostname;
    };
  };
}
