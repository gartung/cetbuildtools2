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
#[[.rst:
.. cmake:command:: set_ifnot(<varname> <value>)

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

