include(CetCMakeUtilities)

enum_option(FOOBAR
  VALUES "foo" "bar" "baz"
  TYPE STRING
  DEFAULT "baz"
  )

enum_option(CASEISALTERED
  VALUES "alice" "bob"
  TYPE STRING
  CASE_INSENSITIVE
  )

message("${FOOBAR} ${CASEISALTERED}")

