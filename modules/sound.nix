{ config, lib, pkgs, ... }: 
let
  cfg = config.custom.sound;
  json = pkgs.formats.json {};

in {
  options.custom.sound = {
    enable = lib.mkOption {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {

    sound.enable = true;

    services.avahi = {
      enable = true;
      nssmdns = true;
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };

    environment.etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';

      "pipewire/pipewire.d/90-raop-airplay.conf".source = json.generate "90-raop-airplay.conf" {
        context.modules = [{
          name = "libpipewire-raop-discover";
          args = {
            stream.rules = [{
              matches = [{
                raop.ip = "~.*";
              }];
              actions = {
                create-stream = {
                   #raop.password = ""
                   stream.props = {
                     #target.object = ""
                     #media.class = "Audio/Sink"
                   };
                };
              };
            }];
          };
        }];
      };
    };

    security.rtkit.enable = true;

    environment.systemPackages = with pkgs; [ sof-firmware ];

    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.packages = with pkgs; [ pulseaudioFull pavucontrol patchage ];

      # bluetooth MIDI controls
      services.mpris-proxy.enable = true;
    };
  };
}
