{ config, lib, ... }:
with lib;
let
  personal = import ../modules/personal.secret.nix;
  cfg = config.custom.nginx;
in
{
  options.custom.nginx = {
    enable = mkOption {
      default = false;
      example = true;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      email = personal.email;
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
    };
  };
}
