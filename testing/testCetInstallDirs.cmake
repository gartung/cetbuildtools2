# - Mock project name
set(PROJECT_NAME "TestCetInstallDirs")

include(CetInstallDirs)

# - Sanity checks
foreach(__dir
    BINDIR
    SBINDIR
    LIBEXECDIR
    SYSCONFDIR
    SHAREDSTATEDIR
    LOCALSTATEDIR
    LIBDIR
    INCLUDEDIR
    OLDINCLUDEDIR
    DATAROOTDIR
    DATADIR
    INFODIR
    LOCALEDIR
    MANDIR
    DOCDIR
    CMAKEDIR
    FHICLDIR
    GDMLDIR
    )
  if(NOT DEFINED CMAKE_INSTALL_${__dir})
    message(FATAL_ERROR "cetinstalldirs:error:CMAKE_INSTALL_${__dir} not defined")
  else()
    message(STATUS "cetinstalldirs:pass:CMAKE_INSTALL_${__dir} defined")
  endif()
endforeach()

# Checks on extensions
if(NOT CMAKE_INSTALL_CMAKEDIR STREQUAL "${CMAKE_INSTALL_LIBDIR}/cmake")
  message(FATAL_ERROR
    "cetinstalldirs:error: CMAKE_INSTALL_CMAKEDIR has wrong value\n"
    "Expected '${CMAKE_INSTALL_LIBDIR}/cmake' , Got '${CMAKE_INSTALL_CMAKEDIR}'"
    )
else()
  message(STATUS "cetinstalldirs:pass:CMAKE_INSTALL_CMAKEDIR has correct value")
endif()

if(NOT CMAKE_INSTALL_FHICLDIR STREQUAL "${CMAKE_INSTALL_DATAROOTDIR}/fhicl/${PROJECT_NAME}")
  message(FATAL_ERROR
    "cetinstalldirs:error: CMAKE_INSTALL_FHICLDIR has wrong value\n"
    "Expected '${CMAKE_INSTALL_DATAROOTDIR}/fhicl/${PROJECT_NAME}' , Got '${CMAKE_INSTALL_FHICLDIR}'"
    )
else()
  message(STATUS "cetinstalldirs:pass:CMAKE_INSTALL_FHICLDIR has correct value")
endif()

if(NOT CMAKE_INSTALL_GDMLDIR STREQUAL "${CMAKE_INSTALL_DATAROOTDIR}/gdml/${PROJECT_NAME}")
  message(FATAL_ERROR
    "cetinstalldirs:error: CMAKE_INSTALL_GDMLDIR has wrong value\n"
    "Expected '${CMAKE_INSTALL_DATAROOTDIR}/gdml/${PROJECT_NAME}' , Got '${CMAKE_INSTALL_GDMLDIR}'"
    )
else()
  message(STATUS "cetinstalldirs:pass:CMAKE_INSTALL_GDMLDIR has correct value")
endif()

