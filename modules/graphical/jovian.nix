{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;
  user = config.custom.user;
in {

  config = mkIf (cfg.enable && cfg.flavour == "jovian") {

    jovian.steam = {
      enable = true;
      autoStart = true;
      user = user;
      desktopSession = "plasma";
      environment = {
        STEAM_GAMESCOPE_TEARING_SUPPORTED = "0";
        STEAM_GAMESCOPE_VRR_SUPPORTED = "0";
      };
    };

    services.desktopManager.plasma6.enable = true;


    # Ignore power key and lid events
    services.logind.settings.Login = {
      HandlePowerKey = "ignore";
      HandleLidSwitch = "ignore";
    };
    systemd.sleep.settings.Sleep = {
      AllowSuspend = false;
      AllowHibernation = false;
    };


    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.libinput.enable = true;

    users.users.${user}.extraGroups = [ "input" "video" "audio" ];

    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };

  };
}
