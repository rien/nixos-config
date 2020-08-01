{ ... }:
let
  personal = import ./personal.secret.nix;
  pcKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBB/PjWusmMRRWdhSIMmrA/6s6hESBKVdvo6S26LUh1";
  mobileKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCrM17huf2hfyRGsi9cTF4725haRZuJwxjVWbuaRSmZd1ovWLAroZ1/2tg3x/uBbp61KmU6pISvAIEbJo51Xfgmz+TygpJ3z73x2FLs4Zv2VHMtNQzySUUaZfkKwzPZ0epNgublvXi4isI3u21wBjV+ufGzDfnwvGCJsgUq6TL1aggTSKC01MSZR1RcT8+KxunmuTsl06lAcB3ZeuxhCnA663EIbOMs3aJTYhDAsohAWELt5Boi0J2JsDXfHTa1Jtjp24DNfIxFHLoAIplU4kQPWn7zOxlk8sYmFasy6h6tC4eDOEyYSRm2XIFCUIauf2Yprh088PYWx8VrJl83EptLMYkKT2+aXd84S3kIn5+kRv98XSv13RHWfNPdankoCwvuxWQjD1wMJ9lgQB+KOnouSt0AtQjo6Q5RZfcoB0OOFwYQgxLWXN/n/CTC3Ll+kVW1x2QLr7KIklFrlqG7NYoLwrsH+7eI3HjW2ZNJWIwmvVCn1VTwr8n2veI1EMZ5M4ONOwKriksvGC13oOJUJi3CXEmyrdFxeJo0nCkGqrbTbrDrVIs9BaidfERPRnvLpHJhj5HJ7KHpY9Lgq4uFBznSHoNT1hWHRurPgyyj2t1fM5BmBxeGDQlVh2ci2/ep8Pc1U+jaeeX9Npho+LweX4MIc7hj32O2fCzeZ22RbeM1bw==";

in
{
  users.users.root.openssh.authorizedKeys.keys = [ pcKey ];
  users.users.rien = {
    isNormalUser = true;
    createHome = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ pcKey mobileKey ];
  };
}
