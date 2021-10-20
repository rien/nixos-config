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

    soundsystem = mkOption {
      default = "pipewire";
      example = "pulseaudio";
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = (cfg.soundsystem == "pipewire" || cfg.soundsystem == "pulseaudio");
        message = "soundsystem should be either pipewire or pulseaudio";
      }
    ];

    sound.enable = true;

    services.pipewire = mkIf (cfg.soundsystem == "pipewire") {
      enable = true;
      alsa.enable = true;
      jack.enable = true;
      pulse.enable = true;
    };

    hardware.pulseaudio = mkIf (cfg.soundsystem == "pulseaudio") {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
    };

    environment.systemPackages = with pkgs; [ sof-firmware ];


    security.rtkit.enable = true;

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

    # Ignore power key and lid events
    services.logind.extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=ignore
    '';

    # Configure X session with Xmonad and Xmobar
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
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
        initExtra = ''
          xset r rate 175 75
          autorandr --change
          feh --recursive --randomize --bg-fill ~/pictures/simonstalenhag/ || true
          '';
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

      programs.bash.initExtra = ''
        if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          startx
          exit
        fi
      '';


      programs.autorandr = {
        enable = true;
        profiles = let
          laptop = "00ffffffffffff004d10f91400000000151e0104a51d12780ede50a3544c99260f505400000001010101010101010101010101010101283c80a070b023403020360020b410000018203080a070b023403020360020b410000018000000fe0056564b3859804c513133344e31000000000002410332001200000a010a20200080";
          home = "00ffffffffffff004c2d0e1036395743181e010380351e782a6595a854519c25105054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c45000f282100001e000000fd00324b1e5512000a202020202020000000fc00533234523335780a2020202020000000ff004834544e3630303238330a20200179020313b14690041f13120367030c0010000024011d00bc52d01e20b82855400f282100001e8c0ad090204031200c4055000f28210000188c0ad08a20e02d10103e96000f28210000182a4480a070382740302035000f282100001a0000000000000000000000000000000000000000000000000000000000000000000000007a";
          office = "00ffffffffffff0010ac6da0555036352614010380351e78eabb04a159559e280d5054a54b00714f8180d1c001010101010101010101023a801871382d40582c4500132b2100001e000000ff004e52505035303947353650550a000000fc0044454c4c205032343131480a20000000fd00384c1e5311000a20202020202001e602031b61230907078301000067030c002000802d43908402e2000f8c0ad08a20e02d10103e9600a05a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
          in {
          "home" = {
            config = {
              eDP-1 = {
                enable = true;
                crtc = 0;
                primary = true;
                rate = "59.95";
                mode = "1920x1200";
                position = "0x1080";
              };
              DP-3 = {
                enable = true;
                crtc = 1;
                rate = "60.00";
                mode = "1920x1080";
                position = "0x0";
              };
            };
            fingerprint = {
              DP-3 = home;
              eDP-1 = laptop;
            };
          };
          "office" = {
            config = {
              eDP-1 = {
                enable = true;
                crtc = 0;
                primary = true;
                rate = "59.95";
                mode = "1920x1200";
                position = "0x1080";
              };
              DP-1-3 = {
                enable = true;
                crtc = 1;
                rate = "60.00";
                mode = "1920x1080";
                position = "0x0";
              };
            };
            fingerprint = {
              DP-1-3 = office;
              eDP-1 = laptop;
            };
          };
        };
      };
    };
  };
}
