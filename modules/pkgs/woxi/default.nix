{
  lib,
  pkgs,
  rustPlatform,
  inputs,
  git,
}:

rustPlatform.buildRustPackage rec {
  pname = "woxi";
  version = "0.2.0";

  src = inputs.woxi;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "astro-float-0.9.5" = "sha256-j1cuWBYrOUIjyrNch1VxYPEXdMBP8d+mo1ag8FS6B08=";
      "astro-float-num-0.3.6" = "sha256-j1cuWBYrOUIjyrNch1VxYPEXdMBP8d+mo1ag8FS6B08=";
    };
  };

  nativeBuildInputs = [
    git
    pkgs.lld
  ];

  cargoBuildFlags = [
    "--bin"
    "woxi"
  ];

  doCheck = false;

  meta = {
    description = "Interpreter for a subset of the Wolfram Language";
    homepage = "https://github.com/ad-si/Woxi";
    license = lib.licenses.agpl3Plus;
    mainProgram = "woxi";
    maintainers = with lib.maintainers; [ ];
  };
}
