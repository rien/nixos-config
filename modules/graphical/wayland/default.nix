{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical.hyprland;

in {

  options.custom.graphical.hyprland = {
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

      home.packages = with pkgs; [ pamixer playerctl wlr-randr nwg-displays gnome.adwaita-icon-theme adwaita-qt wofi swww xdg-desktop-portal-hyprland xdg-desktop-portal-gtk swaylock ];

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = import ./hyprland.nix;
      };

      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = {
          mainBar = {
            layer = "top";
            spacing = 2;
            modules-left = [ "hyprland/workspaces" ];
            modules-center = [ "hyprland/window" ];
            modules-right = [ "mpris" "pulseaudio" "network" "battery" "clock" ];
          };
        };
      };
    };

    security.pam.services.swaylock = {};

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
