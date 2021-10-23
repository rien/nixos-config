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

  sound.enable = true;
  services.jack = {
    jackd.extraOptions = [ "-dalsa" ];
    jackd.enable = true;
    alsa.enable = false;
    loopback.enable = false;
  };

  users.users.rien.extraGroups = [ "audio" "jackaudio" "wheel" ];

  musnix.enable = true;
  musnix.alsaSeq.enable = true;
  musnix.kernel.realtime = true;
  musnix.kernel.packages = pkgs.linuxPackages-rt_latest;
  musnix.rtirq = {
    # highList = "snd_hrtimer";
    resetAll = 1;
    prioLow = 0;
    enable = true;
    nameList = "rtc0 snd";
  };

  systemd.services.fluidsynth = let
    synthconf = pkgs.writeText "fluidsynth-conf"
      ''
        router_clear
        router_begin note
        router_end

        # Invert sustain pedal
        router_begin cc
        router_par1 64 64 1 0
        router_par2 0 127 -1 127
        router_end

        router_begin prog
        router_end

        router_begin pbend
        router_end

        router_begin kpress
        router_end
      '';
  in {
    path = [ pkgs.fluidsynth ];
    environment = {
      LD_PRELOAD = "${pkgs.fluidsynth}/lib/libfluidsynth.so.2";
      JACK_NO_AUDIO_RESERVATION = "1";
      JACK_PROMISCUOUS_SERVER = "jackaudio";
    };
    serviceConfig = {
      LimitMEMLOCK = "256M";
      LimitNICE = -15;
      LimitRTPRIO = 99;
      User = "rien";
      Group = "jackaudio";
      Type = "simple";
      WorkingDirectory = "/home/rien";
      ExecStart = "${pkgs.fluidsynth}/bin/fluidsynth -f ${synthconf} -a jack -m jack -j -o midi.autoconnect=1 -is Nice-Steinway-v3.8.sf2";
    };
    after = [ "jack.service" ];
    wantedBy = [ "multi-user.target" ];
  };



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
      htop fluidsynth mpv libjack2 jack2
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

