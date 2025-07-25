{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils/main";
      inputs.systems.follows = "systems";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
      };
    };
    zeroad = {
      url = "github:chvp/0ad-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, flake-utils, agenix, zeroad, devshell, hardware, systems }:
    let
      version-suffix = nixpkgs.rev or (builtins.toString nixpkgs.lastModified);
      pkgsFor = system: import nixpkgs {
        inherit system;
      };
      stablePkgsFor = system: import nixpkgs-stable {
        inherit system;
      };
      mkSystem = system: hostname: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Add extra input arguments to modules
          ({ config._module.args = {
            inherit self;
            util = import ./util.nix; };
          })

          # Secrets management
          agenix.nixosModules.default

          ({
            nixpkgs.overlays = [
              (self: super: {
                inkscape = (stablePkgsFor system).inkscape;

                # Actual budgetting server
                actual-server = self.callPackage ./packages/actual {};

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
        ] ++ extraModules;
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
        chaos = mkSystem "x86_64-linux" "chaos" [];
        space = mkSystem "x86_64-linux" "space" [];
        entropy = mkSystem "x86_64-linux" "entropy" [];
      };
    };
}
