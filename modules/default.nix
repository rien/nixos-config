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
    ./kitty.nix
    ./minidlna.nix
    ./mounts
    ./mail
    ./neovim.nix
    ./nginx.nix
    ./pass.nix
    ./postfix
    ./ssh
    ./sshd.nix
    ./tor.nix
    ./transmission.nix
    ./vpnc
    ./wireless
    ./zeroad.nix
  ];

  options.custom = {
    hostname = lib.mkOption {
      type = lib.types.str;
    };

    extraPackages = lib.mkOption {
      default = [];
      example = [ pkgs.spotify-tui ];
    };

    allowUnfree = lib.mkOption {
      default = [];
      example = [ pkgs.jetbrains.idea-ultimate ];
    };
  };

  config = let
    personal = import ./personal.secret.nix;
  in {

    security.doas = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      pv
      jq
      acpi
      fd
      htop
      nix-index
      pciutils
      ranger
      ripgrep
      screen
      ncdu
      strace
      wget
      zip
      unzip
      nix-tree
      curlie
      httpie
      lsof
    ] ++ cfg.extraPackages;

    # Don't wait for dhcpd when booting
    networking.dhcpcd.wait = "background";

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Brussels";

    users.users.root = {
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn chaos ];
    };

    users.users.rien = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" "audio" "input" "video" "graphical" ];
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn phone chaos ];
    };

    home-manager.users.rien = { pkgs, ... }: {
      home.packages = with pkgs; [ xdg-user-dirs ];
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

    nixpkgs.config.allowUnfreePredicate = pkg:
    let
      allowed = builtins.map lib.getName cfg.allowUnfree;
    in builtins.elem (lib.getName pkg) allowed;
  };

}
