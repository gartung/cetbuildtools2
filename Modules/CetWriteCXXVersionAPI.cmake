#.rst:
# CetWriteCXXVersionAPI
# ---------------------

#-----------------------------------------------------------------------
# Copyright 2016 Ben Morgan <Ben.Morgan@warwick.ac.uk>
# Copyright 2016 University of Warwick
#
# Distributed under the OSI-approved BSD 3-Clause License (the "License");
# see accompanying file License.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Setup
#
set(__cet_write_cxx_version_api_dir "${CMAKE_CURRENT_LIST_DIR}")
include(CMakeParseArguments)
include(CetCMakeUtilities)

#-----------------------------------------------------------------------
#[[.rst:
.. cmake:command:: cet_write_cxx_version_api

  .. code-block:: cmake

    cet_write_cxx_version_api(NAMESPACE      <ns>
                              TYPENAME       <type>
                              [HEADER_FILE   <path>])

  Write C++ header and source files defining a compile and runtime
  API for reporting and checking project version numbers following
  MAJOR.MINOR.PATCH style versioning.

  Identifiers for the C++ namespace and struct holding the API as member
  functions must be specified using the ``NAMESPACE`` and ``TYPENAME``
  arguments. ``NAMESPACE`` may be as many levels deep as you require.
  For example, setting ``NAMESPACE`` to "Foo::Bar" and ``TYPENAME``
  to "Version" constructs a forward declaration and struct definition:

  .. code-block:: cpp

    namespace Foo {
      namespace Bar {
        struct Version;
        }
    }

    struct Foo::Bar::Version {
      // functions
    };

  By default the header and source file are output in the current binary
  directory and named "``<type>.h``" and "``<type>.cc``". This may be modified
  using the ``HEADER_FILE`` argument, supplying ``<path>`` as the required
  output location and name (including extension) of the header. The resultant
  source file will be output alongside the header with the same name plus
  an additional ``.cc`` extension. If ``<path>`` is supplied as a relative
  path, it is evaluated relative to the current binary directory.

  Version component values are taken from the CMake variables
  ``<PROJECT_NAME>_VERSION_MAJOR``, ``<PROJECT_NAME>_VERSION_MINOR`` and
  ``<PROJECT_NAME>_VERSION_PATCH`` are used. A FATAL_ERROR is raised
  if any of these is not defined. If the variable is defined but empty,
  the version component is taken as 0.

  The header file macros, struct and member functions are documented
  using Doxygen style markup.

  The generated source file includes the header file using an absolute
  path, so it can be compiled into a target without additional setting
  of include directories of compile definitions.
#]]
function(cet_write_cxx_version_api)
  cmake_parse_arguments(CXXAPI
    ""
    "NAMESPACE;TYPENAME;HEADER_FILE"
    ""
    ${ARGN}
    )

  # - Validate arguments
  if(NOT CXXAPI_NAMESPACE)
    message(FATAL_ERROR "cet_write_cxx_version_api: NAMESPACE argument must be provided")
  endif()

  if(NOT CXXAPI_TYPENAME)
    message(FATAL_ERROR "cet_write_cxx_version_api: TYPENAME argument must be provided")
  endif()

  # - Check/set versions
  foreach(__version_component "MAJOR" "MINOR" "PATCH")
    if(NOT DEFINED ${PROJECT_NAME}_VERSION_${__version_component})
      message(FATAL_ERROR "cet_write_cxx_version_api: ${PROJECT_NAME}_VERSION_${__version_component} variable must be defined")
    endif()

    set(CXXAPI_VERSION_${__version_component} ${${PROJECT_NAME}_VERSION_${__version_component}})
    if(CXXAPI_VERSION_${__version_component} STREQUAL "")
      set(CXXAPI_VERSION_${__version_component} 0)
    endif()
  endforeach()

  # Project setting - only for Doxygen markup
  set(CXXAPI_PROJECT_NAME "${PROJECT_NAME}")

  # - File paths/names
  set_ifnot(CXXAPI_HEADER_FILE "${CXXAPI_TYPENAME}.h")
  set(CXXAPI_SOURCE_FILE "${CXXAPI_HEADER_FILE}.cc")
  if(NOT IS_ABSOLUTE "${CXXAPI_HEADER_FILE}")
    set(CXXAPI_HEADER_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CXXAPI_HEADER_FILE}")
    set(CXXAPI_SOURCE_FILE "${CMAKE_CURRENT_BINARY_DIR}/${CXXAPI_SOURCE_FILE}")
  endif()
  get_filename_component(CXXAPI_HEADER_FILENAME "${CXXAPI_HEADER_FILE}" NAME)

  string(TOUPPER "${CXXAPI_NAMESPACE}" CXXAPI_PREPROCESSOR_PREFIX)
  string(REPLACE "::" "_" CXXAPI_PREPROCESSOR_PREFIX "${CXXAPI_PREPROCESSOR_PREFIX}")

  # If we want a GUID in the include guard, here's one way to do it.
  # Generally, the various names should be unique enough to identify
  # the header.
  #string(RANDOM ALPHABET "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" CXXAPI_GUID)
  #set(CXXAPI_GUID "_${CXXAPI_GUID}")

  # - Create open/close namespace defs (until C++17)
  # Open...
  string(REGEX REPLACE "::([a-zA-Z0-9_]+)" " { namespace \\1" CXXAPI_OPEN_NAMESPACE "${CXXAPI_NAMESPACE}")
  # Close...
  string(REGEX MATCHALL "::" CXXAPI_NAMESPACE_LEVELS "${CXXAPI_NAMESPACE}")
  foreach(_level ${CXXAPI_NAMESPACE_LEVELS})
    list(APPEND CXXAPI_CLOSE_NAMESPACE "}")
  endforeach()

  # - Create the header and source files
  configure_file("${__cet_write_cxx_version_api_dir}/version.h.in"
    "${CXXAPI_HEADER_FILE}"
    @ONLY
    )
  configure_file("${__cet_write_cxx_version_api_dir}/version.cpp.in"
    "${CXXAPI_SOURCE_FILE}"
    @ONLY
    )
endfunction()

