# eilmeldung: TUI RSS reader (news-flash based) against FreshRSS over the
# Google Reader API. Replaces newsboat.
#
# Not in nixos-26.05 or home-manager release-26.05 — it landed in nixpkgs
# unstable and home-manager master — so pull the package from the
# unstable-packages overlay and render config.toml here instead of using
# programs.eilmeldung.
{
  config,
  pkgs,
  vars,
  ...
}:
let
  domain = vars.domain;
  # news-flash's GReader client expects the trailing slash (see the sample
  # output of `eilmeldung --print-login-data`); newsboat did not.
  baseUrl = "https://rss.${domain}/api/greader.php/";

  # sops-decrypted FreshRSS API password. Kept outside ~/.config/eilmeldung
  # because news-flash owns that directory (newsflash.json + auth state).
  passwordFile = "${config.home.homeDirectory}/.config/freshrss/api-password";

  settings = {
    startup_commands = [ "sync" ]; # was: auto-reload yes
    sync_every_minutes = 30; # was: reload-time 30
    keep_articles_days = 30; # was: delete-read-articles-on-quit yes
    article_scope = "unread";
    content_preferred_type = "markdown";
    auto_scrape = true;
    # ratatui-image Picker::from_query_stdio queries the terminal for graphics
    # support; through tmux/script PTYs the reply never arrives (ENODEV panic
    # at view.rs:49 in 1.8.1, garbled thumbs when it does). Thumbnails off
    # until upstream falls back to halfblocks instead of unwrap().
    thumbnail_show = false;
    # tmux already owns the mouse (better-mouse-mode); letting a ratatui app
    # capture it too fights copy-mode and steals clicks in popups.
    mouse_support = false;

    # Matches the repo's gruvbox theming (ghostty, fern, tmux).
    theme.base16_theme = "gruvbox-dark-medium";

    login_setup = {
      login_type = "direct_password";
      provider = "freshrss";
      user = "ratatoskr";
      url = baseUrl;
      # `cmd:` prefix — the secret never enters the world-readable nix store.
      password = "cmd:cat ${passwordFile}";
    };
  };

  configFile = (pkgs.formats.toml { }).generate "eilmeldung-config.toml" settings;
in
{
  home.packages = [ pkgs.unstable.eilmeldung ];

  # The FreshRSS API password is the same as the login password, which
  # nix-secrets already holds.
  sops.secrets."freshrss/admin-password" = {
    path = passwordFile;
    mode = "0400";
  };

  xdg.configFile."eilmeldung/config.toml".source = configFile;
}
