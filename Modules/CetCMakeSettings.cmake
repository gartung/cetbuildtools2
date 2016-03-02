#.rst:
# CetCMakeSettings
# ----------------
#
# Set defaults for CMake build settings as useful or required for
# building CET projects. Where appropriate, these settings may be
# changed via command line arguments to cmake or through ccmake/cmake-gui
# interfaces.
#

#-----------------------------------------------------------------------
# Copyright 2016 Ben Morgan <Ben.Morgan@warwick.ac.uk>
# Copyright 2016 University of Warwick
#
# Distributed under the OSI-approved BSD 3-Clause License (the "License");
# see accompanying file LICENSE for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
#.rst:
# General Build Settings
# ^^^^^^^^^^^^^^^^^^^^^^
#
# .. cmake:variable:: CET_BUILD_NO_UNINSTALL_TARGET
#
#   Option to disable creation of an ``uninstall`` target for the project.
#   ``OFF`` by default, and marked as advanced.
#
#   See the documentation of the ``CetUninstallTarget``
#   module for more details on what this target does.
#

option(CET_BUILD_NO_UNINSTALL_TARGET "Disable creation of an `uninstall` target" OFF)
mark_as_advanced(CET_BUILD_NO_UNINSTALL_TARGET)

if(NOT CET_BUILD_NO_UNINSTALL_TARGET)
  include("${CMAKE_CURRENT_LIST_DIR}/CetUninstallTarget.cmake")
endif()

#.rst:
# CTest/Testing Settings
# ^^^^^^^^^^^^^^^^^^^^^^
#
# .. cmake:variable:: BUILD_TESTING
#
#   Option to enable test infrastructure and settings, ``ON`` by default.
#   After inclusion of this module, use CMake conditionals on ``BUILD_TESTING`` like
#
#   .. code-block:: cmake
#
#     if(BUILD_TESTING)
#       # ... code to create/build/configure tests ...
#     endif()
#
#   to only build/define tests when the variable is set.
#
#   At present, enabling testing only supports direct testing rather than
#   use of the :cmake:module:`CTest <cmake:module:CTest>` module.
#
#   .. todo::
#
#     Add support for CTest. Should be matter of checking for
#     a `CTestConfig.cmake` file in the project source dir.
#

option(BUILD_TESTING "Enable and build tests for this project" ON)

if(BUILD_TESTING)
  enable_testing()
endif()

