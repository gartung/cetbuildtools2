include(CetCMakeUtilities)

function(testSetIfNot)
  # - empty variable
  set(testvar )
  set_ifnot(testvar "emptyvar")
  if(NOT testvar STREQUAL "emptyvar")
    message(FATAL_ERROR
      "set_ifnot:emptyvariable:fail\n"
      "expected 'empty', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:emptyvariable:ok")
  endif()

  # - empty string
  set(testvar "")
  set_ifnot(testvar "emptystring")
  if(NOT testvar STREQUAL "emptystring")
    message(FATAL_ERROR
      "set_ifnot:emptyvariable:fail\n"
      "expected 'emptystring', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:emptystring:ok")
  endif()

  # - NOTFOUND
  set(testvar "testvar-NOTFOUND")
  set_ifnot(testvar "foundit")
  if(NOT testvar STREQUAL "foundit")
    message(FATAL_ERROR
      "set_ifnot:notfound:fail\n"
      "expected 'foundit', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:foundit:ok")
  endif()

  # - Boolean False
  set(testvar FALSE)
  set_ifnot(testvar TRUE)
  if(NOT testvar)
    message(FATAL_ERROR
      "set_ifnot:booleanfalse:fail\n"
      "expected 'TRUE', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:booleanfalse:ok")
  endif()

  # - Boolean True
  set(testvar TRUE)
  set_ifnot(testvar "badfunction")
  if(testvar STREQUAL "badfunction")
    message(FATAL_ERROR
      "set_ifnot:booleantrue:fail\n"
      "expected 'TRUE', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:booleantrue:ok")
  endif()

  # - String
  set(testvar "isset")
  set_ifnot(testvar "badfunction")
  if(NOT testvar STREQUAL "isset")
    message(FATAL_ERROR
      "set_ifnot:isset:fail\n"
      "expected 'isset', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:isset:ok")
  endif()

  # - unset
  unset(testvar)
  set_ifnot(testvar "unset")
  if(NOT testvar STREQUAL "unset")
    message(FATAL_ERROR
      "set_ifnot:unset:fail\n"
      "expected 'unset', got '${testvar}'"
      )
  else()
    message(STATUS "set_ifnot:unset:ok")
  endif()

endfunction()


testSetIfNot()

