{ lib, buildNpmPackage, nodejs_20 }:

buildNpmPackage rec {
  pname = "copilot-cli";
  version = "0.0.409";

  src = ./.;

  npmDepsHash = "sha256-4aASD08B/a+au88f9BxNZsENNzed6FHO4oCfsK9wG1Y=";

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/copilot-cli/node_modules/.bin/copilot $out/bin/copilot
  '';

  meta = with lib; {
    description = "GitHub Copilot CLI";
    homepage = "https://github.com/github/copilot-cli";
    license = licenses.unfree; # It's proprietary software
    maintainers = with maintainers; [ ];
  };
}
