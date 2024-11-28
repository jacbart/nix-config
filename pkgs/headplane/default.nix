{ stdenv
, lib
, fetchFromGitHub
, nodejs_20
, pnpm_9
, ...
}:
stdenv.mkDerivation (finalAttrs: rec {
  pname = "headplane";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "tale";
    repo = "headplane";
    rev = version;
    sha256 = "sha256-o/lQQJxSPPnBAKIQ0J3EbZN1ysqADT1j2xM5bAgPNQA=";
  };

  nativeBuildInputs = [
    nodejs_20
    pnpm_9.configHook
  ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-RcuYheZRn/4Y5L93LBiYCXs5hymcfzuYD3o+UNtzTDo=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    chmod u+x ./build/headplane/server.js

    runHook postBuild
  '';

  installPhase =
    ''
      mkdir -p $out/{src,bin}

      cp -R ./build $out/src/
      cp -R ./node_modules $out/src/
      echo '{"type":"module"}' > $out/src/package.json
    ''
    + ''
      cat >> $out/bin/headplane << 'END'
      #!/usr/bin/env bash
      cd $(direnv "$0")/../src
      node ./build/headplane/server.js
      END

      chmod u+x $out/bin/headplane
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
