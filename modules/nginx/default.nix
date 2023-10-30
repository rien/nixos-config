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

    certificateDomains = mkOption {
      default = [];
      example = [
        {
          domain = "example.com";
          extra = [ "a.example.com" "b.example.com" ];
          dns = {
            dnsProvider = "mydns";
            dnsCredentialsFile = "/run/agenix/dns-api-key";
          };
        }
      ];
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    users.users.nginx.extraGroups = [ "acme" ];

    security.acme = {
      acceptTerms = true;
      defaults.email = personal.email;

      certs = builtins.listToAttrs (map
        (item: {
          name = item.domain;
          value = {
            inherit (item.dns) dnsProvider environmentFile;
            extraDomainNames = item.extra;
          };
        })
        cfg.certificateDomains
      );
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
