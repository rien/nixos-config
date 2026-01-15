{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

in {
  imports = [
    ./gnome.nix
    ./plasma.nix
    ./tv.nix
    ./kodi.nix
  ];

  options.custom.graphical = {
    enable = mkOption {
      default = false;
      example = true;
    };

    flavour = mkOption {
      example = "plasma";
      type = lib.types.enum [ "plasma" "tv" "gnome" "kodi" ];
    };
  };

  config = mkIf cfg.enable {

    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.keyboard = {
        layout = "us";
        variant = "alt-intl";
        options = [ "caps:none" ];
      };
      home.packages = with pkgs; [ pamixer playerctl adwaita-icon-theme adwaita-qt wl-clipboard moonlight-qt ];
      # gtk.gtk2.force = true;
    };


    fonts = {
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [ "Source Code Pro" ];
          sansSerif = [ "Source Serif Sans" ];
          serif = [ "Source Serif Pro" ];
        };
      };

      packages = with pkgs; with nerd-fonts; [
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
        noto-fonts-color-emoji
        comic-relief
        open-sans
      ];
    };
  };
}
