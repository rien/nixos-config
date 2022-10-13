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
          alias = "/srv/webhost/rxn.be/";
        };
        locations."/brief" = {
          return = "302 https://drive.google.com/file/d/1kmKL7ir2gVoTCvGFehKEkNeuAD2wNXLG/view";
        };
        locations."/wild" = {
          return = "302 https://forms.gle/VUYhYB2fFq5XrPys7";
        };
      };
      "rien.maertens.io" = {
        useACMEHost = "maertens.io";
        addSSL = true;
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
      "tryout.theatervolta.be" = {
        serverAliases = [ "tryout.voltaprojects.be" ];
        useACMEHost = "theatervolta.be";
        forceSSL = true;
        root = "/srv/webhost/volta-tryout";
      };
    };
  };
}
