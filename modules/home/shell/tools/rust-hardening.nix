{
  pkgs,
  config,
  ...
}:
{
  home.file.".cargo/config.toml".text = ''
    # ── Cargo hardening ──────────────────────────────────────
    [net]
    retry = 3

    # Note: Cargo has no native minimum release age feature.
    # For cooldown enforcement, install cargo-cooldown separately:
    #   cargo install cargo-cooldown
    # Then use: cargo cooldown --days 7 build
  '';

  home.packages = with pkgs; [
    cargo-audit
  ];
}