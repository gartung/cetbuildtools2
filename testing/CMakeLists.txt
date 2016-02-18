# - Create/add tests for cetbuildtools2

# Sanity
add_test(NAME sanity COMMAND ${CMAKE_COMMAND} --version)

# Utilities
add_test(
  NAME testCetCMakeUtilities
  COMMAND ${CMAKE_COMMAND}
          -DCMAKE_MODULE_PATH=${PROJECT_SOURCE_DIR}/Modules
          -P ${CMAKE_CURRENT_SOURCE_DIR}/testCetCMakeUtilities.cmake
  )

