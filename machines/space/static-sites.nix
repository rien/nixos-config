{ ... }:
{
  users.users.webhost = {
    isNormalUser = true;
    createHome = true;
    home = /srv/webhost;
    openssh.authorizedKeys.keys = [ (import ../../conf/personal.secret.nix).pcKey ];
  };

  services.nginx = {
    virtualHosts = {
      "space.rxn.be" = {
        #serverAliases = [ "www.rxn.be" "rxn.be" ];
        enableACME = true;
        addSSL = true;
        extraConfig = "default_type \"text/plain; charset=utf-8\";";
        locations."/" = {
          return = "200 \"\\n███████╗    ██████╗      █████╗      ██████╗    ███████╗\\n██╔════╝    ██╔══██╗    ██╔══██╗    ██╔════╝    ██╔════╝\\n███████╗    ██████╔╝    ███████║    ██║         █████╗\\n╚════██║    ██╔═══╝     ██╔══██║    ██║         ██╔══╝\\n███████║    ██║         ██║  ██║    ╚██████╗    ███████╗\\n╚══════╝    ╚═╝         ╚═╝  ╚═╝     ╚═════╝    ╚══════╝\\n\"";
        };
      };
      "rien.maertens.io" = {
        enableACME = true;
        forceSSL = true;
        root = "/srv/webhost/maertens.io";
      };
      "maertens.io" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = "302 https://rien.maertens.io";
        };
      };
      "theatervolta.be" = {
        serverAliases = [ "www.theatervolta.be" "voltaprojects.be" "www.voltaprojects.be" ];
        enableACME = true;
        # useACMEHost = "theatervolta.be";
        forceSSL = true;
        root = "/srv/webhost/volta";
      };
    };
  };


  #security.acme.certs."theatervolta.be" = {
  #  dnsProvider = "hetzner";
  #  credentialsFile = "/etc/nixos/secrets/acme-credentials";
  #};
}
