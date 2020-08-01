{ ... }:
{
  services.transmission = {
    enable = true;
    settings = {
      rpc-url = "/";
      rpc-host-whitelist-enabled = false;
    };
  };

  systemd.services.transmission.serviceConfig.Environment="http_proxy=socks5://10.64.0.1";

  services.nginx.virtualHosts."transmission.rxn.be" = {

    enableACME = true;
    forceSSL = true;

    basicAuthFile = /etc/nixos/services/transmission/basicAuth.secret;

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

    /*locations."/web/style/" = {
      alias = "/usr/share/transmission/web/style/";
    };

    locations."/web/javascript/" = {
      alias = "/usr/share/transmission/web/javascript/";
    };

    locations."/web/images/" = {
      alias = "/usr/share/transmission/web/images/";
    };*/
  };
}
