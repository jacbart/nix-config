{
  lib,
  pkgs,
  rustPlatform,
  fetchFromGitHub,
}:
let
  name = "mazter";
  inherit (lib) licenses maintainers optionals;
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.darwin.apple_sdk) frameworks;
in
rustPlatform.buildRustPackage rec {
  pname = name;
  version = "1.0.0";

  buildInputs = optionals isDarwin [
    frameworks.SystemConfiguration
  ];

  src = fetchFromGitHub {
    owner = "Canop";
    repo = name;
    rev = "1757a3858a5def389182e6bfe059bf402d71b582";
    hash = "sha256-PLDhz9ge2O/HINnnHliMrS0NL8BCqOvOSgLPrdixbZw=";
  };

  cargoLock.lockFile = builtins.toPath "${src}/Cargo.lock";

  meta = {
    description = "Mazes in your terminal";
    homepage = "https://github.com/Canop/${name}";
    license = licenses.mit;
    maintainers = with maintainers; [ jacbart ];
    mainProgram = name;
  };
}
