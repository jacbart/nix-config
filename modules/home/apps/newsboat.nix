{ vars, ... }:
let
  domain = vars.domain;
  baseUrl = "https://rss.${domain}/api/greader.php";
in
{
  programs.newsboat = {
    enable = true;
    extraConfig = ''
      # FreshRSS API
      urls-source "freshrss"
      freshrss-url "${baseUrl}"
      freshrss-login "ratatoskr"
      freshrss-passwordfile "~/.config/newsboat/freshrss-password"
      freshrss-min-items 200

      # Appearance
      color listnormal_unread yellow default
      color listfocus blue white bold
      color listfocus_unread yellow white bold
      color info red white bold

      # Navigation
      bind-key j down feedlist
      bind-key k up feedlist
      bind-key J next-feed articlelist
      bind-key K prev-feed articlelist
      bind-key G end feedlist
      bind-key g home feedlist

      # Reload
      reload-time 30
      auto-reload yes

      # Cleanup
      delete-read-articles-on-quit yes
    '';
  };
}
