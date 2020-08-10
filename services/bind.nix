{ ... }:
{
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.bind = {
    enable = true;
    zones = [
      {
        file = "/etc/nixos/zones/theatervolta.be.zone";
        name = "theatervolta.be";
      }
    ];
  };
}
