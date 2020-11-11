{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.custom.transmission;
  staticFiles = "${pkgs.transmission}/share/transmission/web/";
in
{
  options.custom.transmission = {
    domain = mkOption {
      type = types.str;
    };
    download-dir = mkOption {
      type = types.str;
    };
    incomplete-dir = mkOption {
      type = types.str;
    };
    port = mkOption {
      type = types.port;
      default = 51413;
    };
    namespace = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
    rpc-whitelist = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
    rpc-bind-address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };
  };

  config = {

    networking.firewall.allowedTCPPorts = [ cfg.port ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    services.transmission = {
      enable = true;
      settings = {
        peer-port = cfg.port;
        download-dir = cfg.download-dir;
        incomplete-dir = cfg.incomplete-dir;
        encryption = 2;
        rpc-url = "/";
        rpc-bind-address = cfg.rpc-bind-address;
        rpc-host-whitelist-enabled = false;
        rpc-whitelist = cfg.rpc-whitelist;
      };
    };

    systemd.services.transmission.serviceConfig.NetworkNamespacePath= mkIf (cfg.namespace != null) "/var/run/netns/${cfg.namespace}";

    services.nginx.virtualHosts."${cfg.domain}" = {

      enableACME = true;
      forceSSL = true;

      basicAuthFile = /etc/nixos/secrets/transmission-basic-auth;

      extraConfig = "
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-NginX-Proxy true;
      proxy_http_version 1.1;
      proxy_set_header Connection \"\";
      proxy_pass_header X-Transmission-Session-Id;
      add_header   Front-End-Https   on;
      ";

      locations."/" = {
        return = "302 http://\$server_name/web";
      };

      locations."/rpc" = {
        proxyPass = "http://${cfg.rpc-bind-address}:9091";
      };

      locations."/web/" = {
        proxyPass = "http://${cfg.rpc-bind-address}:9091";
      };

      locations."/upload" = {
        proxyPass = "http://${cfg.rpc-bind-address}:9091";
      };

      locations."/web/style/" = {
        alias = "${staticFiles}/style/";
      };

      locations."/web/javascript/" = {
        alias = "${staticFiles}/javascript/";
      };

      locations."/web/images/" = {
        alias = "${staticFiles}/images/";
      };
    };

  };

}
