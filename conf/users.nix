{ ... }:
let
  personal = import ./personal.secret.nix;
  sshkeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBB/PjWusmMRRWdhSIMmrA/6s6hESBKVdvo6S26LUh1"
  ];
in
{
  users.users.root.openssh.authorizedKeys.keys = sshkeys;
  users.users.rien = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = sshkeys;
  };
}
