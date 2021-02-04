{ config, lib, pkgs, ... }:

{
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
    #custom.zfs.homeLinks = [
    #  { path = ".config/0ad"; type = "cache"; }
    #];

    nixpkgs.config.permittedInsecurePackages = [
      "spidermonkey-38.8.0"
    ];

    hardware.opengl.enable = true;
    home-manager.users.rien = { pkgs, ... }: {
      home.packages = [ pkgs.zeroad ];
    };
    networking.firewall = lib.mkIf config.custom.zeroad.asServer {
      allowedTCPPorts = [ 20595 ];
      allowedUDPPorts = [ 20595 ];
    };
    services.openssh.forwardX11 = lib.mkDefault config.custom.zeroad.asServer;
  };
}
