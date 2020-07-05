{ ... }:
let
  personal = import ./personal.secret.nix;
in
{
  users.users.root.openssh.authorizedKeys.keys = personal.sshkeys;
  users.users.rien = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = personal.sshkeys;
  };
}
