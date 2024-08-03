{pkgs, ...}: {

  home = {
    packages = with pkgs; [
      helix
      marksman
      markdown-oxide
      dprint
    ];
    file.".config/helix/config.toml".text = ''
    theme = "ayu_dark"

    [editor]
    shell = ["zsh", "-c"]
    line-number = "absolute"
    mouse = true
    color-modes = true
    auto-pairs = true
    bufferline = "multiple"
    auto-completion = true
    auto-format = true

    [editor.statusline]
    left = ["mode", "spinner"]
    center = ["file-name"]
    right = ["diagnostics", "selections", "position", "file-encoding", "file-line-ending", "file-type"]
    separator = "│"

    [editor.cursor-shape]
    insert = "bar"
    normal = "block"
    select = "underline"

    [editor.file-picker]
    hidden = false
    git-ignore = true

    [editor.whitespace.render]
    space = "none"
    tab = "none"
    newline = "none"

    [editor.whitespace.characters]
    space = "·"
    nbsp = "⍽"
    tab = "→"
    newline = "⏎"
    tabpad = "·"

    [editor.lsp]
    display-messages = true

    [editor.indent-guides]
    render = true
    character = "╎"
    skip-levels = 1
    '';

    file.".config/helix/languages.toml" = ''
    [[language]]
    name = "hcl"
    file-types = ["tf", "tfvars", "hcl", "jaws"]
    auto-format = true
    [[language]]
    name = "markdown"
    formatter = { command = "dprint", args = ["fmt", "--stdin", "md"] }
    auto-format = true
    '';

    file.".dprint.json" = ''
    {
      "typescript": {
      },
      "json": {
      },
      "markdown": {
      },
      "toml": {
      },
      "dockerfile": {
      },
      "excludes": [
        "**/node_modules",
        "**/*-lock.json"
      ],
      "plugins": [
        "https://plugins.dprint.dev/typescript-0.91.0.wasm",
        "https://plugins.dprint.dev/json-0.19.3.wasm",
        "https://plugins.dprint.dev/markdown-0.17.1.wasm",
        "https://plugins.dprint.dev/toml-0.6.2.wasm",
        "https://plugins.dprint.dev/dockerfile-0.3.2.wasm"
      ]
    }
    '';
  };
}