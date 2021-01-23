{ ... }:
let
  personal = import ./personal.secret.nix;
in
{
  users.users.root.openssh.authorizedKeys.keys = personal.pcKeys;
  users.users.root.extraGroups = [ "audio" ];
  users.users.rien = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" "audio" ];
    openssh.authorizedKeys.keys = personal.pcKeys ++ [ personal.mobileKey ];
  };
}
