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
      "space.rxn.be" = {
        #serverAliases = [ "www.rxn.be" "rxn.be" ];
        useACMEHost = "rxn.be";
        addSSL = true;
        extraConfig = "default_type \"text/plain; charset=utf-8\";";
        locations."/" = {
          return = "200 \"\\n███████╗    ██████╗      █████╗      ██████╗    ███████╗\\n██╔════╝    ██╔══██╗    ██╔══██╗    ██╔════╝    ██╔════╝\\n███████╗    ██████╔╝    ███████║    ██║         █████╗\\n╚════██║    ██╔═══╝     ██╔══██║    ██║         ██╔══╝\\n███████║    ██║         ██║  ██║    ╚██████╗    ███████╗\\n╚══════╝    ╚═╝         ╚═╝  ╚═╝     ╚═════╝    ╚══════╝\\n\"";
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
