(require "mattwparas-helix-package/splash.scm")
(require "steel-pty/term.scm")

(when (equal? (command-line) '("hx"))
  (show-splash))

(provide open-term
         new-term
         kill-active-terminal
         switch-term
         term-resize
         (contract/out set-default-terminal-cols! (->/c int? void?))
         (contract/out set-default-terminal-rows! (->/c int? void?))
         (contract/out set-default-shell! (->/c string? void?))
         open-debug-window
         close-debug-window
         hide-terminal)
