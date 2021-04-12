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
          "x-systemd.automount"
          "noauto,x-systemd.idle-timeout=10"
          "x-systemd.device-timeout=5s"
          "x-systemd.mount-timeout=5s"
          "ro"
          "transform_symlinks"
          "_netdev"
          "reconnect"
          "identityfile=${cfg.identityFile}"
          "uid=${config.custom.user}"
          "gid=users"
        ];
      };
    };
  };
}
