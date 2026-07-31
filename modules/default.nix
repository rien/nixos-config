{ config, lib, pkgs, ... }:
let
  cfg = config.custom;
in {

  imports = [
    ./autoupgrade.nix
    ./actual.nix
    ./affine
    ./bash.nix
    ./docker.nix
    ./dodona-mailer
    ./dwarffortress.nix
    ./fava.nix
    ./git.nix
    ./gnupg.nix
    ./graphical
    ./home-base.nix
    ./home-assistant.nix
    ./music-assistant.nix
    ./intellij.nix
    ./kitty.nix
    ./mastodon.nix
    ./minidlna.nix
    ./mounts
    ./mail
    ./nextcloud.nix
    ./neovim.nix
    ./nginx
    ./pass.nix
    ./photoprism.nix
    ./postfix
    ./postgres.nix
    ./sound.nix
    ./ssh
    ./sshd.nix
    ./syncthing-client.nix
    ./syncthing-server.nix
    ./tailscale.nix
    ./tor.nix
    ./transmission.nix
    ./ugent-vpn.nix
    ./vaultwarden.nix
    ./wireless
    ./wireshark.nix
    ./wireguard.nix
    ./zeroad.nix
  ];

  options.custom = {
    hostname = lib.mkOption {
      type = lib.types.str;
    };

    extraSystemPackages = lib.mkOption {
      default = [];
      example = [ pkgs.unzip ];
    };

    stateVersion = lib.mkOption {
      example = "21.03";
    };


    permittedInsecurePackages = lib.mkOption {
      default = [];
    };
  };

  config = let
    personal = import ./personal.secret.nix;
  in {

    environment.systemPackages = with pkgs; [
      acpi
      fd
      file
      jq
      lsof
      htop
      pciutils
      ripgrep
      strace
      unzip
      wget
      zip
      dnsutils
      nmap
      binutils
      usbutils
      qsv
    ] ++ cfg.extraSystemPackages;

    systemd.settings.Manager = {
      DefaultTimeoutStopSec = "5s";
    };

    # Don't wait for dhcpd when booting
    networking.dhcpcd.wait = "background";

    i18n = {
      defaultLocale = "en_IE.UTF-8";
      #extraLocaleSettings = {
        # LC_TIME = "en_GB.UTF-8";
      #};
      supportedLocales = [
        "en_GB.UTF-8/UTF-8"
        "en_IE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
    };
    time.timeZone = "Europe/Brussels";

    users.users.root = {
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn chaos ];
    };

    users.users.${config.custom.user} = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" "audio" "input" "video" "graphical" "vboxusers" "dialout"];
      openssh.authorizedKeys.keys = with personal.sshKeys; [ octothorn phone chaos euphoria ];
    };

    home-manager.backupFileExtension = "hm-bak";

    home-manager.users.root = { ... }: {
      home.stateVersion = cfg.stateVersion;
    };

    home-manager.users.${config.custom.user} = { ... }: {
      home.stateVersion = cfg.stateVersion;
    };

    nix = {
      #package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
        substituters = https://cache.nixos.org https://nix-community.cachix.org
        trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
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

    nixpkgs.config = {
      permittedInsecurePackages = cfg.permittedInsecurePackages;
      allowUnfree = true;
    };

    boot.tmp.useTmpfs = true;
    boot.tmp.tmpfsSize = "75%";

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = cfg.stateVersion; # Did you read the comment?
  };

}
