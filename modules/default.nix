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
    ./minidlna.nix
    ./mounts
    ./neovim.nix
    ./pass.nix
    ./ssh
    ./vpnc
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

    allowUnfree = lib.mkOption {
      default = [];
      example = [ pkgs.jetbrains.idea-ultimate ];
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
      unzip
      nix-tree
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
      extraGroups = [ "wheel" ] ++ lib.optionals cfg.graphical.enable [ "input" "video" "graphical" ];
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn phone chaos ];
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
