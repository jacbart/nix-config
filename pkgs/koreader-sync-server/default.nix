{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  makeWrapper,
  openresty,
  luajit,
  luarocks,
  redis,
  git,
  unzip,
  gnused,
  coreutils,
  gnugrep,
}:

let
  ginSrc = fetchFromGitHub {
    owner = "ostinelli";
    repo = "gin";
    rev = "cb35e87fa0671fcf25e5bce5cb9487dee8b497e2";
    sha256 = "sha256-HUtqs1nx659eSpBupTGVyoe/BW5HmhJTaoIKLjIzidM=";
  };

  koreaderSyncSrc = fetchFromGitHub {
    owner = "koreader";
    repo = "koreader-sync-server";
    rev = "v2.0";
    sha256 = "sha256-KbRZ/KBGSXV01vJTAvPtvVE/mIvDvQ324eCLKi7QBU8=";
  };

  ginPatch = fetchurl {
    url = "https://raw.githubusercontent.com/koreader/koreader-sync-server/master/gin.patch";
    sha256 = "sha256-A8HaVjtEgU9dTZ4ciDw9QzOtdX29VbPy21/6XEPAchY=";
  };

in
stdenv.mkDerivation {
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
  ];

  buildInputs = [
    openresty
    luajit
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

    # Create openresty wrapper with correct Lua paths
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
