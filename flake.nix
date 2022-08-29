{
  description = "Nixos configuration";

  inputs = {
    #nixpkgs.url = "github:rien/nixpkgs/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    accentor = {
      url = "github:accentor/flake";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    accentor-api = {
      url = "github:accentor/api";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    accentor-web = {
      url = "github:accentor/web";
      inputs = {
        devshell.follows = "devshell";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
    mfauth = {
      url = "github:rien/mfauth/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    zeroad = {
      url = "github:chvp/0ad-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, agenix, musnix, mfauth, zeroad, accentor, accentor-web, accentor-api, devshell }:
    let
      version-suffix = nixpkgs.rev or (builtins.toString nixpkgs.lastModified);
      pkgsFor = system: import nixpkgs {
        inherit system;
      };
      mkSystem = system: hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Add extra input arguments to modules
          ({ config._module.args = { util = import ./util.nix; }; })

          # Secrets management
          agenix.nixosModules.age
          { environment.systemPackages = [ agenix.defaultPackage.${system} ]; }

          ({
            nixpkgs.overlays = [
              (self: super: {
                accentor-api = accentor-api.packages.${self.system}.default;
                accentor-web = accentor-web.packages.${self.system}.default;
                # Simple OAuth2 client
                mfauth = mfauth.defaultPackage.${system};
              })
              (final: prev: rec {
                  zathuraPkgs = rec {
                    inherit
                    (prev.zathuraPkgs)
                    gtk
                    zathura_djvu
                    zathura_pdf_poppler
                    zathura_ps
                    zathura_core
                    zathura_cb
                    ;

                    zathura_pdf_mupdf = prev.zathuraPkgs.zathura_pdf_mupdf.overrideAttrs (o: {
                      patches = [./packages/zathura.patch];
                    });

                    zathuraWrapper = prev.zathuraPkgs.zathuraWrapper.overrideAttrs (o: {
                      paths = [
                        zathura_core.man
                        zathura_core.dev
                        zathura_core.out
                        zathura_djvu
                        zathura_ps
                        zathura_cb
                        zathura_pdf_mupdf
                      ];
                    });
                  };

                  zathura = zathuraPkgs.zathuraWrapper;
                }
              )
            ];
          })

          # Accentor music server
          accentor.nixosModules.accentor

          musnix.nixosModules.musnix

          # Enable home-manager
          home-manager.nixosModules.home-manager

          # Set global home-manager options
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          })

          # Automatically load custom modules
          (./modules)

          # Expose the currently deployed nixpkgs in /etc/nixpkgs/
          ({ pkgs, ... }: {
            environment.etc."nixpkgs".source = (pkgs.runCommandNoCC "nixpkgs" { } ''
              cp -r ${nixpkgs} $out
              chmod 700 $out
              echo "${version-suffix}" > $out/.version-suffix
            '');
            nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];
          })

          # Load the config for our current machine
          (./. + "/machines/${hostname}")
        ];
      };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = pkgsFor system;
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [ nixpkgs-fmt ];
          };
        }) // {
      nixosConfigurations = {
        chaos = mkSystem "x86_64-linux" "chaos";
        space = mkSystem "x86_64-linux" "space";
        living = mkSystem "aarch64-linux" "living";
        entropy = mkSystem "aarch64-linux" "entropy";
      };
    };
}
