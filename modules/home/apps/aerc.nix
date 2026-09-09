# aerc — TUI mail client for jack@meep.sh.
#
# IMAP (993) and SMTP submission (587 STARTTLS) both terminate on maple over
# Tailscale. The raw login password is the `mail/password-plain` sops secret
# (maple's side of the same credential is the `mail-password` dovecot
# passwd-file hash). unsafe-accounts-conf is required by home-manager (it
# renders accounts.conf into the world-readable store); the password is only
# fetched at runtime via passwordCommand, so nothing secret lands in the
# store.
#
# UX mirrors the helix/zsh-tools setup elsewhere in this flake:
#   - `bat` (not `less`) is the pager everywhere. aerc runs pager/openers via
#     `sh -c`, so zsh aliases (`less` -> `bat`) never apply — we spell out the
#     real commands ourselves.
#   - `fzf` is the menu and the attachment picker.
#   - keybinds follow helix muscle memory (j/k, g/G, h/l tree, v/x mark,
#     <Space> leader, `;` leader); composing edits the body in helix via `e`.
#   - `gruvbox` styleset matches helix's gruvbox_dark_hard.
{
  config,
  pkgs,
  vars,
  ...
}:
let
  # Plain command names on purpose: aerc runs pager/openers/menu-cmd/editor via
  # `sh -c`, so zsh aliases never apply and these resolve through the PATH aerc
  # inherits from the launching shell (which includes the nix profile bin where
  # bat/fd/fzf/hx live). Interpolating store paths here also trips a Nix string-
  # context bug in home-manager's writeTextFile passAsFile path.
  bat = "bat";
  bsdtar = "bsdtar";
  fd = "fd";
  fzf = "fzf";
  hx = "hx";

  # `:open-link` target. macOS has no xdg-utils, so use its own `open`; the
  # NixOS hosts (niri) use vivaldi as their browser (see desktop/niri.nix).
  browser = if pkgs.stdenv.isDarwin then "open" else "vivaldi";

  # The colorize filter already pipes ANSI-colored email into the pager, so bat
  # must *not* add its own syntax highlighting (`--color=never`), and the
  # underlying pager must interpret the ANSI (`-R`). `--style=plain` drops the
  # line numbers/grid. `--color=always` would make bat re-highlight plain
  # email text as a guessed language, so never use that here.
  batPager = "${bat} --paging=always --style=plain --color=never --pager 'less -R'";
in
{
  # bsdtar (libarchive) reads zip from stdin natively (unzip/zipinfo can't),
  # and pdftotext (poppler-utils) reads PDF from stdin (mutool can't); both
  # are used by filters below.
  home.packages = [
    pkgs.libarchive
    pkgs.poppler-utils
  ];

  programs.aerc = {
    enable = true;
    extraConfig = {
      general = {
        unsafe-accounts-conf = true;
        # `:menu` (and friends) route their items through fzf.
        default-menu-cmd = "${fzf} --multi";
      };
      ui = {
        # Fuzzy completion for commands/options, fzf-style.
        fuzzy-complete = true;
        # Foldable sidebar tree, navigated with h/l (see extraBinds).
        dirlist-tree = true;
        mouse-enabled = true;
        styleset-name = "gruvbox";
      };
      viewer.pager = batPager;
      compose = {
        editor = hx;
        # `:attach -m` (bound to `a` in compose) picks attachments with fzf.
        file-picker-cmd = "${fd} --type f --strip-cwd-prefix | ${fzf} --multi --height 40% --reverse --border --border-label ' attach ' --prompt 'attach> ' --preview '${bat} --style=plain --color=always {}'";
      };
      openers = {
        "text/*" = batPager;
        "message/*" = batPager;
        "application/pgp-signature" = batPager;
        # Web links (`:open-link`, bound to <C-l>) go to the browser.
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
      };
      # A user aerc.conf fully replaces aerc's built-in defaults, so the
      # [filters] section must be reproduced here too — otherwise opening a
      # part reports "no filter configured". aerc 0.21's built-in defaults
      # include `text/html=! html` (its bundled w3m-based `html` filter, which
      # nixpkgs wraps with w3m + dante on PATH), so HTML-only messages are
      # viewable. Keep it here or the same message is unviewable.
      # Written as a literal string (not an attrset): home-manager renders
      # attrset sections with generators.toKeyValue, which sorts keys
      # alphabetically — `text/*` would sort before `text/html`, hijacking
      # HTML parts before their `! html` filter. aerc matches filters with
      # fnmatch and uses the first hit, so order below is significant.
      filters = ''
        # text — most specific first; `text/*` is the last-resort catch-all.
        text/plain=colorize
        text/html=! html
        text/calendar=calendar
        # Catch-all for other text subtypes (diff, markdown, vcard, log, ...)
        # that would otherwise report "no filter configured".
        text/*=colorize

        message/delivery-status=colorize
        message/rfc822=colorize
        .headers=colorize

        # Attachments. `image/*` is deliberately left unfiltered: with no
        # filter aerc's Vaxis terminal renders images natively (kitty/sixel),
        # and defining one would disable that.
        application/json=jq --color-output .
        # pdftotext reads from stdin (`-`) and is capped at 10 pages; fmt
        # re-wraps at 100 cols for the pager.
        application/pdf=pdftotext - -l 10 -nopgbrk -q - | fmt -w 100
        # bsdtar reads zip from stdin (unzip/zipinfo need a seekable file).
        application/zip=${bsdtar} -tvf -
        # Tabulate comma-separated attachments (`.filename,` = exact-substring
        # match on the attachment filename, no regex escaping needed).
        .filename,.csv=column -t --separator=','
      '';
    };

    # A user binds.conf fully replaces aerc's built-in defaults, so this is a
    # complete, self-contained map (not an overlay). Contexts follow aerc's
    # binds.conf(5): `global` renders with no [section] header and is inherited
    # by every context that doesn't set $noinherit.
    extraBinds = {
      global = {
        "?" = ":help keys<Enter>";
        "<C-c>" = ":prompt 'Quit?' quit<Enter>";
        "<C-q>" = ":prompt 'Quit?' quit<Enter>";
        "<C-z>" = ":suspend<Enter>";
        "<C-t>" = ":term<Enter>";
        "<C-p>" = ":prev-tab<Enter>";
        "<C-PgUp>" = ":prev-tab<Enter>";
        "<C-n>" = ":next-tab<Enter>";
        "<C-PgDn>" = ":next-tab<Enter>";
        "\\[t" = ":prev-tab<Enter>";
        "\\]t" = ":next-tab<Enter>";
        "<Space>t" = ":term<Enter>";
        "<Space>q" = ":prompt 'Quit?' quit<Enter>";
      };

      messages = {
        q = ":prompt 'Quit?' quit<Enter>";

        j = ":next<Enter>";
        "<Down>" = ":next<Enter>";
        "<C-d>" = ":next 50%<Enter>";
        "<C-f>" = ":next 100%<Enter>";
        "<PgDn>" = ":next 100%<Enter>";

        k = ":prev<Enter>";
        "<Up>" = ":prev<Enter>";
        "<C-u>" = ":prev 50%<Enter>";
        "<C-b>" = ":prev 100%<Enter>";
        "<PgUp>" = ":prev 100%<Enter>";

        g = ":select 0<Enter>";
        G = ":select -1<Enter>";

        J = ":next-folder<Enter>";
        "<C-Down>" = ":next-folder<Enter>";
        K = ":prev-folder<Enter>";
        "<C-Up>" = ":prev-folder<Enter>";
        h = ":collapse-folder<Enter>";
        H = ":collapse-folder<Enter>";
        "<C-Left>" = ":collapse-folder<Enter>";
        l = ":expand-folder<Enter>";
        L = ":expand-folder<Enter>";
        "<C-Right>" = ":expand-folder<Enter>";

        v = ":mark -t<Enter>";
        x = ":mark -t<Enter>:next<Enter>";
        V = ":mark -v<Enter>";
        u = ":read -t<Enter>";

        T = ":toggle-threads<Enter>";
        zc = ":fold<Enter>";
        zo = ":unfold<Enter>";
        za = ":fold -t<Enter>";
        zM = ":fold -a<Enter>";
        zR = ":unfold -a<Enter>";
        "<tab>" = ":fold -t<Enter>";

        zz = ":align center<Enter>";
        zt = ":align top<Enter>";
        zb = ":align bottom<Enter>";

        "<Enter>" = ":view<Enter>";
        d = ":choose -o y 'Really delete this message' delete-message<Enter>";
        D = ":delete<Enter>";
        a = ":archive flat<Enter>";
        A = ":unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>";

        C = ":compose<Enter>";
        m = ":compose<Enter>";

        b = ":bounce<space>";

        rr = ":reply -a<Enter>";
        rq = ":reply -aq<Enter>";
        Rr = ":reply<Enter>";
        Rq = ":reply -q<Enter>";

        f = ":forward<Enter>";

        c = ":cf<space>";
        "$" = ":term<space>";
        "!" = ":term<space>";
        "|" = ":pipe<space>";

        "/" = ":search<space>";
        "\\" = ":filter<space>";
        n = ":next-result<Enter>";
        N = ":prev-result<Enter>";
        "<Esc>" = ":clear<Enter>";

        s = ":split<Enter>";
        S = ":vsplit<Enter>";

        pl = ":patch list<Enter>";
        pa = ":patch apply <Tab>";
        pd = ":patch drop <Tab>";
        pb = ":patch rebase<Enter>";
        pt = ":patch term<Enter>";
        ps = ":patch switch <Tab>";

        # <Space> leader (helix-style)
        "<Space>c" = ":compose<Enter>";
        "<Space>r" = ":reply<Enter>";
        "<Space>R" = ":reply -a<Enter>";
        "<Space>f" = ":forward<Enter>";
        "<Space>a" = ":archive flat<Enter>";
        "<Space>d" = ":delete<Enter>";
        "<Space>m" = ":mark -t<Enter>";
        "<Space>/" = ":search<space>";

        # `;` leader (mirrors the helix `;` pipe/shell prefix)
        ";s" = ":term<Enter>";
        ";f" = ":filter<space>";
        ";c" = ":cf<space>";
      };

      "messages:folder=Drafts" = {
        "<Enter>" = ":recall<Enter>";
      };

      view = {
        "/" = ":toggle-key-passthrough<Enter>/";
        q = ":close<Enter>";
        O = ":open<Enter>";
        o = ":open<Enter>";
        S = ":save<space>";
        "|" = ":pipe<space>";
        D = ":delete<Enter>";
        A = ":archive flat<Enter>";
        u = ":read -t<Enter>";

        "<C-y>" = ":copy-link <space>";
        "<C-l>" = ":open-link <space>";

        f = ":forward<Enter>";
        rr = ":reply -a<Enter>";
        rq = ":reply -aq<Enter>";
        Rr = ":reply<Enter>";
        Rq = ":reply -q<Enter>";

        H = ":toggle-headers<Enter>";
        "<C-k>" = ":prev-part<Enter>";
        "<C-Up>" = ":prev-part<Enter>";
        "<C-j>" = ":next-part<Enter>";
        "<C-Down>" = ":next-part<Enter>";
        J = ":next<Enter>";
        "<C-Right>" = ":next<Enter>";
        K = ":prev<Enter>";
        "<C-Left>" = ":prev<Enter>";
      };

      "view::passthrough" = {
        "$noinherit" = true;
        "$ex" = "<C-x>";
        "<Esc>" = ":toggle-key-passthrough<Enter>";
      };

      compose = {
        "$noinherit" = true;
        "$ex" = "<C-x>";
        "$complete" = "<C-o>";
        "<C-k>" = ":prev-field<Enter>";
        "<C-Up>" = ":prev-field<Enter>";
        "<C-j>" = ":next-field<Enter>";
        "<C-Down>" = ":next-field<Enter>";
        "<A-p>" = ":switch-account -p<Enter>";
        "<C-Left>" = ":switch-account -p<Enter>";
        "<A-n>" = ":switch-account -n<Enter>";
        "<C-Right>" = ":switch-account -n<Enter>";
        "<tab>" = ":next-field<Enter>";
        "<backtab>" = ":prev-field<Enter>";
        "<C-p>" = ":prev-tab<Enter>";
        "<C-PgUp>" = ":prev-tab<Enter>";
        "<C-n>" = ":next-tab<Enter>";
        "<C-PgDn>" = ":next-tab<Enter>";
        e = ":edit<Enter>";
        a = ":attach -m<Enter>";
      };

      "compose::review" = {
        y = ":send<Enter>";
        n = ":abort<Enter>";
        s = ":sign<Enter>";
        x = ":encrypt<Enter>";
        v = ":preview<Enter>";
        p = ":postpone<Enter>";
        q = ":choose -o d discard abort -o p postpone postpone<Enter>";
        e = ":edit<Enter>";
        a = ":attach<space>";
        d = ":detach<space>";
      };

      terminal = {
        "$noinherit" = true;
        "$ex" = "<C-x>";
        "<C-p>" = ":prev-tab<Enter>";
        "<C-n>" = ":next-tab<Enter>";
        "<C-PgUp>" = ":prev-tab<Enter>";
        "<C-PgDn>" = ":next-tab<Enter>";
      };
    };

    # gruvbox_dark_hard, keyed to match helix's theme.
    stylesets.gruvbox = {
      global = {
        "*.default" = true;
        "*.normal" = true;
        "title.bg" = "#665c54";
        "title.fg" = "#fbf1c7";
        "title.bold" = true;
        "header.bold" = true;
        "header.fg" = "#83a598";
        "tab.selected.fg" = "#fbf1c7";
        "tab.selected.bg" = "#665c54";
        "dirlist*.selected.bg" = "#3c3836";
        "dirlist*.selected.fg" = "#fbf1c7";
        "*error.bold" = true;
        "*error.fg" = "#fb4934";
        "*warning.fg" = "#fabd2f";
        "*success.fg" = "#b8bb26";
        "statusline_default.bg" = "#282828";
        "statusline_error.fg" = "#fb4934";
        "msglist_unread.fg" = "#fbf1c7";
        "msglist_unread.bold" = true;
        "msglist_deleted.fg" = "#7c6f64";
        "msglist_*.selected.bg" = "#3c3836";
        "msglist_result.bg" = "#665c54";
        "msglist_marked.fg" = "#282828";
        "msglist_marked.selected.fg" = "#282828";
        "msglist_marked.bg" = "#fabd2f";
        "msglist_marked.selected.bg" = "#fe8019";
        "msglist_pill.reverse" = true;
        "part_*.fg" = "#ebdbb2";
        "part_mimetype.fg" = "#7c6f64";
        "part_*.selected.fg" = "#fbf1c7";
        "part_*.selected.bg" = "#3c3836";
        "part_filename.selected.bold" = true;
        "completion_pill.reverse" = false;
        "selector_focused.bold" = false;
        "selector_focused.bg" = "#3c3836";
        "selector_focused.fg" = "#fbf1c7";
        "selector_chooser.bold" = false;
        "selector_chooser.bg" = "#3c3836";
        "selector_chooser.fg" = "#fbf1c7";
        "default.selected.bold" = false;
        "default.selected.fg" = "#fbf1c7";
        "default.selected.bg" = "#3c3836";
        "completion_default.selected.bg" = "#3c3836";
        "completion_default.selected.fg" = "#fbf1c7";
      };
      viewer = {
        "*.default" = true;
        "*.normal" = true;
        "url.underline" = true;
        "url.fg" = "#83a598";
        "header.bold" = true;
        "header.fg" = "#83a598";
        "signature.dim" = true;
        "signature.fg" = "#8ec07c";
        "diff_meta.bold" = true;
        "diff_chunk.fg" = "#8ec07c";
        "diff_chunk_func.fg" = "#8ec07c";
        "diff_chunk_func.dim" = true;
        "diff_add.fg" = "#b8bb26";
        "diff_del.fg" = "#fb4934";
        "quote_1.fg" = "#8ec07c";
        "quote_2.fg" = "#83a598";
        "quote_3.fg" = "#8ec07c";
        "quote_3.dim" = true;
        "quote_4.fg" = "#83a598";
        "quote_4.dim" = true;
        "quote_x.fg" = "#d3869b";
        "quote_x.dim" = true;
      };
    };
  };

  accounts.email.accounts.meep = {
    address = "jack@${vars.domain}";
    realName = "Jack Bartlett";
    userName = "jack";
    primary = true;
    imap = {
      host = "maple.${vars.domain}";
      port = 993;
      tls.enable = true;
    };
    smtp = {
      host = "maple.${vars.domain}";
      port = 587;
      tls.enable = true;
      tls.useStartTls = true;
    };
    aerc.enable = true;
    passwordCommand = "cat ${config.sops.secrets."mail/password-plain".path}";
  };

  sops.secrets."mail/password-plain" = { };
}
