# codebase-memory-mcp — install the binary and keep its coordination daemon warm.
#
# The daemon owns the background watcher (auto re-indexes git projects), shared
# indexing jobs, and CBM Lens (the loopback graph UI). `daemon start` spawns a
# detached permanent daemon and exits, so this is a RunAtLoad-only job — no
# KeepAlive, which would otherwise re-run it in a tight loop. If the daemon ever
# dies, any CBM client (OpenCode, the CLI) starts it again on demand.
{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.codebase-memory-mcp ];

  launchd.agents.cbm-lens = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.codebase-memory-mcp}/bin/codebase-memory-mcp"
        "daemon"
        "start"
      ];
      RunAtLoad = true;
    };
  };
}
