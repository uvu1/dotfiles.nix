{
  buildNpmPackage,
  claude-code,
  codex,
  lib,
  makeWrapper,
  nodejs,
}:

buildNpmPackage {
  pname = "ai-adapter-acp";
  version = "0.1.0";

  src = ./.;

  npmDepsHash = "sha256-Xc71SulFkZUVvufHO2OrjPDWi3X8iCjifuVmt+QOTgs=";

  nativeBuildInputs = [
    makeWrapper
  ];

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    app_dir="$out/lib/ai-adapter-acp"
    mkdir -p "$app_dir" "$out/bin"
    cp -r node_modules package.json package-lock.json "$app_dir"/

    makeWrapper ${lib.getExe nodejs} "$out/bin/codex-acp" \
      --prefix PATH : ${lib.makeBinPath [ codex ]} \
      --add-flags "$app_dir/node_modules/@zed-industries/codex-acp/bin/codex-acp.js"

    makeWrapper ${lib.getExe nodejs} "$out/bin/claude-agent-acp" \
      --prefix PATH : ${lib.makeBinPath [ claude-code ]} \
      --add-flags "$app_dir/node_modules/@agentclientprotocol/claude-agent-acp/dist/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Fixed ACP adapter executables for Codex and Claude Agent";
    platforms = lib.platforms.linux;
  };
}
