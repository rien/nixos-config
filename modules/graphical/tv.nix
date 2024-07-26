{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical.tv;

in {

  options.custom.graphical.tv = {
    enable = mkOption {
      default = false;
      example = true;
    };
  };

  config = mkIf cfg.enable {



    home-manager.users.${config.custom.user} = { pkgs, ... }: {

      home.keyboard = {
        layout = "us";
        variant = "alt-intl";
        options = [ "caps:none" ];
      };

      home.packages = with pkgs; [ pamixer playerctl adwaita-icon-theme adwaita-qt wl-clipboard ];

    };

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

    fonts = {
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Symbola" "Noto Emoji" ];
          monospace = [ "Fira Code" ];
          sansSerif = [ "Fira Sans" ];
          serif = [ "Source Serif Pro" ];
        };
      };
      packages = with pkgs; [
        orbitron
        roboto
        roboto-mono
        roboto-slab
        source-serif
        source-sans-pro
        source-serif-pro
        source-code-pro
        fira-mono
        fira-code
        fira
        symbola
        noto-fonts-emoji
        comic-relief
        nerdfonts
        open-sans
        # corefonts
      ];
    };
  };
}
