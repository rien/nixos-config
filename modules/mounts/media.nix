{ pkgs, config, lib, ... }:
with lib;
let
  secret = ./secret.nix;
  cfg = config.custom.mounts.media;
in {
  options.custom.mounts.storage = {
    enable = mkOption {
      default = false;
      example = true;
    };

    mountPoint = mkOption {
      default = "/media/"
    };

    identityFile = mkOption {
      type = t.path;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ sshfs ];
    fileSystems = {
      "${mountPoint}" = {
        device = secret.mediaDevice;
        fsType = "fuse.sshfs";
        options = [
          "ro",
          "transform_symlinks"
          "_netdev"
          "reconnect"
          "allow_other",
          "identityfile=${cfg.identityFile}"
          "uid=${cfg.user}",
        ];
      };
  };
};
