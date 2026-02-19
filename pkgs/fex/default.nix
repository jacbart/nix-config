{
  pkgs,
  ...
}:
let
  zigEnv = pkgs.zig_0_13;
in
pkgs.stdenv.mkDerivation rec {
  name = "fex-${version}";
  version = "unstable-2025-05-18";
  src = pkgs.fetchFromGitHub {
    owner = "18alantom";
    repo = "fex";
    rev = "b77ab14e4f42b3f8f866028b7770b54a2a1c9680";
    sha256 = "sha256-h+M0Enyu1wmyZW+qPf6DHAS20D8J3WxYgFguo2SqsYg=";
  };

  nativeBuildInputs = [ zigEnv ];

  buildPhase = ''
    export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/.zig-cache"
    mkdir -p "$ZIG_GLOBAL_CACHE_DIR"
    zig build-exe -O ReleaseSafe main.zig
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp ./main $out/bin/fex
    cp ./shell/.fex.zsh $out/lib/fex.zsh
  '';

  meta = with pkgs.lib; {
    mainProgram = "fex";
    description = "A command-line file explorer prioritizing quick navigation";
    longDescription = ''
      fex is a command-line file explorer inspired by Vim, exa and fzf, built
      with quick exploration and navigation in mind.
    '';
    homepage = "https://github.com/18alantom/fex";
    license = with licenses; [ gpl3 ];
    maintainers = with maintainers; [ jacbart ];
    platforms = platforms.unix;
  };

}
