# audiobookshelf-hardcover-sync — sidecar that pushes ABS listening progress,
# status, and library ownership to Hardcover.app on a schedule.
# Runs on maple next to Audiobookshelf (see modules/nixos/services/audiobookshelf.nix).
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "audiobookshelf-hardcover-sync";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "drallgood";
    repo = "audiobookshelf-hardcover-sync";
    rev = "v${version}";
    hash = "sha256-4iin6apySM1LppC7+t+BXGrBTlgEn4r0S4S2ZlT3xaA=";
  };

  vendorHash = "sha256-qtmNg229OY2eh8nj2lbv+cY+QiX4sUUdD9UiRoiSG10=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Syncs Audiobookshelf listening progress and library status to Hardcover";
    homepage = "https://github.com/drallgood/audiobookshelf-hardcover-sync";
    license = lib.licenses.asl20;
    mainProgram = "audiobookshelf-hardcover-sync";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
