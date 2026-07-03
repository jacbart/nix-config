; Authored in-repo, adapted from Helix's bundled java indents.scm
; (apex grammar is java-derived; java-only nodes dropped, trigger_body added).

[
  (class_body)
  (enum_body)
  (interface_body)
  (constructor_body)
  (trigger_body)
  (block)
  (switch_block)
  (array_initializer)
  (argument_list)
  (formal_parameters)
  (annotation_argument_list)
  (element_value_array_initializer)
] @indent

[
  "}"
  ")"
  "]"
] @outdent

; Single statement after if/while/for without brackets
(if_statement
  consequence: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))

(while_statement
  body: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))

(for_statement
  (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))

(enhanced_for_statement
  body: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))

(do_statement
  body: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))
