# Declarative Vivaldi setup: minimal UI (tabs + slim address bar), Kagi homepage.
#
# How it works:
# - UI prefs live in ~/.config/vivaldi/Default/Preferences (JSON). Key names were
#   verified against resources/vivaldi/prefs_definitions.json in the Vivaldi 8.1
#   package. Unknown keys are harmlessly ignored by Vivaldi.
# - The merge must run while Vivaldi is CLOSED — a running Vivaldi overwrites
#   Preferences on exit. The script skips with a warning if Vivaldi is up; re-run
#   `vivaldi-apply-prefs` after closing it (also runs on every HM switch).
# - Kagi as the default search engine CANNOT be automated (verified empirically
#   on Vivaldi 8.1): search engines live in the "Web Data" sqlite `keywords`
#   table, but rows require Vivaldi-computed encrypted fields (`position`,
#   `url_hash`); foreign rows are pruned on startup. The default selection pref
#   (`vivaldi.system.search_engine.default.index`) only accepts prepopulate_ids
#   of built-in engines and resets otherwise.
#   One-time manual step per profile (Kagi's official method):
#   open kagi.com (it is the homepage) → sign in → right-click Kagi's search
#   field → "Add as Search Engine" → check "Set as Default Search".
{
  lib,
  pkgs,
  ...
}:
let
  jq = lib.getExe pkgs.jq;

  prefs = {
    vivaldi = {
      # Address bar keeps only essentials (drops Panel/Extensions/VPN/Update/Account).
      toolbars = {
        navigation = [
          "Back"
          "Forward"
          "Reload"
          "AddressField"
        ];
        panel = [ ];
        status = [ ];
        tabbar_before = [ ];
        tabbar_after = [ ];
      };
      status_bar.display = 1; # 0=on 1=off 2=overlay
      tabs = {
        show_trash_can = false;
        show_synced_tabs_button = false;
      };
      address_bar.show_qr_generator = false;
      # Empty, decluttered new-tab page.
      startpage = {
        navigation = 2; # 0=on 1=speed_dial_only 2=off
        navigation_shorcuts = false; # key name is Vivaldi's typo, keep as-is
        speed_dial = {
          display_search = false;
          controls_visible = false;
          add_button_visible = false;
        };
      };
      homepage = "https://kagi.com";
      startup.check_is_default = false;
      menu.compact = true;
    };
  };

  applyScript = pkgs.writeShellScriptBin "vivaldi-apply-prefs" ''
    set -euo pipefail
    profile_dir="$HOME/.config/vivaldi/Default"
    prefs_file="$profile_dir/Preferences"

    if pgrep -x vivaldi-bin >/dev/null 2>&1 || pgrep -x vivaldi >/dev/null 2>&1; then
      echo "vivaldi-apply-prefs: Vivaldi is running; close it and re-run" >&2
      echo "(a running Vivaldi overwrites Preferences on exit)." >&2
      exit 1
    fi

    install -d "$profile_dir"

    # Deep-merge our prefs (jq `*` operator = recursive merge; arrays replace).
    if [ -e "$prefs_file" ] && ${jq} -e . "$prefs_file" >/dev/null 2>&1; then
      cp "$prefs_file" "$prefs_file.work"
    else
      echo '{}' > "$prefs_file.work"
    fi
    ${jq} --argjson prefs '${builtins.toJSON prefs}' '. * $prefs' \
      "$prefs_file.work" > "$prefs_file.new"
    mv "$prefs_file.new" "$prefs_file"
    rm -f "$prefs_file.work"
    echo "vivaldi-apply-prefs: preferences applied"
  '';
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [ applyScript ];

  home.activation.vivaldiPrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${applyScript}/bin/vivaldi-apply-prefs || true
  '';
}
