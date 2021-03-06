{ pkgs, ... }:
let
  keys = import ./df-keys.secret.nix;
  username = "df";
in
{

  services.openssh.extraConfig = ''
  Match User ${username}
      PermitTunnel no
      GatewayPorts no
      AllowAgentForwarding no
      AllowTcpForwarding no
  '';

  # programs.firejail.enable = true;

  nixpkgs.config.allowUnfree = true;
  users.users."${username}" = {
    isNormalUser = true;
    createHome = true;
    openssh.authorizedKeys.keys = keys;
    shell =
      let
        # firejail = "${pkgs.firejail}/bin/firejail -c --noprofile --net=none --shell=none --";
        abduco = "${pkgs.abduco}/bin/abduco -lA df";
        df = "${pkgs.dwarf-fortress.override { enableSound = false; enableTextMode = true; }}/bin/dwarf-fortress";
        df-shell = pkgs.writeShellScriptBin "df-shell" "${abduco} ${df}";
      in
        df-shell.overrideAttrs (old: { passthru = { shellPath = "/bin/df-shell"; }; });
  };

}
