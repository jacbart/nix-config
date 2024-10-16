{ lib
, pkgs
, rustPlatform
, fetchFromGitHub }:
rustPlatform.buildRustPackage {
    pname = "mazter";
    version = "1.0.0";

    buildInputs = []
    ++ lib.optionals pkgs.stdenv.isDarwin [
        pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    src = fetchFromGitHub {
        owner = "Canop";
        repo = "mazter";
        rev = "1757a3858a5def389182e6bfe059bf402d71b582";
        hash = "sha256-PLDhz9ge2O/HINnnHliMrS0NL8BCqOvOSgLPrdixbZw=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    meta = with lib; {
        description = "Mazes in your terminal";
        homepage = "https://github.com/Canop/mazter";
        license = licenses.mit;
        maintainers = with maintainers; [ jacbart ];
        mainProgram = "mazter";
    };
}
