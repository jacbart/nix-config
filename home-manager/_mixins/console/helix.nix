{ config, pkgs, ...}: {

  home = {
    packages = with pkgs; [
      marksman
      markdown-oxide
      dprint
    ];

    file.".dprint.json".text = ''
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

    sessionVariables = {
      EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };
  programs = {
    helix = {
      enable = true;
      languages = {
        language = [
          {
            name = "hcl";
            file-type = ["tf" "tfvars" "hcl" "koi" "jaws"];
            auto-format = true;
          }
          {
            name = "markdown";
            formatter = { command = "dprint"; args = ["fmt" "--stdin" "md"]; };
            auto-format = true;
          }
        ];
      };
      settings = {
        theme = "ayu_dark";
        editor = {
          shell = ["zsh" "-c"];
          line-number = "absolute";
          mouse = true;
          color-modes = true;
          auto-pairs = true;
          bufferline = "multiple";
          auto-completion = true;
          auto-format = true;
          statusline = {
            left = ["mode" "spinner"];
            center = ["file-name"];
            right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
            separator = "│";
          };
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker = {
            hidden = false;
            git-ignore = true;
          };
          whitespace.render = {
            space = "none";
            tab = "none";
            newline = "none";
          };
          whitespace.characters = {
            space = "·";
            nbsp = "⍽";
            tab = "→";
            newline = "⏎";
            tabpad = "·";
          };
          lsp.display-messages = true;
          indent-guides = {
            render = true;
            character = "╎";
            skip-levels = 1;
          };
        };
      };
    };
  };
}