# Declarative Vivaldi setup: minimal UI (tabs + slim address bar), Kagi homepage,
# and a best-effort seed of the Kagi search engine.
#
# How it works:
# - UI prefs live in ~/.config/vivaldi/Default/Preferences (JSON). Key names were
#   verified against resources/vivaldi/prefs_definitions.json in the Vivaldi 8.1
#   package. Unknown keys are harmlessly ignored by Vivaldi.
# - The merge must run while Vivaldi is CLOSED — a running Vivaldi overwrites
#   Preferences on exit. The script skips with a warning if Vivaldi is up; re-run
#   `vivaldi-apply-prefs` after closing it (also runs on every HM switch).
# - Kagi as DEFAULT search engine cannot be fully declarative: engines live in
#   the "Web Data" sqlite DB and Vivaldi encrypts/hashes the default pointer in
#   Preferences. This module seeds the engine row (so it appears in
#   vivaldi:settings/search); if the default doesn't stick, the one-time manual
#   step is: open kagi.com (it is the homepage) → sign in → right-click Kagi's
#   search field → "Add as Search Engine" → check "Set as Default Search".
{
  lib,
  pkgs,
  ...
}:
let
  jq = lib.getExe pkgs.jq;
  sqlite3 = "${pkgs.sqlite}/bin/sqlite3";

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
    web_data="$profile_dir/Web Data"

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

    # Best-effort: seed Kagi into Web Data keywords (skipped if present).
    # Column list is introspected so schema changes across versions are safe.
    if [ -f "$web_data" ]; then
      if ${sqlite3} "$web_data" \
        "SELECT 1 FROM keywords WHERE keyword = 'kagi.com' LIMIT 1;" | grep -q 1; then
        echo "vivaldi-apply-prefs: Kagi search engine already present"
      else
        now=$((($(date +%s) + 11644473600) * 1000000)) # chromium epoch (1601), µs
        guid=$(cat /proc/sys/kernel/random/uuid)
        cols=$(${sqlite3} "$web_data" \
          "SELECT group_concat(name, char(10)) FROM pragma_table_info('keywords');")
        col_list=""
        val_list=""
        add() { # <column> <sql literal>
          if printf '%s\n' "$cols" | grep -qx "$1"; then
            col_list="''${col_list:+$col_list, }$1"
            val_list="''${val_list:+$val_list, }$2"
          fi
        }
        add short_name "'Kagi'"
        add keyword "'kagi.com'"
        add favicon_url "'https://kagi.com/favicon.ico'"
        add url "'https://kagi.com/search?q={searchTerms}'"
        add safe_for_autoreplace 0
        add originating_url "'''"
        add date_created "$now"
        add usage_count 0
        add input_encodings "'UTF-8'"
        add suggest_url "'https://kagi.com/api/autosuggest?q={searchTerms}'"
        add prepopulate_id 0
        add created_by_policy 0
        add last_modified "$now"
        add sync_guid "'$guid'"
        add alternate_urls "'[]'"
        add image_url "'''"
        add search_url_post_params "'''"
        add suggest_url_post_params "'''"
        add image_url_post_params "'''"
        add new_tab_url "'''"
        add last_visited 0
        add created_from_play_api 0
        add is_active 1
        add starter_pack_id 0
        add enforced_by_policy 0
        add featured_by_search_surface 0
        ${sqlite3} "$web_data" \
          "INSERT INTO keywords ($col_list) VALUES ($val_list);"
        echo "vivaldi-apply-prefs: Kagi search engine seeded (set it as default in vivaldi:settings/search if needed)"
      fi
    fi
  '';
in
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [ applyScript ];

  home.activation.vivaldiPrefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${applyScript}/bin/vivaldi-apply-prefs || true
  '';
}
