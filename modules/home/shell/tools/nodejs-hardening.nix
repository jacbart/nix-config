{ ... }:
{
  home.file.".npmrc".text = ''
    # ── npm (≥11.10) / pnpm shared hardening ───────────────
    save-exact               = true
    minimum-release-age      = 10080   # block packages < 7 days old (minutes)
    audit                    = true
    fund                     = false
    prefer-offline           = true
    update-notifier          = false
  '';

  home.file.".yarnrc.yml".text = ''
    # ── Yarn Berry hardening ────────────────────────────────
    npmMinimalAgeGate        : 604800  # block packages < 7 days old (seconds)
    defaultSemverRangePrefix : ""      # exact versions by default (^ → no prefix)
    enableTelemetry          : false

    # use PnP for strict dependency isolation
    nodeLinker               : pnp
  '';

  home.file.".yarnrc".text = ''
    # ── Yarn Classic (maintenance mode, limited hardening) ──
    registry "https://registry.yarnpkg.com"
  '';

  home.file.".bunfig.toml".text = ''
    [install]
    exact              = true
    minimumReleaseAge  = 604800     # block packages < 7 days old (seconds)
    ignoreScripts      = true       # disable postinstall/build scripts globally
  '';

}
