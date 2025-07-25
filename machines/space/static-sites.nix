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
        serverAliases = [ "www.rxn.be" "space.rxn.be" "49.12.7.126" ];
        useACMEHost = "rxn.be";
        addSSL = true;
        extraConfig = "default_type \"text/plain; charset=utf-8\";";
        locations."/" = {
          return = "200 \"\\n███████╗    ██████╗      █████╗      ██████╗    ███████╗\\n██╔════╝    ██╔══██╗    ██╔══██╗    ██╔════╝    ██╔════╝\\n███████╗    ██████╔╝    ███████║    ██║         █████╗\\n╚════██║    ██╔═══╝     ██╔══██║    ██║         ██╔══╝\\n███████║    ██║         ██║  ██║    ╚██████╗    ███████╗\\n╚══════╝    ╚═╝         ╚═╝  ╚═╝     ╚═════╝    ╚══════╝\\n\"";
        };
      };
      "rien.rxn.be" = {
        useACMEHost = "rxn.be";
        addSSL = true;
        locations."/" = {
          return = "302 https://ohai.social/@rien";
        };
      };
      "maertens.io" = {
        useACMEHost = "maertens.io";
        forceSSL = true;
        locations."/" = {
          return = "302 https://rien.maertens.gent";
        };
      };
      "rien.maertens.io" = {
        useACMEHost = "maertens.io";
        addSSL = true;
        locations."/" = {
          return = "302 https://rien.maertens.gent$request_uri";
        };
      };
      "maertens.gent" = {
        useACMEHost = "maertens.gent";
        forceSSL = true;
        locations."/" = {
          return = "302 https://rien.maertens.gent";
        };
      };
      "rien.maertens.gent" = {
        useACMEHost = "maertens.gent";
        addSSL = true;
        root = "/srv/webhost/maertens.gent";
      };
      "theatervolta.be" = {
        serverAliases = [ "www.theatervolta.be" "voltaprojects.be" "www.voltaprojects.be" ];
        useACMEHost = "theatervolta.be";
        forceSSL = true;
        root = "/srv/webhost/volta";
        locations."/brief" = {
          return = "302 https://drive.google.com/file/d/18QN07EKUBFHQrQINFj-5nEweMVgohnjh/view";
        };
        locations."/weekend/brief" = {
          return = "302 https://drive.google.com/file/d/18QN07EKUBFHQrQINFj-5nEweMVgohnjh/view";
        };
        locations."/weekend/inschrijven" = {
          return = "302 https://forms.gle/nTKDNnvZNjh5y5sJ7";
        };
      };
      "tryout.theatervolta.be" = {
        serverAliases = [ "tryout.voltaprojects.be" ];
        useACMEHost = "theatervolta.be";
        forceSSL = true;
        root = "/srv/webhost/volta-tryout";

      };
    };
  };
}
