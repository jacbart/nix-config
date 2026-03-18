{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  makeWrapper,
  openssl,
  pcre,
  zlib,
  luajit,
  luarocks,
  redis,
  which,
  git,
  unzip,
  gnused,
  coreutils,
  gnugrep,
  gawk,
  gnutar,
  gzip,
  curl,
  cacert,
}:

let
  openrestyVersion = "1.27.1.2";

  openresty = stdenv.mkDerivation rec {
    pname = "openresty";
    version = openrestyVersion;

    src = fetchurl {
      url = "https://openresty.org/download/openresty-${version}.tar.gz";
      sha256 = "sha256-dPB29+NksqmabF+btTHCdhDHiYWr6Va0QrGSoilfdUg=";
    };

    nativeBuildInputs = [ which ];
    buildInputs = [
      openssl
      pcre
      zlib
      luajit
    ];

    configureFlags = [
      "--prefix=${placeholder "out"}"
      "--with-http_ssl_module"
      "--with-http_v2_module"
      "--with-http_realip_module"
      "--with-http_stub_status_module"
      "--with-luajit"
    ];

    preConfigure = ''
      export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${luajit}/include"
      export NIX_LDFLAGS="$NIX_LDFLAGS -L${luajit}/lib"
    '';

    postInstall = ''
      ln -s $out/nginx/sbin/nginx $out/bin/openresty
      ln -s $out/bin/openresty $out/bin/nginx
    '';

    enableParallelBuilding = true;

    meta = with lib; {
      description = "Fast web app server by bundling NGINX with LuaJIT";
      homepage = "https://openresty.org";
      license = licenses.bsd2;
      platforms = platforms.all;
      maintainers = with maintainers; [ ];
    };
  };

  ginSrc = fetchFromGitHub {
    owner = "ostinelli";
    repo = "gin";
    rev = "cb35e87fa0671fcf25e5bce5cb9487dee8b497e2";
    sha256 = "sha256-VyCTsyrPO/zN4fo95SFgzMN6mPPOItWtBP3WyoNV3No=";
  };

  koreaderSyncSrc = fetchFromGitHub {
    owner = "koreader";
    repo = "koreader-sync-server";
    rev = "v2.0";
    sha256 = "sha256-l355M1Hn3gRZmEuRyF7RFMn7dNTrUKxCpV3PEfKAkn0=";
  };

  ginPatch = fetchurl {
    url = "https://raw.githubusercontent.com/koreader/koreader-sync-server/master/gin.patch";
    sha256 = "sha256-A8HaVjtEgU9dTZ4ciDw9QzOtdX29VbPy21/6XEPAchY=";
  };

in
stdenv.mkDerivation rec {
  pname = "koreader-sync-server";
  version = "2.0";

  src = koreaderSyncSrc;

  nativeBuildInputs = [
    makeWrapper
    luarocks
    git
    unzip
    gnused
    coreutils
    gnugrep
    gawk
    gnutar
    gzip
    curl
    cacert
  ];

  buildInputs = [
    openresty
    luajit
    openssl
    redis
  ];

  buildPhase = ''
    runHook preBuild

    # Set up luarocks environment
    export LUAROCKS_PREFIX="$TMPDIR/luarocks"
    mkdir -p "$LUAROCKS_PREFIX"
    export LUA_PATH="$LUAROCKS_PREFIX/share/lua/5.1/?.lua;$LUAROCKS_PREFIX/share/lua/5.1/?/init.lua;;"
    export LUA_CPATH="$LUAROCKS_PREFIX/lib/lua/5.1/?.so;;"

    # Set luarocks to use local tree
    mkdir -p "$LUAROCKS_PREFIX/etc/luarocks"
    cat > "$LUAROCKS_PREFIX/etc/luarocks/config.lua" << 'LUACONFIG'
    rocks_trees = {
      { name = "user", root = os.getenv("LUAROCKS_PREFIX") }
    }
    LUACONFIG
    export LUAROCKS_CONFIG="$LUAROCKS_PREFIX/etc/luarocks/config.lua"

    # Fetch and patch gin
    cp -r ${ginSrc} gin
    chmod -R +w gin
    cd gin
    patch -N -p1 < ${ginPatch} || true

    # Build and install gin
    luarocks make --tree="$LUAROCKS_PREFIX" 2>&1 || true
    cd ..

    # Install Lua dependencies
    luarocks install --tree="$LUAROCKS_PREFIX" luasocket 2>&1 || true
    luarocks install --tree="$LUAROCKS_PREFIX" luasec 2>&1 || true
    luarocks install --tree="$LUAROCKS_PREFIX" redis-lua 2>&1 || true

    # Verify installations
    echo "Installed rocks in $LUAROCKS_PREFIX:"
    ls -la "$LUAROCKS_PREFIX/share/lua/5.1/" 2>/dev/null || true
    ls -la "$LUAROCKS_PREFIX/lib/lua/5.1/" 2>/dev/null || true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/{bin,lib,share/koreader-sync-server}
    mkdir -p $out/share/koreader-sync-server/{app,config,db,lib}

    # Copy application code
    cp -r app/* $out/share/koreader-sync-server/app/
    cp -r config/* $out/share/koreader-sync-server/config/
    cp -r db/* $out/share/koreader-sync-server/db/
    cp -r lib/* $out/share/koreader-sync-server/lib/

    # Copy luarocks installed packages
    cp -r $LUAROCKS_PREFIX/share/lua/5.1/* $out/share/koreader-sync-server/lib/ 2>/dev/null || true
    cp -r $LUAROCKS_PREFIX/lib/lua/5.1/* $out/lib/ 2>/dev/null || true

    # Create wrapper scripts
    makeWrapper ${openresty}/bin/openresty $out/bin/openresty \
      --set LUA_PATH "$out/share/koreader-sync-server/lib/?.lua;$out/share/koreader-sync-server/lib/?/init.lua;;" \
      --set LUA_CPATH "$out/lib/?.so;;"

    # Create gin wrapper
    cat > $out/bin/gin << 'GINWRAPPER'
    #!/usr/bin/env bash
    export LUA_PATH="@out@/share/koreader-sync-server/lib/?.lua;@out@/share/koreader-sync-server/lib/?/init.lua;;"
    export LUA_CPATH="@out@/lib/?.so;;"
    export GIN_APP_ROOT="@out@/share/koreader-sync-server/app"

    cd "@out@/share/koreader-sync-server"

    if [ "$1" = "start" ]; then
      exec @out@/bin/openresty -p "@out@/share/koreader-sync-server" -c config/nginx.conf
    else
      echo "Usage: gin start"
      exit 1
    fi
    GINWRAPPER
    sed -i "s|@out@|$out|g" $out/bin/gin
    chmod +x $out/bin/gin

    # Create the main server wrapper
    makeWrapper $out/bin/gin $out/bin/koreader-sync-server \
      --set PATH "${
        lib.makeBinPath [
          openresty
          redis
          coreutils
          gnugrep
        ]
      }:$PATH" \
      --set GIN_ENV "production" \
      --set ENABLE_USER_REGISTRATION "true" \
      --chdir "$out/share/koreader-sync-server"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Self-hostable synchronization service for KOReader devices";
    longDescription = ''
      KOReader Sync Server is built on top of the Gin JSON-API framework 
      which runs on OpenResty and is entirely written in Lua. Users of 
      KOReader devices can register their devices to the synchronization 
      server and use the sync service to keep all reading progress 
      synchronized between devices.
    '';
    homepage = "https://github.com/koreader/koreader-sync-server";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
