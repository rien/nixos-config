{ ... }:
let
  webdir = "/srv/webhost";
in {
  users.users.webhost = {
    isNormalUser = true;
    createHome = true;
    home = webdir;
    openssh.authorizedKeys.keys = with (import ../../modules/personal.secret.nix).sshKeys; [ chaos octothorn ];
  };

  system.activationScripts.make-webdir-world-readable = {
    text = ''
      chmod a+rx ${webdir}
    '';
  };

  services.nginx = {
    virtualHosts = {
      "rxn.be" = {
        serverAliases = [ "www.rxn.be" "space.rxn.be" ];
        useACMEHost = "rxn.be";
        addSSL = true;
        extraConfig = "default_type \"text/plain; charset=utf-8\";";
        locations."/" = {
          return = "200 \"\\n███████╗    ██████╗      █████╗      ██████╗    ███████╗\\n██╔════╝    ██╔══██╗    ██╔══██╗    ██╔════╝    ██╔════╝\\n███████╗    ██████╔╝    ███████║    ██║         █████╗\\n╚════██║    ██╔═══╝     ██╔══██║    ██║         ██╔══╝\\n███████║    ██║         ██║  ██║    ╚██████╗    ███████╗\\n╚══════╝    ╚═╝         ╚═╝  ╚═╝     ╚═════╝    ╚══════╝\\n\"";
        };
        locations."/vuur" = {
          return = "302 https://docs.google.com/forms/d/e/1FAIpQLSeTltrQAZxYmmoov4jijEMzJy5Bg4dfnRW0PW_56lgYqLqW4w/viewform";
        };
        locations."/zwart-wit" = {
          return = "302 https://docs.google.com/forms/d/e/1FAIpQLSeTltrQAZxYmmoov4jijEMzJy5Bg4dfnRW0PW_56lgYqLqW4w/viewform";
        };
        locations."/zwartwit" = {
          return = "302 https://docs.google.com/forms/d/e/1FAIpQLSeTltrQAZxYmmoov4jijEMzJy5Bg4dfnRW0PW_56lgYqLqW4w/viewform";
        };
        locations."/brief" = {
          return = "302 https://drive.google.com/file/d/1JsMAJbnwWslBfpXe05gNvSlGi5M0wNNe/view";
        };
      };
      "rien.maertens.io" = {
        useACMEHost = "maertens.io";
        forceSSL = true;
        root = "/srv/webhost/maertens.io";
      };
      "maertens.io" = {
        useACMEHost = "maertens.io";
        forceSSL = true;
        locations."/" = {
          return = "302 https://rien.maertens.io";
        };
      };
      "theatervolta.be" = {
        serverAliases = [ "www.theatervolta.be" "voltaprojects.be" "www.voltaprojects.be" ];
        useACMEHost = "theatervolta.be";
        forceSSL = true;
        root = "/srv/webhost/volta";
      };
    };
  };
}
