{ config, lib, pkgs, ... }:
let
  cfg = config.custom;
in {

  imports = [
    ./bash.nix
    ./git.nix
    ./gnupg.nix
    ./graphical
    ./kitty.nix
    ./neovim.nix
    ./pass.nix
    ./ssh
    ./wireless
  ];

  options.custom = {
    hostname = lib.mkOption {
      type = lib.types.str;
    };

    extraPackages = lib.mkOption {
      default = [];
      example = [ pkgs.spotify-tui ];
    };
  };

  config = let
    personal = import ./personal.secret.nix;
  in {

    environment.systemPackages = with pkgs; [
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
    ] ++ cfg.extraPackages;

    # Don't wait for dhcpd when booting
    networking.dhcpcd.wait = "background";

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Brussels";

    users.users.root = {
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn ];
    };

    users.users.rien = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" ] ++ lib.optionals cfg.graphical.enable [ "input" "video" "graphical" ];
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn phone ];
    };

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "symbola"
    ];
  };

}
