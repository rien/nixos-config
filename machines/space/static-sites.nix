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
        locations."/hupseflupse/" = {
          basicAuthFile = "/run/agenix/static-sites-auth";
          alias = "/srv/webhost/rxn.be/";
        };
        locations."/brief" = {
          return = "302 https://drive.google.com/file/d/14m9oOKiqOiBpkv1RzPFtqxegl1DkndL5/view";
        };
        locations."/elementen" = {
          return = "302 https://forms.gle/hefCh45VvBkJitGo8";
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
          return = "302 https://drive.google.com/file/d/14m9oOKiqOiBpkv1RzPFtqxegl1DkndL5/view";
        };
        locations."/elementen" = {
          return = "302 https://forms.gle/hefCh45VvBkJitGo8";
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
