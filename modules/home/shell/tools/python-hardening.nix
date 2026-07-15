{
  pkgs,
  config,
  ...
}:
{
  home.file.".config/uv/uv.toml".text = ''
    # ── uv hardening (uv ≥ 0.9.17) ───────────────────────────
    exclude-newer = "7 days"

    [pip]
    require-hashes = true
    verify-hashes = true
  '';

  home.file.".config/pip/pip.conf".text = ''
    # ── pip hardening ─────────────────────────────────────────
    [global]
    require-hashes = true
  '';

  home.packages = with pkgs; [
    pip-audit
  ];
}
