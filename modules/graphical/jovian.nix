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

    programs.kdeconnect.enable = true;

    # Game Mode does not read the Plasma autostart entry that starts kdeconnectd.
    systemd.user.services.kdeconnectd = {
      description = "KDE Connect daemon";
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" "gamescope-session.service" ];
      wantedBy = [ "graphical-session.target" ];
      startLimitBurst = 10;
      startLimitIntervalSec = 300;
      # kdeconnectd needs a Qt platform plugin. Game Mode exports neither
      # WAYLAND_DISPLAY nor DISPLAY to the user manager, and leaves
      # XDG_SESSION_TYPE at x11, so Qt picks xcb and the process aborts.
      script = ''
        if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ]; then
          export WAYLAND_DISPLAY=gamescope-0
          export QT_QPA_PLATFORM=wayland
        fi
        exec ${getExe' config.programs.kdeconnect.package "kdeconnectd"}
      '';
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        Slice = "session.slice";
      };
    };

    users.users.${user}.extraGroups = [ "input" "video" "audio" ];

    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };

  };
}
