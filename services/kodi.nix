{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.kodi;
in {
  options.custom.kodi.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {
    # Define a user account
    users.extraUsers.kodi = {
      isNormalUser = true;
      extraGroups = [ "video" "input" "audio" ];
    };
    services.cage.user = "kodi";
    services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
    services.cage.enable = true;

    # Remote interface
    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };
  };

}
