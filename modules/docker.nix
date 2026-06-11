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
      default = "overlay";
    };
  };


  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings = {
        dns = [ "100.100.100.100" ];
      };
    };
    virtualisation.containers.storage.settings = {
      storage.driver = cfg.storageDriver;
    };
    programs.criu.enable = true;
    systemd.services.podman.path = [ pkgs.gzip pkgs.gnutar pkgs.criu ];
    users.users.${config.custom.user}.extraGroups = [ "docker" "podman" ];
  };
}
