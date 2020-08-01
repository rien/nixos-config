{ ...  }:
{
  # Define OpenSSH configuration
  services.openssh = {
    enable = true;
    ports = [ 9450 ];
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };
}
