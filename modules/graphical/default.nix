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
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };

    environment.etc = mkIf (cfg.soundsystem == "pipewire") {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
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
      libinput.enable = false;
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

    programs.dconf.enable = true;

    # Fix GTK filepicker crashing
    nixpkgs.overlays = [(self: super: {
      xmonad-with-packages = let
        xmessage = self.xorg.xmessage;
        ghcWithPackages = self.haskellPackages.ghcWithPackages;
        packages = _: [ self.haskellPackages.xmonad-contrib self.haskellPackages.xmonad-extras ];
        xmonadEnv = ghcWithPackages (self: [ self.xmonad ] ++ packages self);
      in super.xmonad-with-packages.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ self.glib self.wrapGAppsHook self.gtk3 ];
        buildCommand = ''
          gappsWrapperArgsHook

          install -D ${xmonadEnv}/share/man/man1/xmonad.1.gz $out/share/man/man1/xmonad.1.gz
          makeWrapper ${xmonadEnv}/bin/xmonad $out/bin/xmonad \
          ''${gappsWrapperArgs[@]} \
          --set XMONAD_GHC "${xmonadEnv}/bin/ghc" \
          --set XMONAD_XMESSAGE "${xmessage}/bin/xmessage"
        '';
      });
    })];


    # Configure X session with Xmonad and Xmobar
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.packages = with pkgs; [ pavucontrol patchage dunst volumectl brightnessctl brightness slockWrapped screenshot gnome.adwaita-icon-theme adwaita-qt ];
      home.file.".xinitrc".text = "source ~/.xsession";
      home.keyboard = {
        layout = "us";
        variant = "alt-intl";
        options = [ "caps:none" ];
      };

      dconf.settings."org/gnome/desktop/interface" = {
        gtk-theme = "breeze-gtk";
        icon-theme = "breeze-icons";
      };
      gtk = {
        enable = true;

        iconTheme = {
          package = pkgs.libsForQt5.breeze-icons;
          name = "breeze-icons";
        };
        theme = {
          package = pkgs.libsForQt5.breeze-gtk;
          name = "breeze-gtk";
        };
      };
      qt = {
        enable = true;
        platformTheme = "gnome";
        style = {
          name = "breeze";
          package = pkgs.libsForQt5.breeze-qt5;
        };
      };

      services.screen-locker.lockCmd = "${slockWrapped}/bin/slock";
      services.gnome-keyring = {
        enable = true;
        components = [ "secrets" ];
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

      # bluetooth MIDI controls
      services.mpris-proxy.enable = true;



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

      #programs.bash.initExtra = ''
      #  if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      #    startx
      #    exit
      #  fi
      #'';


      programs.autorandr = {
        enable = true;
        profiles = let
          laptop = "00ffffffffffff004d10f91400000000151e0104a51d12780ede50a3544c99260f505400000001010101010101010101010101010101283c80a070b023403020360020b410000018203080a070b023403020360020b410000018000000fe0056564b3859804c513133344e31000000000002410332001200000a010a20200080";
          home = "00ffffffffffff004c2d0e1036395743181e010380351e782a6595a854519c25105054bfef80714f81c0810081809500a9c0b3000101023a801871382d40582c45000f282100001e000000fd00324b1e5512000a202020202020000000fc00533234523335780a2020202020000000ff004834544e3630303238330a20200179020313b14690041f13120367030c0010000024011d00bc52d01e20b82855400f282100001e8c0ad090204031200c4055000f28210000188c0ad08a20e02d10103e96000f28210000182a4480a070382740302035000f282100001a0000000000000000000000000000000000000000000000000000000000000000000000007a";
          home2 = "00ffffffffffff0010ac99a04c524b38011a0104a5301b78e2ebf5a656519c26105054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c4500dd0c1100001e000000ff003239433239363132384b524c0a000000fc0044454c4c205032323134480a20000000fd00384c1e5311000a20202020202000f4";
          office = "00ffffffffffff004c2d700f59485843041f0104a55021783a46c5a5564f9b250f5054bfef80714f810081c081809500a9c0b3000101e77c70a0d0a0295030203a001d4d3100001a000000fd00324b1e7829000a202020202020000000fc005333344a3535780a2020202020000000ff0048344c523130313734360a202001f5020314f147901f041303125a2309070783010000023a801871382d40582c45001d4d3100001e584d00b8a1381440f82c45001d4d3100001e565e00a0a0a02950302035001d4d3100001a539d70a0d0a0345030203a001d4d3100001a00000000000000000000000000000000000000000000000000000000000000000000002a";
          bart = "00ffffffffffff001e6d010001010101011f010380a05a780aee91a3544c99260f5054a1080031404540614071408180d1c00101010131ce0046f0705a8020108a0040846300001e565e00a0a0a029503020350040846300001e000000fd0018781e873c000a202020202020000000fc004c472054562053534352320a2001fd02035ef15a0000101f00000413051403021220212215015d5e5f0000003f402c0957071507505707016704036e030c001000b83c2c00800102030068d85dc40178800b02e200cfe305c000e3060d01e20f33eb0146d000480b6a825e759400000000000000000000000000000000000000000000000000000000000000000048";
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
          "home2" = {
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
              DP-3 = home2;
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
                position = "1520x1440";
              };
              DP-1-1 = {
                enable = true;
                crtc = 1;
                rate = "49.99";
                mode = "3440x1440";
                position = "0x0";
              };
            };
            fingerprint = {
              DP-1-1 = office;
              eDP-1 = laptop;
            };
          };
          "bart" = {
            config = {
              eDP-1 = {
                enable = true;
                crtc = 0;
                primary = true;
                rate = "59.95";
                mode = "1920x1200";
                position = "0x0";
              };
              DP-1 = {
                enable = true;
                crtc = 1;
                rate = "49.99";
                mode = "1920x1080";
                position = "0x0";
              };
            };
            fingerprint = {
              eDP-1 = laptop;
              DP-1 = bart;
            };
          };
        };
      };
    };
  };
}
