# - Create/add tests for cetbuildtools2

# Sanity
add_test(NAME sanity COMMAND ${CMAKE_COMMAND} --version)

# Utilities
# - set_ifnot
add_test(
  NAME testCetCMakeUtilities
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testCetCMakeUtilities.cmake
  )

# - enum_option
add_test(
  NAME testEnumOption_Default
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testEnumOption.cmake
  )
set_tests_properties(testEnumOption_Default
  PROPERTIES PASS_REGULAR_EXPRESSION "baz alice"
  )

add_test(
  NAME testEnumOption_Basic
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -DFOOBAR=foo
          -DCASEISALTERED=bob
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testEnumOption.cmake
  )
set_tests_properties(testEnumOption_Basic
  PROPERTIES PASS_REGULAR_EXPRESSION "foo bob"
  )

add_test(
  NAME testEnumOption_OutOfSet
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -DFOOBAR=alice
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testEnumOption.cmake
  )
set_tests_properties(testEnumOption_OutOfSet
  PROPERTIES WILL_FAIL TRUE
  )

add_test(
  NAME testEnumOption_BadCase
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -DFOOBAR=Foo
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testEnumOption.cmake
  )
set_tests_properties(testEnumOption_BadCase
  PROPERTIES WILL_FAIL TRUE
  )

add_test(
  NAME testEnumOption_CaseInsensitive
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -DCASEISALTERED=AlICe
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testEnumOption.cmake
  )
set_tests_properties(testEnumOption_CaseInsensitive
  PROPERTIES PASS_REGULAR_EXPRESSION "baz alice"
  )

# - Boost.Unit
# TODO: Needs implementing as a mini-project(s)
add_test(
  NAME testBoostUnitProperties
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testBoostUnitProperties.cmake
  )

#-----------------------------------------------------------------------
# CetInstallDirs tests
add_test(
  NAME testCetInstallDirs_Basic
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testCetInstallDirs.cmake
  )

#-----------------------------------------------------------------------
# CetWriteCXXVersionAPI test
#
add_test(
  NAME testCetWriteCXXVersionAPI_build_and_run
  COMMAND ${CMAKE_CTEST_COMMAND}
          --build-and-test ${CMAKE_CURRENT_LIST_DIR}/testCetWriteCXXVersionAPI ${CMAKE_CURRENT_BINARY_DIR}/testCetWriteCXXVersionAPI
          --build-generator ${CMAKE_GENERATOR}
          --build-makeprogram ${CMAKE_MAKE_PROGRAM}
          --build-config $<CONFIG>
          --build-options "-DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules"

          --test-command testCetWriteCXXVersionAPI
  )

#-----------------------------------------------------------------------
# CetCMakeSettings test
#
add_test(
  NAME testCetCMakeSettings_sanity
  COMMAND ${CMAKE_CTEST_COMMAND}
          --build-and-test ${CMAKE_CURRENT_LIST_DIR}/testCetCMakeSettings ${CMAKE_CURRENT_BINARY_DIR}/testCetCMakeSettings_sanity
          --build-generator ${CMAKE_GENERATOR}
          --build-makeprogram ${CMAKE_MAKE_PROGRAM}
          --build-config $<CONFIG>
          --build-options "-Dcetbuildtools2_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules"
  )




