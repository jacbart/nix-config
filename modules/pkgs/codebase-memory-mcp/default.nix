# codebase-memory-mcp — code-intelligence MCP server (DeusData).
#
# Packaged from the official GitHub release tarball rather than the upstream
# flake's source build: the release binary embeds CBM Lens and the `daemon`
# command (the source `default` build omits the UI), and a binary fetch avoids
# compiling the C11 source plus building the React frontend.
#
# See modules/home/apps/ai/codebase-memory.nix for the launchd agent that keeps
# the coordination daemon warm at login.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.12.1";

  # Release asset name + sha256 per host platform. The standard tarballs embed
  # CBM Lens; the `-ui-` variants are byte-identical legacy aliases.
  asset =
    {
      "aarch64-darwin" = {
        name = "codebase-memory-mcp-darwin-arm64.tar.gz";
        sha256 = "9bfcbe38414b47969a3e1d1c1999f5357409387c86fa3d24221b5458267660d2";
      };
      "x86_64-darwin" = {
        name = "codebase-memory-mcp-darwin-amd64.tar.gz";
        sha256 = "ca6e64397a8ae80cec898a8205a6aa16750ac798acc05a0c3ed983837944a581";
      };
      "aarch64-linux" = {
        name = "codebase-memory-mcp-linux-arm64.tar.gz";
        sha256 = "8575f126092660b93b170bdc2e06f3ef2dd28d3cc49ad6d0895dc3e4767219cd";
      };
      "x86_64-linux" = {
        name = "codebase-memory-mcp-linux-amd64.tar.gz";
        sha256 = "8453015145f072c1b9b019cbdd02cea8cc6f18cc5e116036dd20992631c638c7";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "codebase-memory-mcp: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "codebase-memory-mcp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${version}/${asset.name}";
    inherit (asset) sha256;
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 codebase-memory-mcp "$out/bin/codebase-memory-mcp"
    install -Dm644 LICENSE "$out/share/licenses/codebase-memory-mcp/LICENSE"
    install -Dm644 THIRD_PARTY_NOTICES.md "$out/share/licenses/codebase-memory-mcp/THIRD_PARTY_NOTICES.md"
    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP server that indexes codebases into a persistent knowledge graph (with CBM Lens)";
    homepage = "https://github.com/DeusData/codebase-memory-mcp";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "codebase-memory-mcp";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
    maintainers = with maintainers; [ jacbart ];
  };
}
