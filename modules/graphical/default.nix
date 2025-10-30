{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

in {
  imports = [
    ./plasma.nix
    ./tv.nix
  ];

  options.custom.graphical = {
    enable = mkOption {
      default = false;
      example = true;
    };

    flavour = mkOption {
      example = "plasma";
      type = lib.types.enum [ "plasma" "tv" ];
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
        noto-fonts-emoji
        comic-relief
        open-sans
      ];
    };
  };
}
