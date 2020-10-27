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
  };

  config = {

    services.transmission = {
      enable = true;
      settings = {
        encryption = 1;
        rpc-url = "/";
        rpc-host-whitelist-enabled = false;
      };
    };

    systemd.services.transmission.serviceConfig.Environment="http_proxy=socks5://10.64.0.1";

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
        proxyPass = "http://127.0.0.1:9091";
      };

      locations."/web/" = {
        proxyPass = "http://127.0.0.1:9091";
      };

      locations."/upload" = {
        proxyPass = "http://127.0.0.1:9091";
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
