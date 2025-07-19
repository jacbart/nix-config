{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  pnpm,
  git,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "headplane";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "tale";
    repo = finalAttrs.pname;
    tag = finalAttrs.version;
    hash = "sha256-2M0OpTIFfsF7khZviaAGIhKV7zEtX2ks6D6xfujmFMk=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm.configHook
    git
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-W0ba9xvs1LRKYLjO7Ldmus4RrJiEbiJ7+Zo92/ZOoMQ=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build
    pnpm prune --prod

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/headplane}
    cp -r {build,node_modules} $out/share/headplane/
    # https://code.tecosaur.net/tec/golgi/src/commit/53f3218c28168c7f619a1fd8de2093fe823d2f83/packages/headplane.nix
    sed -i 's;/build/source/node_modules/react-router/dist/development/index.mjs;react-router;' $out/share/headplane/build/headplane/server.js
    sed -i 's;define_process_env_default.PORT;process.env.PORT;' $out/share/headplane/build/headplane/server.js
    makeWrapper ${lib.getExe nodejs} $out/bin/headplane \
        --chdir $out/share/headplane \
        --set BUILD_PATH $out/share/headplane/build \
        --set NODE_ENV production \
        --add-flags $out/share/headplane/build/headplane/server.js
    runHook postInstall
  '';

  HEADSCALE_INTEGRATION = "proc";

  meta = with lib; {
    mainProgram = "headplane";
    description = "An advanced UI for juanfont/headscale";
    longDescription = ''
      Headscale is a self-hosted version of the Tailscale control server, however, it
      currently lacks a first-party web UI. Headplane aims to solve this issue by
      providing a GUI that can deeply integrate with the Headscale server. It's able
      to replicate nearly all of the functions of the official Tailscale SaaS UI.
    '';
    homepage = "https://github.com/tale/headplane";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ jacbart ];
    platforms = platforms.unix;
  };
})
