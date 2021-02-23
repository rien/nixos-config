{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.graphical;

  brightness = pkgs.stdenv.mkDerivation {
    name = "brightness";
    src = ./brightness.sh;
    inherit (pkgs) brightnessctl dunst;
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      substituteAll $src $out/bin/$name
      chmod +x $out/bin/$name
    '';
  };
  volumectl = pkgs.stdenv.mkDerivation {
    name = "volumectl";
    src = ./volumectl.sh;
    noot = ./noot.ogg;
    inherit (pkgs) pulseaudio dunst;
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      substituteAll $src $out/bin/$name
      chmod +x $out/bin/$name
    '';
  };
  slock = pkgs.slock.overrideAttrs (old: {
    name = "slock-custom";
    src = pkgs.fetchFromGitHub {
      owner = "rien";
      repo = "slock";
      rev = "de7cd3f300f9e83533120025e59f22d5afb4f255";
      sha256 = "sha256-adil530ecPQKDUg1gkoYI870lD8TbEmytMU1+zPJ1m0=";
    };
  });
  slockWrapped = pkgs.writeScriptBin "slock" ''
      /run/wrappers/bin/doas ${slock}/bin/slock
  '';
  screenshot = pkgs.stdenv.mkDerivation {
    name = "screenshot";
    src = ./screenshot.sh;
    inherit (pkgs) dunst imagemagick xclip;
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      substituteAll $src $out/bin/$name
      chmod +x $out/bin/$name
    '';
  };
in {
  options.custom.graphical = {
    enable = mkOption {
      default = false;
      example = true;
    };
  };

  config = mkIf cfg.enable {

    custom.allowUnfree = [ pkgs.symbola ];

    environment.systemPackages = with pkgs; [ sof-firmware ];

    sound.enable = true;
    security.rtkit.enable = true;
    hardware.pulseaudio.enable = true;
    hardware.pulseaudio.support32Bit = true;
    hardware.pulseaudio.package = pkgs.pulseaudioFull;

    # Enable X11 and fix touchpad
    services.xserver = {
      enable = true;
      displayManager.startx.enable = true;
      synaptics = {
        enable = true;
        tapButtons = false;
        vertTwoFingerScroll = true;
        # Two fingers -> right mouse button
        # Three fingers -> middle mouse button
        buttonsMap = [ 1 3 2 ];

        maxSpeed = "1.25";
        minSpeed = "1.25";
      };
    };

    # Set some nice fonts
    fonts = {
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = [ "Symbola" "Noto Emoji" ];
          monospace = [ "Fira Code" ];
          sansSerif = [ "Fira Sans" ];
          serif = [ "Fira" ];
        };
      };
      fonts = with pkgs; [
        fira-code
        fira
        symbola
        noto-fonts-emoji
      ];
    };

    security.doas.extraRules = [{
      cmd = "${slock}/bin/slock";
      setEnv = [ "DISPLAY=$DISPLAY" "XAUTHORITY=$XAUTHORITY" ];
      users = [ "rien" ];
      noPass = true;
    }];

    # Configure X session with Xmonad and Xmobar
    home-manager.users.rien = { pkgs, ... }: {
      home.packages = with pkgs; [ pavucontrol patchage dunst volumectl brightnessctl brightness slockWrapped screenshot ];
      home.file.".xinitrc".text = "source ~/.xsession";
      home.keyboard = {
        layout = "us";
        variant = "alt-intl";
        options = [ "caps:none" ];
      };

      services.screen-locker.lockCmd = "${slockWrapped}/bin/slock";

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

      xsession = {
        enable = true;
        initExtra = "xset r rate 175 75";
        windowManager.xmonad = {
          enable = true;
          enableContribAndExtras = true;
          # Build custom xmonad from ./xmonad.hs
          config = pkgs.substituteAll {
            src = ./xmonad.hs;

            # Build custom xmobar from file
            xmobar = (
              pkgs.writers.writeHaskell
              "xmobar"
              {
                libraries = with pkgs.haskellPackages; [ 
                  xmobar
                  clock
                ];
                ghcArgs = [ "-threaded" ];
              }
              (builtins.readFile ./xmobar.hs)
            );

            inherit
              volumectl
              brightness
              slockWrapped
              screenshot;

            inherit (pkgs)
              kitty
              dmenu
              firefox
              pass
              ;
          };
        };
      };
    };
  };
}
