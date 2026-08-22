{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
  # Cross-built x86_64 Linux libraries for the box64 target ELF. They live
  # in the native (aarch64) Nix store via the `pkgs.x86` overlay (see
  # modules/flake/overlays.nix); their store paths are baked into the
  # wrapper text below so no runtime /etc file is required.
  #
  # Add more here when UnityPlayer.so complains about missing x86_64
  # symbols (e.g. pkgs.x86.zlib, pkgs.x86.freetype, pkgs.x86.mesa).
  x86Libs = [
    pkgs.x86.glibc
    pkgs.x86.libgcc
    # x86_64 libstdc++: CoQ_Data/Plugins/libzipw.so NEEDs it and box64
    # 0.4.2 never falls back to its native wrap for it (only an emulated
    # copy on BOX64_LD_LIBRARY_PATH is picked up).
    pkgs.x86.gcc.cc.lib
  ];

  # Native aarch64 libraries for box64's wrapped-lib dlopens. box64 wraps
  # most of UnityPlayer.so's NEEDED entries (X11, wayland, GL, audio) to
  # *native* libs, which it resolves by soname with dlopen — on NixOS there
  # is no /lib or ld.so.cache, so their store roots must be baked into
  # LD_LIBRARY_PATH (separate from the x86_64 roots in
  # BOX64_LD_LIBRARY_PATH). Without libz here, libmonobdwgc-2.0.so fails to
  # init and Unity exits silently ("Failed to load mono").
  # Note: no libstdc++ here — box64 only accepts the emulated one (see
  # x86Libs). libgtk-3/glib/gobject are deliberately omitted too: they
  # would only let the optional libStandaloneFileBrowser.so plugin load
  # (native file dialogs for mods), at the cost of a large gtk3 closure
  # on the SD card. The game runs fine without it.
  nativeLibs = [
    pkgs.zlib
    pkgs.dbus.lib
    pkgs.xorg.libX11
    pkgs.xorg.libXext
    pkgs.xorg.libXcursor
    pkgs.xorg.libXinerama
    pkgs.xorg.libXi
    pkgs.xorg.libXrandr
    pkgs.xorg.libXScrnSaver
    pkgs.xorg.libXxf86vm
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.libglvnd
    pkgs.mesa
    pkgs.alsa-lib
    pkgs.libpulseaudio
    pkgs.systemdLibs
    pkgs.vulkan-loader
  ];

  toLibRoots = builtins.concatMap (pkg: [
    "${pkg}/lib"
    "${pkg}/lib64"
    "${pkg}/usr/lib"
    "${pkg}/usr/lib64"
  ]);

  x86LibPath = builtins.concatStringsSep " " (toLibRoots x86Libs);
  nativeLibPath = builtins.concatStringsSep " " (toLibRoots nativeLibs);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    coreutils
    box64
  ]
  ++ x86Libs;
  # The `@X86_LIBS@` line in coq.sh is a Nix string template marker.
  # At derivation time, this expression reads the raw file, substitutes
  # the marker with a real shell assignment listing the store-roots,
  # and the result is what writeShellApplication writes to
  # /bin/coq. The produced wrapper is self-contained: no
  # /etc/ld.so.conf.d required, no box64 --lib-path required (which
  # 0.4.2 does not support).
  text =
    let
      base = builtins.readFile ./${name}.sh;
    in
    pkgs.lib.replaceStrings
      [ "@X86_LIBS@\n" "@NATIVE_LIBS@\n" ]
      [
        "X86_LIB_ROOTS=\"${x86LibPath}\"\n"
        "NATIVE_LIB_ROOTS=\"${nativeLibPath}\"\n"
      ]
      base;
}
