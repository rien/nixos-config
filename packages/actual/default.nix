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
  version = "24.7.0";

  src = fetchFromGitHub {
    owner = "actualbudget";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-WpHjXrofOHYr7CiodWzoE688R1pbDPbVCA4aSXMolNM=";
  };

  npmDepsHash = "sha256-fF9cE5rBt9MAnPFdMPCRbDo1jIhyOg15B5IXlZuqoTY=";

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
