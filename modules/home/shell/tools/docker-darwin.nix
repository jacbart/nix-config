# Docker CLI config + plugin symlinks (binaries on nix-darwin system profile)

{ pkgs, lib, ... }:
lib.mkIf pkgs.stdenv.isDarwin {
  # programs.docker-cli puts config.json in the store and symlinks it; Colima/Docker then
  # try rename(2) onto config.json and fail: "cross-device link". Keep a real file under $HOME.
  home.activation.dockerCliConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d "$HOME/.docker"
    cfg="$HOME/.docker/config.json"
    if [ -L "$cfg" ]; then
      rm -f "$cfg"
    fi
    if [ ! -e "$cfg" ]; then
      umask 077
      printf '%s' '{"credsStore":"osxkeychain"}' > "$cfg"
    elif [ -f "$cfg" ]; then
      if ! ${lib.getExe pkgs.jq} -e . "$cfg" >/dev/null 2>&1; then
        umask 077
        printf '%s' '{"credsStore":"osxkeychain"}' > "$cfg"
      else
        ${lib.getExe pkgs.jq} '. + {credsStore: "osxkeychain"}' "$cfg" > "$cfg.tmp" \
          && mv -f "$cfg.tmp" "$cfg"
      fi
    fi
    chmod 600 "$cfg" 2>/dev/null || true
  '';

  home.file = {
    ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
    ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
  };
}
