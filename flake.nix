{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs23.url = "github:NixOS/nixpkgs/5e4c2ada4fcd54b99d56d7bd62f384511a7e2593";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils/main";
      inputs.systems.follows = "systems";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
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

  outputs = { self, nixpkgs, nixpkgs23, nix-ld, home-manager, flake-utils, agenix, zeroad, devshell, hardware, systems }:
    let
      version-suffix = nixpkgs.rev or (builtins.toString nixpkgs.lastModified);
      pkgsFor = system: import nixpkgs {
        inherit system;
      };
      pkgsFor23 = system: import nixpkgs23 {
        inherit system;
      };
      mkSystem = system: hostname: extraModules: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Add extra input arguments to modules
          ({ config._module.args = { util = import ./util.nix; }; })

          nix-ld.nixosModules.nix-ld

          # Secrets management
          agenix.nixosModules.default

          ({
            nixpkgs.overlays = [
              (self: super: {
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
              (self: super: {
                postgresql_11 = (pkgsFor23 system).postgresql_11;
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
        living = mkSystem "aarch64-linux" "living" [];
        entropy = mkSystem "aarch64-linux" "entropy" [ hardware.nixosModules.raspberry-pi-4 ];
      };
    };
}
