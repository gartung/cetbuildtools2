#.rst:
# CetCompilerSettings
# -------------------
#
# .. code-block:: cmake
#
#   include(CetCompilerSettings)
#
# Sets CET Build Modes and Compiler Flags when included.
#
# Include this module to configure your project to use the CET standard
# build modes and C/C++/Fortran compiler flags. CMake options and functions
# are provided to manage warning levels, debugging format, symbol resolution
# policy, architecture level optimization and assertion activation.
#

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
# - Prevent more than one inclusion per project call
if(NOT __cet_compiler_configuration_loaded)
  set(__cet_compiler_configuration_loaded TRUE)
else()
  return()
endif()

include(CetCMakeUtilities)

#-----------------------------------------------------------------------
#.rst:
# CET Base Compiler Flags and Build Types
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Base flags for a language, that is ``CMAKE_<LANG>_FLAGS`` are always
# set by prepending any required to the existing value of the ``CMAKE_<LANG>_FLAGS``
# variable. This enables a project or environment to override or extend
# flags by setting ``CMAKE_<LANG>_FLAGS`` in their own CMake scripts before
# including this module.
#
# Additional flags are added depending on the build mode being used,
# and CET uses the same set as defined by vanilla CMake:
#
# * ``None``: Base language flags only
# * ``Release``: Highest optimization possible, debugging information
# * ``Debug``: No optimization, debugging information
# * ``MinSizeRel``: Highest optimization possible, debugging information plus frame pointer
# * ``RelWithDebInfo``: Moderate optimization, debugging info
#
# For the GNU, Clang and Intel C/C++ compilers, these correspond to
# flags for optimization and debugging of:
#
# * ``Release``: ``-O3 -g``
# * ``Debug``: ``-O0 -g``
# * ``MinSizeRel``: ``-O3 -g -fno-omit-frame-pointer``
# * ``RelWithDebInfo``: ``-O2 -g``
#
# When building for single mode generators like Make and Ninja,
# the build type defaults to ``RelWithDebInfo`` if it is not already
# set.

#-----------------------------------------------------------------------
#.rst:
# Options for Controlling Compiler Warnings
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# .. cmake:variable:: CET_COMPILER_DIAGNOSTIC_LEVEL
#
#   Option to select the level of compiler diagnostics to add to flags.
#   The warnings checked for by the compiler are defined in CET by four
#   levels, with the following flags prepended to ``CMAKE_C_FLAGS`` and ``CMAKE_CXX_FLAGS``.
#   At present, diagnostic selection is only enabled for C and C++ languages
#   and when using the GNU, Clang or Intel compilers.
#
#   * ``CAVALIER``
#
#     * No additional flags added for any compiler
#
#   * ``CAUTIOUS`` (default)
#
#     * All ``CAVALIER`` flags for the compiler in use, plus
#     * GNU/Intel compilers: ``-Wall -Werror=return-type``
#     * Clang compilers: ``-Wall -Werror=return-type -Wno-mismatched-tags -Wno-missing-braces``
#
#   * ``VIGILANT``
#
#     * All ``CAUTIOUS`` flags for the compiler in use, plus
#     * GNU/Clang compilers: ``-Wextra -Wno-long-long -Winit-self -Wno-unused-local-typedefs``
#     * Intel compilers: ``-Wextra -Wno-long-long -Winit-self``
#     * GNU/Clang/Intel C++ compilers also add: ``-Woverloaded-virtual``
#
#   * ``PARANOID``
#
#     * All ``VIGILANT`` flags for the compiler in use, plus
#     * GNU/Clang/Intel compilers: ``-pedantic -Wformat-y2k -Wswitch-default -Wsync-nand -Wtrampolines -Wlogical-op -Wshadow -Wcast-qual``
#     * NB: these are known to be GNU specific at present, but are retained until
#       a good set for each compiler can be developed.
#
enum_option(CET_COMPILER_DIAGNOSTIC_LEVEL
  VALUES CAVALIER CAUTIOUS VIGILANT PARANOID
  TYPE STRING
  DEFAULT CAUTIOUS
  DOC "Set warning diagnostic level"
  )

#.rst:
# .. cmake:variable:: CET_COMPILER_WARNINGS_ARE_ERRORS
#
#  Option to turn compiler warnings into hard errors. ``ON`` by default.
#
option(CET_COMPILER_WARNINGS_ARE_ERRORS "treat all warnings as errors" ON)

#.rst:
# .. cmake:variable:: CET_COMPILER_ALLOW_DEPRECATIONS
#
#   Option to ignore deprecation warnings. ``ON`` by default.
#   It only has an effect if ``CET_COMPILER_WARNINGS_ARE_ERRORS`` is
#   activated (this matches upstream `cetbuildtools` behaviour.
#
option(CET_COMPILER_ALLOW_DEPRECATIONS "ignore deprecation warnings" ON)

mark_as_advanced(
  CET_COMPILER_WARNINGS_ARE_ERRORS
  CET_COMPILER_ALLOW_DEPRECATIONS
  CET_COMPILER_DIAGNOSTIC_LEVEL
  )

# - Diagnostics by language/compiler
foreach(_lang "C" "CXX")
  # GNU/Clang/Intel are mostly common...
  if(CMAKE_${_lang}_COMPILER_ID MATCHES "GNU|(Apple)+Clang|Intel")
    # C/C++ common
    # - Basic
    set(CET_COMPILER_${_lang}_DIAGFLAGS_CAVALIER "")

    # - Cautious
    set(CET_COMPILER_${_lang}_DIAGFLAGS_CAUTIOUS "${CET_COMPILER_${_lang}_DIAGFLAGS_CAVALIER} -Wall -Werror=return-type")
    # Clang's -Wall activates a larger number of warnings than GCC, and
    # can lead to spurious warnings, so turn the following off:
    # mismatched-tags : Seemingly only needed for systems that may
    #                   mangle struct/class differently
    # missing-braces  : Down to parsing/standard behaviour, see
    #                   https://gcc.gnu.org/bugzilla/show_bug.cgi?id=25137
    #                   https://llvm.org/bugs/show_bug.cgi?id=21629
    if(CMAKE_${_lang}_COMPILER_ID MATCHES "(Apple)+Clang")
      set(CET_COMPILER_${_lang}_DIAGFLAGS_CAUTIOUS "${CET_COMPILER_${_lang}_DIAGFLAGS_CAVALIER} -Wno-mismatched-tags -Wno-missing-braces")
    endif()

    # - Vigilant
    set(CET_COMPILER_${_lang}_DIAGFLAGS_VIGILANT "${CET_COMPILER_${_lang}_DIAGFLAGS_CAUTIOUS} -Wextra -Wno-long-long -Winit-self")

    # We want -Wno-unused-local-typedef in VIGILANT, but Intel doesn't know this
    if(NOT CMAKE_${_lang}_COMPILER_ID STREQUAL "Intel")
      set(CET_COMPILER_${_lang}_DIAGFLAGS_VIGILANT "${CET_COMPILER_${_lang}_DIAGFLAGS_VIGILANT} -Wno-unused-local-typedefs")
    endif()

    # Additional CXX option for VIGILANT
    if(${_lang} STREQUAL "CXX")
      set(CET_COMPILER_CXX_DIAGFLAGS_VIGILANT "${CET_COMPILER_CXX_DIAGFLAGS_VIGILANT} -Woverloaded-virtual")
    endif()

    # - Paranoid
    set(CET_COMPILER_${_lang}_DIAGFLAGS_PARANOID "${CET_COMPILER_${_lang}_DIAGFLAGS_VIGILANT} -pedantic -Wformat-y2k -Wswitch-default -Wsync-nand -Wtrampolines -Wlogical-op -Wshadow -Wcast-qual")
  endif()
endforeach()

if(CET_COMPILER_WARNINGS_ARE_ERRORS)
  foreach(_lang "C" "CXX")
    if(CMAKE_${_lang}_COMPILER_ID MATCHES "GNU|(Apple)+Clang|Intel")
      set(CET_COMPILER_${_lang}_ERROR_FLAGS "-Werror")
      if(CET_COMPILER_ALLOW_DEPRECATIONS)
        set(CET_COMPILER_${_lang}_ERROR_FLAGS "${CET_COMPILER_${_lang}_ERROR_FLAGS} -Wno-error=deprecated-declarations")
      endif()
    endif()
  endforeach()
endif()

#-----------------------------------------------------------------------
#.rst:
# Options for Controlling Debugging Output
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# For compatible compilers, the version and strictness of DWARF
# debugging output may be controlled
#
# .. cmake:variable:: CET_COMPILER_DWARF_STRICT
#
#   Option to only emit DWARF debugging info at the level set by
#   ``CET_COMPILER_DWARF_VERSION``. ``ON`` by default.
#
# .. todo::
#
#   Current flags are GCC dependent. Review them for Clang and Intel
#
option(CET_COMPILER_DWARF_STRICT "only emit DWARF debugging info at defined level" ON)

# .. cmake:variable:: CET_COMPILER_DWARF_VERSION
#
#   Version of DWARF standard that should be emitted. Defaults to 2.
#
enum_option(CET_COMPILER_DWARF_VERSION
  VALUES 2 3 4
  TYPE STRING
  DOC "Set version of DWARF standard to emit"
  )

mark_as_advanced(
  CET_COMPILER_DWARF_STRICT
  CET_COMPILER_DWARF_VERSION
  )

# Probably also need check that compiler in use supports DWARF...
# NOTE: Clang doesn't provide -gstrict-dwarf flag (simply ignores it and
# warns it's unused), but has further options for emitting debugging
# such as tuning output for gdb, lldb, sce.
# Dwarf version may also not be needed here.
foreach(_lang "C" "CXX")
  if(CMAKE_${_lang}_COMPILER_ID MATCHES "GNU|(Apple)+Clang|Intel")
    set(CET_COMPILER_${_lang}_DWARF_FLAGS "-gdwarf-${CET_COMPILER_DWARF_VERSION}")
    if(CET_COMPILER_DWARF_STRICT)
      set(CET_COMPILER_${_lang}_DWARF_FLAGS "${CET_COMPILER_${_lang}_DWARF_FLAGS} -gstrict-dwarf")
    endif()
  endif()
endforeach()

#-----------------------------------------------------------------------
#.rst:
# Options for Controlling Symbol Resolution
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Linkers may have different default policies for symbol resolution.
# CET prefer to fully resolved symbols.
#
# .. cmake:variable:: CET_COMPILER_NO_UNDEFINED_SYMBOLS
#
#   Option to control whether the linker must fully resolve symbols for
#   shared libraries. ``ON`` by default.
#
option(CET_COMPILER_NO_UNDEFINED_SYMBOLS "required full symbol resolution for shared libs" ON)
mark_as_advanced(CET_COMPILER_NO_UNDEFINED_SYMBOLS)

if(CET_COMPILER_NO_UNDEFINED_SYMBOLS)
  if(APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,error")
  else()
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
  endif()
elseif(APPLE)
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-undefined,dynamic_lookup")
endif()

#-----------------------------------------------------------------------
#.rst:
# Architecture Level Optimizations
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
# Things like SSE/Vectorization...
#
# .. cmake:variable:: CET_COMPILER_ENABLE_SSE2
#
#   Enable specific optimizations for SSE2. ``OFF`` by default.
#
#   Note that this does not check that the system you are building
#   for supports this instruction set.
#
# .. todo::
#
#   Review options here for further checks and/or arch-specific optimizations.
#
option(CET_COMPILER_ENABLE_SSE2 "enable SSE2 specific optimizations" OFF)
mark_as_advanced(CET_COMPILER_ENABLE_SSE2)

if(CET_COMPILER_ENABLE_SSE2)
  foreach(_lang "C" "CXX")
    if(CMAKE_${_lang}_COMPILER_ID MATCHES "GNU|(Apple)+Clang|Intel")
      set(CET_COMPILER_${_lang}_SSE2_FLAGS "-msse2 -ftree-vectorizer-verbose")
    endif()
  endforeach()
endif()

#-----------------------------------------------------------------------
#.rst:
# Assertion Management
# ^^^^^^^^^^^^^^^^^^^^
#
# Cetbuildtools2 allows fine control over assertions by managing their
# deactivation (passing ``NDEBUG`` as a preprocessor define) on a
# directory-by-directory basis.
#
# The default policy is to only disable assertions in the Release and
# MinSizeRel build types.
#
# .. todo::
#
#   Describe directory property behaviour
#

option(CET_COMPILER_ENABLE_ASSERTS "enable assertions for all build modes" OFF)
mark_as_advanced(CET_COMPILER_ENABLE_ASSERTS)

#-----------------------------------------------------------------------
# PRIVATE function
# Encapsulate generator expression used to set NDEBUG definition for default modes
function(__cet_get_assert_genexp VAR)
  set(${VAR} "$<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>>:NDEBUG>" PARENT_SCOPE)
endfunction()

#[[.rst:
.. cmake:command:: cet_default_asserts

  .. code-block:: cmake

    cet_default_asserts([DIRECTORY <dir>])

  Disable assertions (i.e. pass ``NDEBUG`` as a preprocessor define) for
  Release and MinSizeRel build modes in the current directory (``CMAKE_CURRENT_LIST_DIR``)
  and all its children.

  If ``DIRECTORY`` is passed, disable assertions for Release and MinSizeRel
  build modes in ``<dir>`` and all its children.
#]]
function(cet_default_asserts)
  cmake_parse_arguments(CDA
    ""
    "DIRECTORY"
    ""
    ${ARGN}
    )
  set_ifnot(CDA_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")

  # Remove settings from all modes
  cet_enable_asserts(DIRECTORY "${CDA_DIRECTORY}")

  # Disable assertions for Release-style modes
  __cet_get_assert_genexp(_cetgexp)
  set_property(DIRECTORY "${CDA_DIRECTORY}"
    APPEND PROPERTY COMPILE_DEFINITIONS ${_cetgexp}
    )
endfunction()


#[[.rst:
.. cmake:command:: cet_enable_asserts

  .. code-block:: cmake

    cet_enable_asserts([DIRECTORY <dir>])

  Enable assertions (i.e. do not pass ``NDEBUG`` as a preprocessor define) for
  all build modes in the current directory (``CMAKE_CURRENT_LIST_DIR``) and all
  its children.

  If ``DIRECTORY`` is passed, enable assertions for all build modes in ``<dir>``
  and all its children.
#]]
function(cet_enable_asserts)
  cmake_parse_arguments(CDA
    ""
    "DIRECTORY"
    ""
    ${ARGN}
    )
  set_ifnot(CDA_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")

  get_directory_property(_local_compile_defs DIRECTORY "${CDA_DIRECTORY}" COMPILE_DEFINITIONS)
  # Remove genexp and NDEBUG from list of compile definitions
  list(REMOVE_ITEM _local_compile_defs "NDEBUG")
  __cet_get_assert_genexp(_assert_genexp)
  list(REMOVE_ITEM _local_compile_defs "${_assert_genexp}")

  set_property(DIRECTORY "${CDA_DIRECTORY}"
    PROPERTY COMPILE_DEFINITIONS "${_local_compile_defs}"
    )
endfunction()

#[[.rst:
.. cmake:command:: cet_disable_asserts

  .. code-block:: cmake

    cet_disable_asserts([DIRECTORY <dir>])

  Disable assertions (i.e. pass ``NDEBUG`` as a preprocessor define) for
  all build types in the current directory (``CMAKE_CURRENT_LIST_DIR``) and all
  its children.

  If ``DIRECTORY`` is passed, disable assertions for all build types in ``<dir>``
  and all its children.
#]]
function(cet_disable_asserts)
    cmake_parse_arguments(CDA
    ""
    "DIRECTORY"
    ""
    ${ARGN}
    )
  set_ifnot(CDA_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}")

  get_directory_property(_local_compile_defs DIRECTORY "${CDA_DIRECTORY}" COMPILE_DEFINITIONS)

  # Remove genexp (not strictly neccessary, but avoids duplication
  __cet_get_assert_genexp(_assert_genexp)
  list(REMOVE_ITEM _local_compile_defs "${_assert_genexp}")
  list(APPEND _local_compile_defs "NDEBUG")

  set_property(DIRECTORY "${CDA_DIRECTORY}"
    PROPERTY COMPILE_DEFINITIONS "${_local_compile_defs}"
    )
endfunction()


#-----------------------------------------------------------------------
# Private implementation detail
# - Combine flags and set default assertions on the project source
#   directory
# - General, All Mode Options
string(TOUPPER "${CET_COMPILER_DIAGNOSTIC_LEVEL}" CET_COMPILER_DIAGNOSTIC_LEVEL)
set(CMAKE_C_FLAGS "${CET_COMPILER_C_DIAGFLAGS_${CET_COMPILER_DIAGNOSTIC_LEVEL}} ${CET_COMPILER_C_ERROR_FLAGS} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CET_COMPILER_CXX_DIAGFLAGS_${CET_COMPILER_DIAGNOSTIC_LEVEL}} ${CET_COMPILER_CXX_ERROR_FLAGS} ${CMAKE_CXX_FLAGS}")

# Per-Mode flags (Release, Debug, RelWithDebInfo, MinSizeRel)
# DWARF done here as it's not completely generic like warnings
# - C Language
if(CMAKE_C_COMPILER_ID MATCHES "GNU|(Apple)+Clang|Intel")
  set(CMAKE_C_FLAGS_RELEASE        "-O3 -g ${CET_COMPILER_C_DWARF_FLAGS}")
  set(CMAKE_C_FLAGS_DEBUG          "-O0 -g ${CET_COMPILER_C_DWARF_FLAGS}")
  set(CMAKE_C_FLAGS_MINSIZEREL     "-O3 -g ${CET_COMPILER_C_DWARF_FLAGS} -fno-omit-frame-pointer")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g")
endif()

# - CXX Language
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|(Apple)+Clang|Intel")
  set(CMAKE_CXX_FLAGS_RELEASE        "-O3 -g ${CET_COMPILER_CXX_DWARF_FLAGS}")
  set(CMAKE_CXX_FLAGS_DEBUG          "-O0 -g ${CET_COMPILER_CXX_DWARF_FLAGS}")
  set(CMAKE_CXX_FLAGS_MINSIZEREL     "-O3 -g ${CET_COMPILER_CXX_DWARF_FLAGS} -fno-omit-frame-pointer")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g")
endif()

# - Fortran language
# TODO

# SSE2 flags only in release (optimized) modes?

# Assertions are handled by compile definitions so they can be changed
# on a per directory tree basis. Set defaults here for project
cet_default_asserts(DIRECTORY "${PROJECT_SOURCE_DIR}")

# - If user requested, enable assertions in all modes
if(CET_COMPILER_ENABLE_ASSERTS)
  cet_enable_asserts(DIRECTORY "${PROJECT_SOURCE_DIR}")
endif()

# If we're generating for single-mode and no build type has been set,
# default to RelWithDebInfo
if(NOT CMAKE_CONFIGURATION_TYPES)
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE RelWithDebInfo
      CACHE STRING "Choose the type of build, options are: None Release MinSizeRel Debug RelWithDebInfo"
      FORCE
      )
  else()
    set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}"
      CACHE STRING "Choose the type of build, options are: None Release MinSizeRel Debug RelWithDebInfo"
      FORCE
      )
  endif()
endif()

