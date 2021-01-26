{ config, lib, pkgs, ... }:
{
  options.custom.graphical = {
    enable = lib.mkOption {
      default = false;
      example = true;
    };
  };

  config = lib.mkIf config.custom.graphical.enable {

    custom.allowUnfree = [ pkgs.symbola ];

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

    # Configure X session with Xmonad and Xmobar
    home-manager.users.rien = { pkgs, ... }: {
      home.file.".xinitrc".text = "source ~/.xsession";
      home.keyboard = {
        layout = "us";
        variant = "alt-intl";
        options = [ "caps:none" ];
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
