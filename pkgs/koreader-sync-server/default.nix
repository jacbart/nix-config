{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  makeWrapper,
  openresty,
  luajit,
  luajitPackages,
  redis,
  git,
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

  redisLuaSrc = fetchFromGitHub {
    owner = "nrk";
    repo = "redis-lua";
    rev = "v2.0.4";
    sha256 = "sha256-716yWMrDj0rwhCGebE75b0oRwH5kwvh55WmbqCEhL0E=";
  };

  # Create a luajit with required packages
  luajitWithPackages = luajit.withPackages (
    ps: with ps; [
      luasocket
      luasec
    ]
  );

in
stdenv.mkDerivation {
  pname = "koreader-sync-server";
  version = "2.0";

  dontUseCmakeConfigure = true;

  src = koreaderSyncSrc;

  nativeBuildInputs = [
    makeWrapper
    git
    gnused
    coreutils
    gnugrep
  ];

  buildInputs = [
    openresty
    luajitWithPackages
    redis
  ];

  buildPhase = ''
    runHook preBuild

    # Create directories for gin and other manual deps
    mkdir -p $out/share/koreader-sync-server/lib

    # Fetch and patch gin framework
    cp -r ${ginSrc} gin-src
    chmod -R +w gin-src
    cd gin-src
    patch -N -p1 < ${ginPatch} || true

    # Install gin manually to our lib directory
    # Gin is a pure Lua framework, so we just need to copy the lua files
    cp -r lib/* $out/share/koreader-sync-server/lib/ 2>/dev/null || true
    cp -r *.lua $out/share/koreader-sync-server/lib/ 2>/dev/null || true
    cd ..

    # Install redis-lua
    cp -r ${redisLuaSrc}/* $out/share/koreader-sync-server/lib/redis.lua 2>/dev/null || true
    # If redis-lua has a lib directory structure
    if [ -d "${redisLuaSrc}/lib" ]; then
      cp -r ${redisLuaSrc}/lib/* $out/share/koreader-sync-server/lib/
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Create directory structure
    mkdir -p $out/{bin,lib,share/koreader-sync-server}
    mkdir -p $out/share/koreader-sync-server/{app,config,db,lib}

    # Copy application code
    for dir in app config db; do
      if [ -d "$dir" ] && [ "$(ls -A $dir 2>/dev/null)" ]; then
        cp -r $dir/* $out/share/koreader-sync-server/$dir/ 2>/dev/null || true
      fi
    done

    # Copy lib files (sync app code with lua modules)
    cp -r lib/* $out/share/koreader-sync-server/lib/ 2>/dev/null || true

    # Set up proper Lua paths - use the luajit with packages
    LUA_BASE="${luajitWithPackages}/lib/lua/${luajit.luaversion}"
    LUA_SHARE="${luajitWithPackages}/share/lua/${luajit.luaversion}"

    # Create openresty wrapper with all Lua paths
    makeWrapper ${openresty}/bin/openresty $out/bin/openresty \
      --set LUA_PATH "$out/share/koreader-sync-server/lib/?.lua;$out/share/koreader-sync-server/lib/?/init.lua;$LUA_SHARE/?.lua;$LUA_SHARE/?/init.lua;;" \
      --set LUA_CPATH "${luajitWithPackages}/lib/lua/${luajit.luaversion}/?.so;$out/lib/?.so;;"

    # Create gin wrapper
    cat > $out/bin/gin << 'GINWRAPPER'
    #!/usr/bin/env bash
    export LUA_PATH="@out@/share/koreader-sync-server/lib/?.lua;@out@/share/koreader-sync-server/lib/?/init.lua;@luashare@/?.lua;@luashare@/?/init.lua;;"
    export LUA_CPATH="@luacpath@/?.so;@out@/lib/?.so;;"
    export GIN_APP_ROOT="@out@/share/koreader-sync-server/app"

    cd "@out@/share/koreader-sync-server"

    if [ -z "$1" ] || [ "$1" = "start" ]; then
      exec @out@/bin/openresty -p "@out@/share/koreader-sync-server" -c config/nginx.conf
    else
      echo "Usage: koreader-sync-server [start]"
      exit 1
    fi
    GINWRAPPER

    sed -i "s|@out@|$out|g" $out/bin/gin
    sed -i "s|@luashare@|${luajitWithPackages}/share/lua/${luajit.luaversion}|g" $out/bin/gin
    sed -i "s|@luacpath@|${luajitWithPackages}/lib/lua/${luajit.luaversion}|g" $out/bin/gin
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
