#.rst:
# CetCMakeUtilities
# -----------------
#
# Cetbuildtools2 utility functions and macros
#

#-----------------------------------------------------------------------
# Copyright 2016 Ben Morgan <Ben.Morgan@warwick.ac.uk>
# Copyright 2016 University of Warwick

#-----------------------------------------------------------------------
# Core CMake modules
include(CMakeParseArguments)

#-----------------------------------------------------------------------
#[[.rst:
.. cmake:command:: set_ifnot

  .. code-block:: cmake

    set_ifnot(<varname> <value>)

  :cmake:command:`Macro <cmake:command:macro>` that sets the value of the variable ``<varname>`` to
  the given ``<value>`` if ``<varname>`` evaluates to FALSE. For example,

  .. code-block:: cmake

    set(MYVARIABLE ) # empty variable
    set_ifnot(MYVARIABLE "newvalue")
    message(STATUS "MYVARIABLE = ${MYVARIABLE}") # Prints "MYVARIABLE = newvalue"

#]]
macro(set_ifnot _var _value)
  if(NOT ${_var})
    set(${_var} ${_value})
  endif()
endmacro()


#-----------------------------------------------------------------------
#[[.rst:
.. cmake:command:: enum_option

  .. code-block:: cmake

    enum_option(<option>
                VALUES   <value1> ... <valueN>
                TYPE     <valuetype>
                DOC      <docstring>
                [DEFAULT <value>]
                [CASE_INSENSITIVE])

  :cmake:command:`Function <cmake:command:function>` Declaring a cache
  variable ``<option>`` that can only take values in the ``VALUES`` list.
  If the ``<option>`` variable is set to a value other than one of these
  values, a fatal error is emitted.

  ``TYPE`` may be set to "FILEPATH", "PATH" or "STRING".

  ``<docstring>`` should describe the option, and will appear in
  the interactive CMake interfaces.

  If ``DEFAULT`` is provided, its ``<value>`` argument will be used as
  the the value to which `<option>` should default to if not yet set.
  Otherwise, the first entry in VALUES is used as the
  default. Obviously, ``<value>`` must occur in the ``VALUES`` list.

  If ``CASE_INSENSITIVE`` is supplied, then checks of the value of
  ``<option>`` against the allowed values will ignore the case when
  performing string comparison. All values are converted to lowercase.

  For example,

  .. code-block:: cmake

    enum_option(CXX_STANDARD
                VALUES    "c++11" "c++14" "c++17"
                TYPE      STRING
                DOCSTRING "Choose the C++ Standard"
                DEFAULT   "c++14"
                )

  Would create a cache variable named ``CXX_STANDARD`` with a default
  value of "c++14" that could be set to "c++11", "c++14" or "c++17".
  With ``CASE_INSENSITIVE``

  .. code-block:: cmake

    enum_option(CXX_STANDARD
                VALUES    "c++11" "c++14" "c++17"
                TYPE      STRING
                DOCSTRING "Choose the C++ Standard"
                DEFAULT   "c++14"
                CASE_INSENSITIVE
                )

  the behaviour and values that ``CXX_STANDARD`` can take are identical,
  but the user could set the value as "C++11", "C++14" or "C++17" in
  addition the lowercase equivalents. This is intended to provide a
  little more freedom to the user whilst maintaining a clear internal
  set of values.
#]]
function(enum_option _var)
  set(options CASE_INSENSITIVE)
  set(oneValueArgs DOC TYPE DEFAULT)
  set(multiValueArgs VALUES)
  cmake_parse_arguments(_ENUMOP "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # - Validation as needed arguments
  if(NOT _ENUMOP_VALUES)
    message(FATAL_ERROR "enum_option must be called with non-empty VALUES\n(Called for enum_option '${_var}')")
  endif()

  # - Set argument defaults as needed
  if(_ENUMOP_CASE_INSENSITIVE)
    set(_ci_values )
    foreach(_elem ${_ENUMOP_VALUES})
      string(TOLOWER "${_elem}" _ci_elem)
      list(APPEND _ci_values "${_ci_elem}")
    endforeach()
    set(_ENUMOP_VALUES ${_ci_values})
  endif()

  set_ifnot(_ENUMOP_TYPE STRING)
  list(GET _ENUMOP_VALUES 0 _default)
  if(_ENUMOP_DEFAULT)
    list(FIND _ENUMOP_VALUES "${_ENUMOP_DEFAULT}" _default_index)
    if(_default_index GREATER -1)
      list(GET _ENUMOP_VALUES ${_default_index} _default)
    else()
      message(FATAL_ERROR "enum_option DEFAULT value '${_ENUMOP_DEFAULT}' not present in value set '${_ENUMOP_VALUES}'\n")
    endif()
  endif()

  if(NOT DEFINED ${_var})
    set(${_var} ${_default} CACHE ${_ENUMOP_TYPE} "${_ENUMOP_DOC} (${_ENUMOP_VALUES})")
  else()
    set(_var_tmp ${${_var}})
    if(_ENUMOP_CASE_INSENSITIVE)
      string(TOLOWER ${_var_tmp} _var_tmp)
    endif()

    list(FIND _ENUMOP_VALUES ${_var_tmp} _elem)
    if(_elem LESS 0)
      message(FATAL_ERROR "enum_option value '${${_var}}' for variable ${_var} is not allowed\nIt must be selected from the set: ${_ENUMOP_VALUES} (DEFAULT: ${_default})\n")
    else()
      # - convert to lowercase
      if(_ENUMOP_CASE_INSENSITIVE)
        set(${_var} ${_var_tmp} CACHE ${_ENUMOP_TYPE} "${_ENUMOP_DOC} (${_ENUMOP_VALUES})" FORCE)
      endif()
    endif()
  endif()
endfunction()


#-----------------------------------------------------------------------
# BOOST.UNIT HELPERS
#-----------------------------------------------------------------------
# Many places where Boost.unit is used.
# Generally always boils down to setting a couple of target properties
# and linking said target to the Boost.Unit library.
# Encapsulate this in a function taking the target to be "Boost.Unitified"
# Will need review if additional use cases/styles of use are encountered
# TODO: Error checking

# - Apply needed properties

#-----------------------------------------------------------------------
#[[.rst:
.. cmake:command:: set_boost_unit_properties

  .. code-block:: cmake

    set_boost_unit_properties(<target>)

  :cmake:command:`Function <cmake:command:function>` to apply compile
  definitions, include directories and link libraries to build target
  ``<target>`` as a Boost.Unit test. If ``<target>`` is not a valid
  CMake target (executable or library), a FATAL_ERROR is raised.

  The target properties are appended with:

  - ``COMPILE_DEFINITIONS``: ``-DBOOST_TEST_DYN_LINK`` for libraries
    and executables, with the latter also having ``-DBOOST_TEST_MAIN``
    appended.

  - ``INCLUDE_DIRECTORIES``: value of ``Boost_INCLUDE_DIRS``

  - ``LINK_LIBRARIES``: value of ``Boost_UNIT_TEST_FRAMEWORK_LIBRARY``

  These settings assume that Boost has been located using CMake's
  builtin :cmake:module:`FindBoost <cmake:module:FindBoost>` module
  before being called. If the CMake variables ``Boost_FOUND`` or
  ``Boost_UNIT_TEST_FRAMEWORK_LIBRARY`` are not set, the function
  raises a FATAL_ERROR. At present, no checking of Release vs Debug
  Boost libraries is performed.

  .. todo::

    Review usage of imported targets in CMake 3.5's FindBoost!

#]]
function(set_boost_unit_properties _target)
  if(NOT TARGET ${_target})
    message(FATAL_ERROR "set_boost_unit_properties: input '${_target}' is not a valid CMake target")
  endif()

  # - ASSUMPTION - FindBoost has been used...
  if(NOT Boost_FOUND)
    message(FATAL_ERROR
      "set_boost_unit_properties: Boost not found\n"
      "Ensure the project calls\n"
      "find_package(Boost REQUIRED unit_test_framework)\n"
      "before using this function"
      )
  endif()
  if(NOT Boost_UNIT_TEST_FRAMEWORK_LIBRARY)
    message(FATAL_ERROR
      "set_boost_unit_properties: No Boost_UNIT_TEST_FRAMEWORK_LIBRARY found\n"
      "Ensure the project calls\n"
      "find_package(Boost REQUIRED unit_test_framework)\n"
      "before using this function"
      )
  endif()

  # Append, don't overwrite, compile definitions.
  # All target types need(or rather use) BOOST_TEST_DYN_LINK
  # BOOST_TEST_MAIN for executables only
  set_property(TARGET ${_target}
    APPEND PROPERTY
      COMPILE_DEFINITIONS
        BOOST_TEST_DYN_LINK
        $<$<STREQUAL:$<TARGET_PROPERTY:${_target},TYPE>,EXECUTABLE>:BOOST_TEST_MAIN>
    )

  # PRIVATE incs/libs for now as is assumed tests will not be installed
  # include directories - make private for now
  target_include_directories(${_target} PRIVATE ${Boost_INCLUDE_DIRS})
  # libs to link - can't specify link rule here as others may use it.
  target_link_libraries(${_target} ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})
endfunction()
#-----------------------------------------------------------------------
# END OF BOOST.UNIT HELPERS
#-----------------------------------------------------------------------


