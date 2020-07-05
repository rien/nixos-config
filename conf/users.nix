{ ... }:
let
  keys = import ./keys.secret.nix;
in
{
  users.users.root.openssh.authorizedKeys.keys = keys.sshkeys;
  users.users.rien = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = keys.sshkeys;
  };
}
