{ config, lib, ... }:
with lib;
let
  personal = import ../../modules/personal.secret.nix;
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
    users.users.nginx.extraGroups = [ "acme" ];

    age.secrets."hetzner-api-key" = {
      file = ./hetzner-api-key.age;
      owner = "acme";
    };

    security.acme = {
      acceptTerms = true;
      email = personal.email;
      certs = {
        "maertens.io" = {
          dnsProvider = "hetzner";
          credentialsFile = "/run/secrets/hetzner-api-key";
          extraDomainNames = [ "*.maertens.io" ];
        };
        "rxn.be" = {
          dnsProvider = "hetzner";
          credentialsFile = "/run/secrets/hetzner-api-key";
          extraDomainNames = [ "*.rxn.be" ];
        };
        "theatervolta.be" = {
          dnsProvider = "hetzner";
          credentialsFile = "/run/secrets/hetzner-api-key";
          extraDomainNames = [ "*.theatervolta.be" "voltaprojects.be" "*.voltaprojects.be" ];
        };
      };
    };

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;

      appendHttpConfig = ''
        add_header "Permissions-Policy" "interest-cohort=()";
        proxy_headers_hash_bucket_size 64;
      '';
    };
  };
}
