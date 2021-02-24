{ config, lib, pkgs, stdenv, ... }:
let
  spidermonkey_78_6 = (pkgs.spidermonkey_78.overrideAttrs (oldAttrs: rec {
    version = "78.6.0";
    src = pkgs.fetchurl {
      url = "mirror://mozilla/firefox/releases/${version}esr/source/firefox-${version}esr.source.tar.xz";
      sha256 = "0lyg65v380j8i2lrylwz8a5ya80822l8vcnlx3dfqpd3s6zzjsay";
      postPatch = ''
        # This patch is a manually applied fix of
        #   https://bugzilla.mozilla.org/show_bug.cgi?id=1644600
        # Once that bug is fixed, this can be removed.
        # This is needed in, for example, `zeroad`.
        substituteInPlace js/public/StructuredClone.h \
             --replace "class SharedArrayRawBufferRefs {" \
                       "class JS_PUBLIC_API SharedArrayRawBufferRefs {"
      '';
    };
  }));
  spidermonkeyStdenv = stdenv // { spidermonkey_78 = spidermonkey_78_6; };
in {
  options = {
    custom.zeroad = {
      enable = lib.mkOption {
        default = false;
        example = true;
      };
      asServer = lib.mkOption {
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf config.custom.zeroad.enable {

    nixpkgs.overlays = [
      (self: super: {
        zeroadPackages = (super.zeroadPackages.override { newScope = (extra: self.newScope ({ stdenv = spidermonkeyStdenv; } // extra)); });
      })
    ];

    hardware.opengl.enable = true;
    home-manager.users.rien = { pkgs, ... }: {
      home.packages = [ pkgs.zeroad ];
    };
    networking.firewall = lib.mkIf config.custom.zeroad.asServer {
      allowedTCPPorts = [ 20595 ];
      allowedUDPPorts = [ 20595 ];
    };
    services.openssh.forwardX11 = lib.mkDefault config.custom.zeroad.asServer;
  };
}
