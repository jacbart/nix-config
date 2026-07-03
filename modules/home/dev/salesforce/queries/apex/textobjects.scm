; Authored in-repo, adapted from Helix's bundled java textobjects.scm
; (apex grammar is java-derived; node names verified against
; aheber/tree-sitter-sfapex @ 27a3091 apex/src/node-types.json).

(method_declaration
  body: (_)? @function.inside) @function.around

(constructor_declaration
  body: (_) @function.inside) @function.around

(trigger_declaration
  body: (_) @function.inside) @function.around

(interface_declaration
  body: (_) @class.inside) @class.around

(class_declaration
  body: (_) @class.inside) @class.around

(enum_declaration
  body: (_) @class.inside) @class.around

(formal_parameters
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

(type_parameters
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

(type_arguments
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

(argument_list
  ((_) @parameter.inside . ","? @parameter.around) @parameter.around)

[
  (line_comment)
  (block_comment)
] @comment.inside

(line_comment)+ @comment.around

(block_comment) @comment.around

(array_initializer
  (_) @entry.around)

(enum_body
  (enum_constant) @entry.around)

; @isTest-annotated methods (annotation is case-insensitive in Apex)
(method_declaration
  (modifiers
    (annotation
      name: (identifier) @_annotation
      (#match? @_annotation "(?i)^istest$")))
  body: (_)? @test.inside) @test.around
