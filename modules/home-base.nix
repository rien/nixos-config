{ config, lib, pkgs, ... }:
{
  options.custom.user = lib.mkOption {
    example = "rien";
    default = "rien";
  };

  options.custom.extraHomePackages = lib.mkOption {
    default = [];
    example = [ pkgs.spotify-tui ];
  };

  config.home-manager.users.${config.custom.user} = {
    home.packages = with pkgs; [
      curlie
      exiftool
      htop
      httpie
      libqalculate
      ncdu
      nix-index
      nix-tree
      pv
      ranger
      screen
      bat
      xan
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      agenix
      xdg-user-dirs
    ] ++ config.custom.extraHomePackages;

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    # Garbage collect user profiles
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    xdg = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      userDirs = {
        desktop = "\$HOME/desktop";
        documents = "\$HOME/documents";
        download = "\$HOME/downloads";
        music = "\$HOME/music";
        pictures = "\$HOME/pictures";
        publicShare = "\$HOME/desktop";
        templates = "\$HOME/templates";
        videos = "\$HOME/videos";
      };
      configFile."mimeapps.list".force = true;
      mimeApps = {
        enable = true;
        defaultApplications = {
          "image/png" = [ "org.kde.okular.desktop" ];
          "image/jpg" = [ "org.kde.okular.desktop" ];
          "image/jpeg" = [ "org.kde.okular.desktop" ];
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];

          "text/html" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop" ];

          "x-scheme-handler/msteams" = [ "teams.desktop" ];
        };
      };
    };
  };
}
