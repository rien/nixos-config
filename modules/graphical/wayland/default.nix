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

      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
      };

      home.keyboard = {
        layout = "us";
        variant = "alt-intl";
        options = [ "caps:none" ];
      };

      home.packages = with pkgs; [ pamixer playerctl wlr-randr nwg-displays gnome.adwaita-icon-theme adwaita-qt kickoff swww  swaylock gnome.gnome-bluetooth wl-clipboard ];

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = true;
        settings = import ./hyprland.nix;
      };

      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = import ./waybar.nix;
        package = pkgs.waybar.override { wireplumberSupport = false; };
      };

      services.dunst = {
        enable = true;
        settings = {
          global = {
            alignment = "center";
            allow_markup = "yes";
            follow = "keyboard";
            font = "Fira Mono 16";
            format = "%s";
            frame_color = "#444444";
            frame_width = 2;
            geometry = "0x0-30+10";
            #geometry = "300x5-30+100";
            horizontal_padding = 16;
            icon_position = "off";
            idle_threshold = 120;
            indicate_hidden = true;
            line_height = 0;
            padding = 8;
            separator_color = "auto";
            separator_height = 2;
            show_age_threshold = -1;
            shrink = "no";
            sort = "yes";
            startup_notification = false;
            sticky_history = "yes";
            transparency = 0;
            #transparency = 50;
            word_wrap = "no";
          };

          urgency_low = {
            background = "#222222";
            foreground = "#718888";
            timeout = 5;
          };

          urgency_normal = {
            foreground = "#71c3af";
            background = "#1d2a30";
            timeout = 10;
          };

          urgency_critical = {
            background = "#900000";
            foreground = "#FFFFFF";
            timeout = 0;
          };
        };
      };

      systemd.user.services.swaybg = {
        Unit = {
          Description = "A Simple background";
          After = [ "hyprland-session.target" ];
          PartOf = [ "hyprland-session.target" ];
        };
        Service = {
          Environment = [ "PATH=${lib.makeBinPath [ pkgs.swaybg ]}" ];
          ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i /home/rien/pictures/Sollee.png";
        };
        Install.WantedBy = [ "hyprland-session.target" ];
      };
    };

    security.pam.services.swaylock = {};

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
