(require "mattwparas-helix-package/splash.scm")

(when (equal? (command-line) '("hx"))
  (show-splash))

(require (prefix-in navigator. "hx-tmux-navigator/navigator.scm"))
