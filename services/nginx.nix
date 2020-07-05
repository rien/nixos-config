{ ... }:
let
  personal = import ../conf/personal.secret.nix;
in
{
  services.nginx = {
    enabled = true;
  };

  security.acme = {
    acceptTerms = true;
    email = personal.email;
  };
}
