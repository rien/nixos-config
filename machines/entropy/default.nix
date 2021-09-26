{ lib, config, pkgs, ... }:
let
  secret = import ./secret.nix;
in
{
  imports =
    [
      ./motd.nix
      ./hardware-configuration.nix
    ];

  age.secrets = {
    "hetzner-api-key" = {
      file = ./hetzner-api-key.age;
      owner = "acme";
    };
  };

  system.activationScripts.users.supportsDryActivation = lib.mkForce false;

  musnix.enable = true;
  musnix.kernel.realtime = true;
  musnix.kernel.packages = pkgs.linuxPackages-rt_latest;
  musnix.rtirq = {
    # highList = "snd_hrtimer";
    resetAll = 1;
    prioLow = 0;
    enable = true;
    nameList = "rtc0 snd";
  };

  systemd.user.services = {
    fluidsynth = {
      path = [ pkgs.fluidsynth ];
      environment = {
        LD_PRELOAD = "${pkgs.fluidsynth}/lib/libfluidsynth.so.2";
      };
      serviceConfig = {
        LimitMEMLOCK = "256M";
        LimitNICE = -15;
        LimitRTPRIO = 99;
        Type = "simple";
        WorkingDirectory = "/home/rien";
        ExecStart = "${pkgs.fluidsynth}/bin/fluidsynth -a jack -m jack -j -o midi.autoconnect=1 -is Nice-Steinway-v3.8.sf2";
      };
    };
  };

  sound.enable = true;
  services.jack = {
    jackd.enable = true;
    alsa.enable = false;
    loopback.enable = true;
  };

  users.users.rien.extraGroups = [ "audio" "jackaudio" "wheel" ];


  custom = {
    bash.enable = true;
    neovim.enable = true;
    sshd.enable = true;
    nginx = {
      enable = true;
      dnsCredentialsFile = "/run/secrets/hetzner-api-key";
      certificateDomains = [{
        domain = "entropy.rxn.be";
        extra = [ "home.rxn.be" ];
      }];
    };

    home-assistant = {
      enable = true;
      hostname = "home.rxn.be";
      acmeHost = "entropy.rxn.be";
    };

    extraSystemPackages = with pkgs; [
      htop
    ];

    wireless = {
      enable = true;
      device = "wlan0";
    };
  };

  networking.hostName = "entropy";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # Don't change this.
  # See https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "21.11";
}

