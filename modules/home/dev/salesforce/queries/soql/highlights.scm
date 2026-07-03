; https://code.visualstudio.com/api/language-extensions/semantic-highlight-guide#semantic-token-classification
(field_identifier
  (identifier) @variable.other.member)

(field_identifier
  (dotted_identifier
    (identifier) @variable.other.member))

(type_of_clause
  (identifier) @variable.other.member)

(when_expression
  (identifier) @type)

(when_expression
  (field_list
    (identifier) @variable.other.member))

(when_expression
  (field_list
    (dotted_identifier
      (identifier) @variable.other.member )))

(else_expression
  (field_list
    (identifier) @variable.other.member ))

(else_expression
  (field_list
    (dotted_identifier
      (identifier) @variable.other.member )))

(alias_expression
  (identifier) @label)

(storage_identifier (identifier) @type)
(storage_identifier (dotted_identifier (identifier) @type))

(_ function_name:(identifier) @function)

(date_literal) @constant.builtin

[
  ","
  "."
  ":"
  "("
  ")"
] @punctuation

[
  "AND"
  "OR"
  "NOT"
  "="
  "!="
  "LIKE"
  "NOT_IN"
  "INCLUDES"
  "EXCLUDES"
] @operator
(value_comparison_operator "<" @operator)
"<=" @operator
(value_comparison_operator ">" @operator)
">=" @operator
 @operator
(set_comparison_operator "IN" @operator)

(int) @number
(decimal) @number
(currency_literal) @number
(string_literal) @string
(date) @constant
(date_time) @constant

[
  "TRUE"
  "FALSE"
  (null_literal)
] @constant.builtin

[
  "ABOVE"
  "ABOVE_OR_BELOW"
  "ALL"
  "AS"
  "ASC"
  "AT"
  "BELOW"
  "CUSTOM"
  "DATA_CATEGORY"
  "DESC"
  "ELSE"
  "END"
  "FIELDS"
  "FOR"
  "FROM"
  "GROUP_BY"
  "HAVING"
  "LIMIT"
  "NULLS_FIRST"
  "NULLS_LAST"
  "OFFSET"
  "ORDER_BY"
  "REFERENCE"
  "SELECT"
  "STANDARD"
  "THEN"
  "TRACKING"
  "TYPEOF"
  "UPDATE"
  "USING"
  "SCOPE"
  "LOOKUP"
  "BIND"
  "VIEW"
  "VIEWSTAT"
  "WITH"
  "WHERE"
  "WHEN"
] @keyword

; Using Scope
[
  "delegated"
  "everything"
  "mine"
  "mine_and_my_groups"
  "my_territory"
  "my_team_territory"
  "team"
] @constant

; With
[
  "maxDescriptorPerRecord"
  "RecordVisibilityContext"
  "Security_Enforced"
  "supportsDomains"
  "supportsDelegates"
  "System_Mode"
  "User_Mode"
  "UserId"
] @constant
