{ ...  }:
{
  # Define OpenSSH configuration
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
  };
}
