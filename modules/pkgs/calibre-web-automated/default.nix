# Calibre-Web-Automated (CWA) — fork of janeczku/calibre-web with auto-ingest,
# metadata writeback, EPUB Fixer, Kobo sync improvements, etc.
#
# CWA hard-codes several absolute filesystem paths (/app/calibre-web-automated,
# /config, /calibre-library, /cwa-book-ingest) inherited from its Docker image.
# Rather than patch all of those out, the companion NixOS service in
# modules/nixos/services/calibre.nix uses systemd BindReadOnlyPaths / BindPaths
# to mount this $out tree and a writable state dir into those expected paths.
{
  lib,
  python3,
  fetchFromGitHub,
  fetchPypi,
  makeWrapper,
  calibre,
  kepubify,
  inotify-tools,
  imagemagick,
  ghostscript,
  file,
  sqlite,
  coreutils,
  procps,
}:

let
  py = python3.override {
    self = py;
    packageOverrides = pyfinal: pyprev: {
      goodreads = pyfinal.callPackage ./python-overrides/goodreads.nix { };
      flask-limiter = pyfinal.callPackage ./python-overrides/flask-limiter.nix { };
    };
  };

  pythonDeps = ps:
    with ps;
    [
      # core
      apscheduler
      babel
      flask-babel
      flask-principal
      flask
      iso-639
      pycountry
      pypdf
      pytz
      requests
      sqlalchemy
      tornado
      wand
      unidecode
      lxml
      flask-wtf
      chardet
      netifaces-plus
      urllib3
      flask-limiter
      regex
      bleach
      python-magic
      flask-httpauth
      cryptography
      certifi
      charset-normalizer
      idna
      tabulate
      qrcode
      polib

      # gdrive (pydrive2 currently broken in nixpkgs; GDrive sync feature unavailable
      # until packaged separately. Other deps kept since CWA imports them eagerly.)
      google-api-python-client
      gevent
      greenlet
      httplib2
      oauth2client
      uritemplate
      pyasn1-modules
      pyasn1
      pyyaml
      rsa

      # gmail
      google-auth-oauthlib

      # goodreads (custom override)
      goodreads
      levenshtein

      # ldap
      python-ldap
      flask-simpleldap

      # oauth
      flask-dance
      sqlalchemy-utils

      # metadata extraction
      rarfile
      scholarly
      markdown2
      html2text
      python-dateutil
      beautifulsoup4
      faust-cchardet
      py7zr
      mutagen

      # comics
      natsort
      comicapi

      # kobo
      jsonschema
      curl-cffi
    ];

  runtimeBins = [
    calibre
    kepubify
    inotify-tools
    imagemagick
    ghostscript
    file
    sqlite
    coreutils
    procps
  ];

in
py.pkgs.buildPythonApplication rec {
  pname = "calibre-web-automated";
  version = "4.0.6";

  src = fetchFromGitHub {
    owner = "crocodilestick";
    repo = "Calibre-Web-Automated";
    rev = "v${version}";
    hash = "sha256-4BvExsiSv9hyeLjWuRxR+xGW7Fz2eUEJo5piRgE/ang=";
  };

  format = "other";

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = pythonDeps py.pkgs;

  dontBuild = true;
  doCheck = false;
  pythonImportsCheck = [ ];

  installPhase = ''
    runHook preInstall

    install -d $out/share/calibre-web-automated
    cp -r cps cps.py kobo_sync_utils.py empty_library dirs.json babel.cfg \
      scripts koreader \
      $out/share/calibre-web-automated/

    # Mutable subdirs that CWA writes into at runtime.
    # Created as placeholders so systemd BindPaths can mount over them.
    install -d $out/share/calibre-web-automated/metadata_change_logs

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${py.interpreter} $out/bin/calibre-web-automated \
      --prefix PYTHONPATH : "$out/share/calibre-web-automated:$PYTHONPATH" \
      --prefix PATH : ${lib.makeBinPath runtimeBins} \
      --add-flags "$out/share/calibre-web-automated/cps.py"

    makeWrapper ${py.interpreter} $out/bin/cwa-watch-fallback \
      --add-flags "$out/share/calibre-web-automated/scripts/watch_fallback.py"

    makeWrapper ${py.interpreter} $out/bin/cwa-ingest-processor \
      --prefix PYTHONPATH : "$out/share/calibre-web-automated:$out/share/calibre-web-automated/scripts:$PYTHONPATH" \
      --prefix PATH : ${lib.makeBinPath runtimeBins} \
      --add-flags "$out/share/calibre-web-automated/scripts/ingest_processor.py"

    makeWrapper ${py.interpreter} $out/bin/cwa-convert-library \
      --prefix PYTHONPATH : "$out/share/calibre-web-automated:$out/share/calibre-web-automated/scripts:$PYTHONPATH" \
      --prefix PATH : ${lib.makeBinPath runtimeBins} \
      --add-flags "$out/share/calibre-web-automated/scripts/convert_library.py"

    makeWrapper ${py.interpreter} $out/bin/cwa-kindle-epub-fixer \
      --prefix PYTHONPATH : "$out/share/calibre-web-automated:$out/share/calibre-web-automated/scripts:$PYTHONPATH" \
      --prefix PATH : ${lib.makeBinPath runtimeBins} \
      --add-flags "$out/share/calibre-web-automated/scripts/kindle_epub_fixer.py"
  '';

  passthru = {
    python = py;
    inherit pythonDeps;
  };

  meta = with lib; {
    description = "Calibre-Web with automation: auto-ingest, metadata writeback, EPUB Fixer, enhanced Kobo sync";
    homepage = "https://github.com/crocodilestick/Calibre-Web-Automated";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "calibre-web-automated";
  };
}
