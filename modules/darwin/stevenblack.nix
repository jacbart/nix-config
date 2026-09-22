# StevenBlack unified hosts sinkhole for macOS (ad/malware blocking).
#
# NixOS hosts get this via networking.stevenblack (modules/nixos/core.nix);
# nix-darwin has no equivalent option, so we install the same merged hosts
# file to /etc/hosts. nix-darwin backs up the stock /etc/hosts on first
# activation.
#
# Installed by an activation script rather than `environment.etc`, and that is
# deliberate. environment.etc can only ever produce a symlink into the Nix
# store (modules/system/etc.nix builds its tree with `ln -s`), and Chromium's
# network process is sandboxed by sandbox/policy/mac/network.sb, which grants:
#
#   (allow file-read* (path "/etc/hosts") (path "/private/etc/hosts") ...)
#
# `path` is an exact-path rule matched against the RESOLVED path, and nothing
# in that profile grants /nix. So with /etc/hosts symlinked into the store,
# every Chromium browser silently loses the whole file -- this blocklist and
# any local development entry alike -- while dig, ping, curl and Safari keep
# working, because they resolve through mDNSResponder, which is not sandboxed.
# The failure is invisible: no error, no console warning, just DNS answers for
# names that should have been sinkholed. Do NOT "simplify" this back to
# environment.etc."hosts".source.
#
# Ordering is load-bearing too. Dropping environment.etc."hosts" removes
# /etc/static/hosts from the closure, and etc.nix's stale-link sweep then
# deletes /etc/hosts; postActivation is the last phase to run
# (modules/system/activation-scripts.nix), so the copy lands after that sweep.
# Anything earlier leaves the machine with no hosts file at all.
#
# Pinned by hash (supply chain): upstream `master` moves daily, so this only
# ever changes when the sha256 below is bumped deliberately. Refresh with
# `task update:hosts` and paste the new hash.
{ ... }:
{
  flake.modules.darwin.stevenblack =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      stevenblackHosts = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
        sha256 = "0262c7a7nnykazry18q51lh7qjdspxllhd3ybfpvslsbllgp0fd6";
      };

      extra = config.stevenblack.extraHosts;

      # Concatenated in a build step rather than with builtins.readFile: the
      # upstream file is ~2.4MB and readFile would drag all of it through
      # evaluation on every rebuild.
      hostsFile = pkgs.runCommand "hosts" { preferLocalBuild = true; } ''
        cat ${stevenblackHosts} > $out
        ${lib.optionalString (extra != "") ''
          printf '\n# Local entries -- nix-config stevenblack.extraHosts\n' >> $out
          cat ${pkgs.writeText "hosts-extra" extra} >> $out
        ''}
      '';
    in
    {
      options.stevenblack.extraHosts = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = "127.0.0.1  remote.dev";
        description = ''
          Extra entries appended to /etc/hosts after the StevenBlack blocklist.
          Use this for local development vhosts; never append to /etc/hosts by
          hand, since activation overwrites the file on every rebuild.
        '';
      };

      config = {
        system.activationScripts.postActivation.text = lib.mkAfter ''
          printf >&2 'setting up /etc/hosts...\n'

          # Written via a temp file + rename so /etc/hosts is never absent or
          # half-written, and never appended to in place: `>>` or `tee -a` on
          # this path would follow a leftover symlink straight into the Nix
          # store and corrupt the store object it points at.
          install -m 0644 -o root -g wheel ${hostsFile} /etc/.hosts.nix-darwin-new
          mv -f /etc/.hosts.nix-darwin-new /etc/hosts
        '';
      };
    };
}
