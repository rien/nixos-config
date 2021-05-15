{ config, lib, pkgs, ... }:
let
  cfg = config.custom;
in {

  imports = [
    ./bash.nix
    ./docker.nix
    ./git.nix
    ./gnupg.nix
    ./graphical
    ./intellij.nix
    ./kitty.nix
    ./minidlna.nix
    ./mounts
    ./mail
    ./nextcloud.nix
    ./neovim.nix
    ./nginx
    ./pass.nix
    ./postfix
    ./ssh
    ./sshd.nix
    ./tor.nix
    ./transmission.nix
    ./ugent-vpn.nix
    ./wireless
    ./zeroad.nix
  ];

  options.custom = {
    user = lib.mkOption {
      example = "rien";
      default = "rien";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
    };

    extraSystemPackages = lib.mkOption {
      default = [];
      example = [ pkgs.unzip ];
    };

    extraHomePackages = lib.mkOption {
      default = [];
      example = [ pkgs.spotify-tui ];
    };
  };

  config = let
    personal = import ./personal.secret.nix;
  in {

    security.doas = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      acpi
      fd
      file
      jq
      lsof
      pciutils
      ripgrep
      strace
      unzip
      wget
      zip
      dnsutils
    ] ++ cfg.extraSystemPackages;

    systemd.extraConfig = ''
      DefaultTimeoutStopSec=5s
    '';

    # Don't wait for dhcpd when booting
    networking.dhcpcd.wait = "background";

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Brussels";

    users.users.root = {
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn chaos ];
    };

    users.users.${config.custom.user} = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" "audio" "input" "video" "graphical" "vboxusers"];
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn phone chaos ];
    };

    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.packages = with pkgs; [
        xdg-user-dirs
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
      ] ++ cfg.extraHomePackages;

      xdg = {
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
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableNixDirenvIntegration = true;
      };
    };

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
      optimise = {
        automatic = true;
        dates = [ "daily" ];
      };
    };

    boot.tmpOnTmpfs = true;
    nixpkgs.config.allowUnfree = true;
  };

}
