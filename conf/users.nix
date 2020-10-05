{ ... }:
let
  personal = import ./personal.secret.nix;
in
{
  users.users.root.openssh.authorizedKeys.keys = [ personal.pcKey ];
  users.users.root.extraGroups = [ "audio" ];
  users.users.rien = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" "audio" ];
    openssh.authorizedKeys.keys = [ personal.pcKey personal.mobileKey ];
  };
}
