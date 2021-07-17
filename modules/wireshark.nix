{ config, lib, pkgs, stdenv, ... }: {
  options = {
    custom.wireshark = {
      enable = lib.mkOption {
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf config.custom.wireshark.enable {
    home-manager.users.${config.custom.user} = { pkgs, ... }: {
      home.packages = [ pkgs.wireshark ];
    };
    users.users.${config.custom.user}.extraGroups = [ "wireshark" ];
  };
}
