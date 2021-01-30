{ config, lib, pkgs, ... }: {
  options.custom.kitty = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config = lib.mkIf config.custom.kitty.enable {
    home-manager.users.rien = { pkgs, ... }: {
      programs.kitty = {
        enable = true;
        settings = {
          font_family = "Fira Code";
          font_size = 16;
          disable_ligatures = "cursor";
          enable_audio_bell = false;
          visual_bell_duration = "0.0";
          remember_window_size = false;

          foreground      = "#b7b8b9";
          foreground_bold = "#b7b8b9";
          cursor          = "#b7b8b9";
          background      = "#0c0d0e";

          color0  = "#0c0d0e";
          color8  = "#737475";

          color1  = "#e31a1c";
          color9  = "#e31a1c";

          color2  = "#31a354";
          color10 = "#31a354";

          color3  = "#dca060";
          color11 = "#dca060";

          color4  = "#3182bd";
          color12 = "#3182bd";

          color5  = "#756bb1";
          color13 = "#756bb1";

          color6  = "#80b1d3";
          color14 = "#80b1d3";

          color7  = "#b7b8b9";
          color15 = "#fcfdfe";
        };
      };
    };
  };
}
