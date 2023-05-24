{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:rien/nixpkgs/master";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils/main";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
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
    };
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zeroad = {
      url = "github:chvp/0ad-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, agenix, musnix, mfauth, zeroad, devshell }:
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
          agenix.nixosModules.default

          ({
            nixpkgs.overlays = [
              (self: super: {
                # Simple OAuth2 client
                mfauth = mfauth.defaultPackage.${system};
                # Agenix secrets
                agenix = agenix.packages.${system}.default;
                lego = self.symlinkJoin {
                  name = "lego";
                  paths = [ super.lego ];
                  buildInputs = [ self.makeWrapper ];
                  postBuild = ''
                    wrapProgram $out/bin/lego \
                      --set LEGO_DISABLE_CNAME_SUPPORT true
                  '';
                };
              })
            ];
          })

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
            environment.etc."nixpkgs".source = (pkgs.runCommand "nixpkgs" { } ''
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
