# Local rebuild of fern with a corrected vendorHash.
#
# The upstream fern flake (codeberg.org/InodeLabs/fern @ e662c0f) hardcodes
# vendorHash in its default.nix — not a callPackage parameter — so .override{}
# can't fix it. When the Go module proxy served a different subset, the FOD
# hash drifted (upstream pin: sha256-HaBIU…, actual: sha256-cswCL…). This
# rebuilds from the same locked source (inputs.fern.outPath) with the hash the
# build actually produces. Remove this module once upstream fixes the hash.
{
  lib,
  buildGoModule,
  fernSource,
  fernVersion ? "dev",
}:

buildGoModule rec {
  pname = "fern";
  version = fernVersion;

  src = lib.cleanSource fernSource;

  # Uses module cache directly rather than a vendor directory, which avoids
  # modules.txt compatibility issues across Go versions.
  proxyVendor = true;

  vendorHash = "sha256-cswCL34c2i7JGAD8ZIHkPJIdsRNgcSAoIKDiY7c2MeM=";

  ldflags = [
    "-s"
    "-w"
    "-X codeberg.org/InodeLabs/fern/internal/config.Version=${version}"
  ];

  preBuild = ''
    go generate ./...
  '';

  meta = {
    description = "Terminal markdown viewer and editor";
    homepage = "https://codeberg.org/InodeLabs/fern";
    license = lib.licenses.agpl3Only;
    mainProgram = "fern";
    platforms = lib.platforms.unix;
  };
}
