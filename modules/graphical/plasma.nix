{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

in {

  config = mkIf (cfg.enable && cfg.flavour == "plasma") {

    # autotiler
    environment.systemPackages = [ pkgs.polonium ];

    services.desktopManager.plasma6.enable = true;

    services.displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
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
