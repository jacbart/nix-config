{...}: {
  home = {
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
    file-types = ["tf", "tfvars", "hcl", "koi"]
    auto-format = true
    '';
  };
}