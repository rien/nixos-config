{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;
  kodi = pkgs.kodi-gbm.withPackages (p: with p; [
    joystick
    vfs-sftp
    steam-launcher
  ]);

in {

  config = mkIf (cfg.enable && cfg.flavour == "kodi") {


    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    services.libinput.enable = true;

    users.users.${config.custom.user}.extraGroups = [ "input" "video" "audio" ];

    networking.firewall = {
      allowedTCPPorts = [ 8080 ];
      allowedUDPPorts = [ 8080 ];
    };

    nixpkgs.config.kodi.enableAdvancedLauncher = true;

    systemd.services.kodi = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      conflicts = [ "getty@tty1.service" ];
      serviceConfig = {
        User = config.custom.user;
        Group = "users";
        SupplementaryGroups = [ "video" "input" ];
        TTYPath = "/dev/tty1";
        StandardInput = "tty";
        StandardOutput = "journal";
        ExecStart = "${kodi}/bin/kodi-standalone";
      };
    };

  };
}
