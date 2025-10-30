{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

in {

  config = mkIf (cfg.enable && cfg.flavour == "tv") {

    services.desktopManager.plasma6.enable = true;

    programs.kdeconnect.enable = true;

    services.displayManager = {
      autoLogin = {
        enable = true;
        user = config.custom.user;
      };
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
