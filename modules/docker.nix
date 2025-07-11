{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.docker;
in {
  options.custom.docker = {
    enable = mkOption {
      default = false;
      example = true;
    };
    storageDriver = mkOption {
      default = "overlay2";
    };
  };


  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = cfg.storageDriver;
    };
    programs.criu.enable = true;
    systemd.services.docker.path = [ pkgs.gzip pkgs.gnutar pkgs.criu ];
    users.users.${config.custom.user}.extraGroups = [ "docker" ];
  };
}
