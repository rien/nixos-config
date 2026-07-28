{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;
  kodi = pkgs.kodi.withPackages (p: with p; [
    joystick
    vfs-sftp
    steam-launcher
  ]);
  user = config.custom.user;

in {

  config = mkIf (cfg.enable && cfg.flavour == "kodi") {


    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.libinput.enable = true;

    users.users.${user}.extraGroups = [ "input" "video" "audio" ];

    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };

    nixpkgs.config.kodi.enableAdvancedLauncher = true;

    home-manager.users.${user} = { pkgs, ... }: {
      home.packages = [ kodi ];
      home.file = {
        "bin/steam".source = config.programs.steam.package;
        "bin/kodi".source = kodi;
      };
    };



    services.xserver.enable = true;
    services.xserver.desktopManager.kodi.enable = true;
    services.xserver.desktopManager.kodi.package = kodi;
    services.xserver.displayManager.autoLogin.enable = true;
    services.xserver.displayManager.autoLogin.user = user;
    services.xserver.displayManager.lightdm.greeter.enable = false;



#    systemd.services.kodi = {
#      enable = true;
#      wantedBy = [ "multi-user.target" ];
#      conflicts = [ "getty@tty1.service" ];
#      serviceConfig = {
#        User = config.custom.user;
#        Group = "users";
#        SupplementaryGroups = [ "video" "input" ];
#        TTYPath = "/dev/tty1";
#        StandardInput = "tty";
#        StandardOutput = "journal";
#        ExecStart = "${kodi}/bin/kodi-standalone";
#        Restart = "always";
#      };
#    };

  };
}
