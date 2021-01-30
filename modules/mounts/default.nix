{ config, lib, ... }:
with lib;
let
  cfg = config.custom.mounts;
in {
  options.custom.mounts.enable = mkOption {
    default = false;
    example = true;
  };

  config = mkIf cfg.enable {

      fileSystems."/mnt/ugent" = {
          device = "//files.ugent.be/rbmaerte/";
          fsType = "cifs";
          options = let
              automountOpts = "x-systemd.automount,noauto,x-systemd.idle-timeout=10,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
          in [ "${automountOpts},credentials=/run/secrets/cifs-credentials,vers=3.0,sec=ntlmv2i,uid=rien" ];
      };

      age.secrets."cifs-credentials".file = ./cifs-credentials.age;
  };

}
