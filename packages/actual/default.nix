{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
  nodejs,
  runtimeShell,
}:
buildNpmPackage rec {
  pname = "actual-server";
  version = "24.1.0";

  src = fetchFromGitHub {
    owner = "actualbudget";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-GmKU1Q1XvRBXpsfldD5xL+ZmPlbe8fzqceaCJx7oc8I=";
  };

  npmDepsHash = "sha256-shgCkh5/L+PiOjnaT4T75A4AFazSB+QjHU//lQI5Dc8=";

  nativeBuildInputs = [
    python3
  ];

  postUnpack = ''
    rm -rf yarn.lock
  '';

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  postInstall = ''
    # Make an executable to run the server
    mkdir -p $out/bin
    cat <<EOF > $out/bin/actual-server
    #!${runtimeShell}
    exec ${nodejs}/bin/node $out/lib/node_modules/actual-sync/app.js "\$@"
    EOF
    chmod +x $out/bin/actual-server
  '';

  meta = with lib; {
    homepage = "https://github.com/actualbudget/actual-server";
    description = "Actual's server";
    changelog = "https://github.com/actualbudget/actual-server/releases/tag/v${version}";
    mainProgram = pname;
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
