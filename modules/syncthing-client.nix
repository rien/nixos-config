{ config, lib, ... }:
let
  cfg = config.custom.syncthing-client;
in {
  options.custom.syncthing-client.enable = lib.mkOption {
    default = false;
    example = true;
  };

  config = lib.mkIf cfg.enable {
    networking.hosts = {
      "127.0.0.1" = [ "syncthing.local" ];
    };
    home-manager.users.${config.custom.user} = { ... }: {
      services.syncthing.enable = true;
    };
  };
}
