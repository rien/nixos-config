{ pkgs, config, lib, ... }:
with lib;
let
  secret = import ./secret.nix;
  cfg = config.custom.mounts.media;
in {
  options.custom.mounts.media = {
    enable = mkOption {
      default = false;
      example = true;
    };

    mountPoint = mkOption {
      default = "/media";
    };

    identityFile = mkOption {
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ sshfs ];
    fileSystems = {
      "${cfg.mountPoint}" = {
        device = secret.mediaDevice;
        fsType = "fuse.sshfs";
        options = [
          "ro"
          "transform_symlinks"
          "_netdev"
          "reconnect"
          "allow_other"
          "identityfile=${cfg.identityFile}"
          #"uid=${cfg.user}",
        ];
      };
    };
  };
}
