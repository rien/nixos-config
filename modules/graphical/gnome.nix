{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

in {

  config = mkIf (cfg.enable && cfg.flavour == "gnome") {

    environment.systemPackages = with pkgs; [
      rose-pine-cursor
      rose-pine-icon-theme
      gnome-tweaks
    ];


    services.desktopManager.gnome.enable = true;

    services.displayManager = {
      defaultSession = "gnome";
      gdm.enable = true;
    };

    xdg.portal = {
      enable = true;
      config.preferred = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screencast" = "hyprland";
      };
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-hyprland ];
    };
  };
}
