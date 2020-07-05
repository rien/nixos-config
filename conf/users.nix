{ ... }:
let
  secrets = import ./secrets.nix;
in
{
  users.users.root.openssh.authorizedKeys.keys = secrets.sshkeys;
  users.users.rien = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = secrets.sshkeys;
  };
}
