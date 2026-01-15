{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

in {

  config = mkIf (cfg.enable && cfg.flavour == "kodi") {

    services.xserver.desktopManager.kodi = {
      enable = true;
      package = pkgs.kodi.withPackages (p: with p; [ jellyfin vfs-sftp ]);
    };

    services.xserver.enable = true;
    services.displayManager = {
      autoLogin = {
        enable = true;
        user = config.custom.user;
      };
      defaultSession = "kodi";
      sddm.enable = true;
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];


  };
}
