{ ... }:
let
  personal = import ../conf/personal.secret.nix;
in
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    email = personal.email;
  };

  services.nginx = {
    enable = true;
  };
}
