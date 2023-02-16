{ config, lib, pkgs, stdenv, ... }: {
  options = {
    custom.zeroad = {
      enable = lib.mkOption {
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf config.custom.zeroad.enable {

    hardware.opengl.enable = true;
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.packages = [ pkgs.zeroad ];
    };
  };
}
