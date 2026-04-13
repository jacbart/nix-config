{
  pkgs,
  ...
}:
pkgs.buildGoModule rec {
  pname = "fern";
  version = "1.0.3-beta";
  src = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "InodeLabs";
    repo = "fern";
    rev = "369fc9585d459f38018507149ffe3c264d5d1a6f";
    hash = "sha256-PTcgiguZRLrpiw4E3g8VQoxxSwkcFi7DpFpQqbZ0/tk=";
  };

  proxyVendor = true;
  vendorHash = "sha256-uALSLAxMcz+18RbnZ2iyqjFM+KguskX7q3785BYa4E8=";

  ldflags = [
    "-s"
    "-w"
    "-X codeberg.org/InodeLabs/fern/internal/config.Version=${version}"
  ];

  postBuild = ''
    go run ./cmd/themegen
  '';

  postInstall = ''
    mkdir -p $out/share/fern/themes
    cp themes/*.json $out/share/fern/themes/
  '';

  meta = with pkgs.lib; {
    mainProgram = "fern";
    description = "Knowledge Management from your terminal";
    longDescription = ''
      A vim-style markdown notebook for the terminal. Create and manage notes,
      daily journals, and templates in a local vault with full-text search,
      wikilinks, and a keyboard-driven interface.
    '';
    homepage = "https://codeberg.org/InodeLabs/fern";
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
