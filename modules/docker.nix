{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.custom.docker;
in {
  options.custom.docker.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      extraOptions = "--experimental";
      storageDriver = "zfs";
    };
    programs.criu.enable = true;
    systemd.services.docker.path = [ pkgs.gzip pkgs.gnutar pkgs.criu ];
    users.users.${config.custom.user}.extraGroups = [ "docker" ];
  };
}
