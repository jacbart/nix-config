{ lib
, pkg-config
, glib
, gtk3
, gdk-pixbuf
, openssl
, libsoup_3
, fetchFromGitHub
, rustPlatform
, webkitgtk_4_1
, xdotool
, ...
}:
let
  inherit (lib) licenses maintainers;
in
rustPlatform.buildRustPackage rec {
  pname = "ebou";
  version = "0.2.1-rc";

  nativeBuildInputs = [
    glib
    gdk-pixbuf
    gtk3
    pkg-config
  ];

  buildInputs = [
    openssl
    libsoup_3
    glib
    gdk-pixbuf
    gtk3
    webkitgtk_4_1
    xdotool
  ];

  src = fetchFromGitHub {
    owner = "terhechte";
    repo = pname;
    # tag = version;
    rev = "47f62585150d1dce80952b5eecac23416fd98f72";
    hash = "sha256-Z0eOiBw1bOUIRX1BuwKXed+6OA0zK8djy8NiKPNBHRw=";
  };

  cargoLock = {
    lockFile = builtins.toPath "${src}/Cargo.lock";
    outputHashes = {
      "cacao-0.3.2" = "sha256-vnqPclVSsgbfNeW9sGhMqS9IAy16c2gc8AuBRiX9+Ow=";
      "dioxus-0.3.2" = "sha256-PIG/LzNqhnqTD5N2E+Alv9zwJBDTrtkz7M234ZUctwQ=";
      "megalodon-0.6.1" = "sha256-dCD+2LgNUXIVH7OusGc6mWKNQ29mEzlhnzJysUg56bs=";
      "muda-0.4.0" = "sha256-8dKgii5caxTUWpi2em34158cM+817Tv+zCPMQH1tt38=";
      "navicula-0.1.0" = "sha256-O8G4mEy2ok3WcYQJ87DSJPtUIJIFbRnvYmrIFjeVFKw=";
    };
  };

  meta = {
    mainProgram = pname;
    description = "A cross platform Mastodon Client written in Rust";
    homepage = "https://github.com/terhechte/Ebou";
    license = licenses.gpl3;
    maintainers = with maintainers; [ jacbart ];
  };
}
