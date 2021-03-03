{ config, lib, pkgs, stdenv, custompkgs, ... }: {
  options = {
    custom.zeroad = {
      enable = lib.mkOption {
        default = false;
        example = true;
      };
      asServer = lib.mkOption {
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf config.custom.zeroad.enable {

    hardware.opengl.enable = true;
    home-manager.users.rien = { pkgs, ... }: {
      home.packages = [ custompkgs.zeroad ];
    };
    networking.firewall = lib.mkIf config.custom.zeroad.asServer {
      allowedTCPPorts = [ 20595 ];
      allowedUDPPorts = [ 20595 ];
    };
    services.openssh.forwardX11 = lib.mkDefault config.custom.zeroad.asServer;
  };
}
