{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical.plasma;

in {

  options.custom.graphical.plasma = {
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

    # autotiler
    environment.systemPackages = [ pkgs.libsForQt5.polonium ];

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

    # Ignore power key and lid events
    services.logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=ignore
    '';
  };
}
