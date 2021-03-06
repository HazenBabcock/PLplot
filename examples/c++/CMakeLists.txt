# examples/c++/CMakeLists.txt
### Process this file with cmake to produce Makefile
###
# Copyright (C) 2006 Andrew Ross
# Copyright (C) 2006-2016 Alan W. Irwin
#
# This file is part of PLplot.
#
# PLplot is free software; you can redistribute it and/or modify
# it under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; version 2 of the License.
#
# PLplot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public License
# along with PLplot; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

# N.B. This file is used for both the core build (which installs the examples
# and optionally [depending on BUILD_TEST} builds them) and the installed
# examples build.  The core build has BUILD_TEST OFF or ON at user option
# and CORE_BUILD always ON.  The installed examples build always has
# BUILD_TEST ON and CORE_BUILD OFF.

set(cxx_STRING_INDICES
  "01cc"
  "00"
  "01"
  "02"
  "03"
  "04"
  "05"
  "06"
  "07"
  "08"
  "09"
  "10"
  "11"
  "12"
  "13"
  "14"
  "15"
  "16"
  "17"
  "18"
  "19"
  "20"
  "21"
  "22"
  "23"
  "24"
  "25"
  "26"
  "27"
  "28"
  "29"
  "30"
  "31"
  "33"
  )

if(ENABLE_wxwidgets)
  set(wxPLplotDemo_SRCS ${wxdemo_name}.cpp)
endif(ENABLE_wxwidgets)

if(CORE_BUILD)
  set(cxx_SRCS plc++demos.h)
  foreach(STRING_INDEX ${cxx_STRING_INDICES})
    set(cxx_SRCS ${cxx_SRCS} x${STRING_INDEX}.cc)
  endforeach(STRING_INDEX ${cxx_STRING_INDICES})

  if(PLD_extqt)
    set(qt_INSTALLED_FILES qt_PlotWindow.cpp qt_PlotWindow.h qt_example.cpp README.qt_example)
  endif(PLD_extqt)

  install(FILES ${cxx_SRCS} ${wxPLplotDemo_SRCS} ${qt_INSTALLED_FILES} DESTINATION ${DATA_DIR}/examples/c++)

  set(CXX "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} ${CMAKE_CXX_FLAGS}")

  install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt
    DESTINATION ${DATA_DIR}/examples/c++
    )
endif(CORE_BUILD)

if(BUILD_TEST)
  if(CORE_BUILD)
    include_directories(
      ${CMAKE_SOURCE_DIR}/bindings/c++
      ${CMAKE_SOURCE_DIR}/include
      ${CMAKE_BINARY_DIR}/include
      ${CMAKE_SOURCE_DIR}/lib/qsastime
      )
  else(CORE_BUILD)
    include_directories(${INCLUDE_DIR})
  endif(CORE_BUILD)

  set_property(GLOBAL PROPERTY TARGETS_examples_cxx)
  foreach(STRING_INDEX ${cxx_STRING_INDICES})
    if(BUILD_SHARED_LIBS)
      set_source_files_properties(x${STRING_INDEX}.cc
        PROPERTIES COMPILE_FLAGS "-DUSINGDLL")
    endif(BUILD_SHARED_LIBS)
    add_executable(x${STRING_INDEX} x${STRING_INDEX}.cc)
    target_link_libraries(x${STRING_INDEX} plplotcxx ${MATH_LIB})
    set_property(GLOBAL APPEND PROPERTY TARGETS_examples_cxx x${STRING_INDEX})
  endforeach(STRING_INDEX ${cxx_STRING_INDICES})
endif(BUILD_TEST)

if(ENABLE_wxwidgets)
  # Build wxwidgets applications with same wxwidgets compile and link flags
  # as used with the PLplot wxwidgets device driver.
  if(CORE_BUILD)
    include_directories(
      ${CMAKE_SOURCE_DIR}/bindings/wxwidgets
      ${CMAKE_BINARY_DIR}/bindings/wxwidgets
      )
  endif(CORE_BUILD)
  if(BUILD_TEST)
    if(BUILD_SHARED_LIBS)
      set_source_files_properties(${wxPLplotDemo_SRCS}
        PROPERTIES COMPILE_FLAGS "-DUSINGDLL ${wxwidgets_COMPILE_FLAGS}")
    else(BUILD_SHARED_LIBS)
      set_source_files_properties(${wxPLplotDemo_SRCS}
        PROPERTIES COMPILE_FLAGS "${wxwidgets_COMPILE_FLAGS}")
    endif(BUILD_SHARED_LIBS)
    add_executable(wxPLplotDemo WIN32 ${wxPLplotDemo_SRCS})
    target_link_libraries(wxPLplotDemo plplotwxwidgets plplotcxx ${wxwidgets_LINK_FLAGS} ${MATH_LIB})
  endif(BUILD_TEST)
  # Transform wxwidgets_LINK_FLAGS from list of libraries to the standard pkg-config form
  # for use in configuring Makefile.examples.
  pkg_config_link_flags(pkg_config_wxwidgets_LINK_FLAGS "${wxwidgets_LINK_FLAGS}")
endif(ENABLE_wxwidgets)

if(PLD_extqt)
  if(CORE_BUILD)
    set(BUILD_qt_example ON)
    if(NOT PLPLOT_USE_QT5 AND NOT QT_LIBRARIES)
      message(FATAL_ERROR "include(${QT_USE_FILE}) failed in core build examples/c++ subdirectory.")
    endif(NOT PLPLOT_USE_QT5 AND NOT QT_LIBRARIES)
  else(CORE_BUILD)
    # Find Qt components that we need to build qt_example
    if(PLPLOT_USE_QT5)
      # find_package(Qt5 ...) already done by find_package(plplot) for
      # the reasons given in src/plplotConfig.cmake.  So no need to repeat
      # here.
      # find_package(Qt5 5.3.1 COMPONENTS Svg Gui PrintSupport)
      # So only need to check those results here for this particular
      # use of Qt5.
      if(Qt5_FOUND AND Qt5_VERSION_MAJOR STREQUAL "${CORE_Qt5_VERSION_MAJOR}" AND Qt5_VERSION_MINOR STREQUAL "${CORE_Qt5_VERSION_MINOR}" AND Qt5_VERSION_PATCH STREQUAL "${CORE_Qt5_VERSION_PATCH}")
	set(BUILD_qt_example ON)
      else(Qt5_FOUND AND Qt5_VERSION_MAJOR STREQUAL "${CORE_Qt5_VERSION_MAJOR}" AND Qt5_VERSION_MINOR STREQUAL "${CORE_Qt5_VERSION_MINOR}" AND Qt5_VERSION_PATCH STREQUAL "${CORE_Qt5_VERSION_PATCH}")
	message(STATUS "CORE_Qt5_FOUND = ON")
	message(STATUS "CORE_Qt5_VERSION_MAJOR = ${CORE_Qt5_VERSION_MAJOR}")
	message(STATUS "CORE_Qt5_VERSION_MINOR = ${CORE_Qt5_VERSION_MINOR}")
	message(STATUS "CORE_Qt5_VERSION_PATCH = ${CORE_Qt5_VERSION_PATCH}")
	message(STATUS "Qt5_FOUND = ${Qt5_FOUND}")
	message(STATUS "Qt5_VERSION_MAJOR = ${Qt5_VERSION_MAJOR}")
	message(STATUS "Qt5_VERSION_MINOR = ${Qt5_VERSION_MINOR}")
	message(STATUS "Qt5_VERSION_PATCH = ${Qt5_VERSION_PATCH}")
	message(STATUS "WARNING: Qt5 core build-tree and install-tree inconsistency so qt_example will not be built")
	set(BUILD_qt_example OFF)
      endif(Qt5_FOUND AND Qt5_VERSION_MAJOR STREQUAL "${CORE_Qt5_VERSION_MAJOR}" AND Qt5_VERSION_MINOR STREQUAL "${CORE_Qt5_VERSION_MINOR}" AND Qt5_VERSION_PATCH STREQUAL "${CORE_Qt5_VERSION_PATCH}")
    else(PLPLOT_USE_QT5)
      # Find Qt4 all over again here rather than simply copying variables
      # from the core build to this installed examples build.
      find_package(Qt4 4.8.2 REQUIRED QtCore QtGui QtSvg)
      # To avoid Qt4 version mismatch make sure the Qt version matches that
      # used by the core build.
      if(Qt4_FOUND AND QT_VERSION_MAJOR STREQUAL "${CORE_QT_VERSION_MAJOR}" AND QT_VERSION_MINOR STREQUAL "${CORE_QT_VERSION_MINOR}" AND QT_VERSION_PATCH STREQUAL "${CORE_QT_VERSION_PATCH}")
	include(ndp_UseQt4)
	if(NOT QT_LIBRARIES)
          message(FATAL_ERROR "include(${QT_USE_FILE}) failed in installed examples build examples/c++ subdirectory.")
	endif(NOT QT_LIBRARIES)
	set(BUILD_qt_example ON)
      else(Qt4_FOUND AND QT_VERSION_MAJOR STREQUAL "${CORE_QT_VERSION_MAJOR}" AND QT_VERSION_MINOR STREQUAL "${CORE_QT_VERSION_MINOR}" AND QT_VERSION_PATCH STREQUAL "${CORE_QT_VERSION_PATCH}")
	message(STATUS "CORE_Qt4_FOUND = ON")
	message(STATUS "CORE_QT_VERSION_MAJOR = ${CORE_QT_VERSION_MAJOR}")
	message(STATUS "CORE_QT_VERSION_MINOR = ${CORE_QT_VERSION_MINOR}")
	message(STATUS "CORE_QT_VERSION_PATCH = ${CORE_QT_VERSION_PATCH}")
	message(STATUS "Qt4_FOUND = ${Qt4_FOUND}")
	message(STATUS "QT_VERSION_MAJOR = ${QT_VERSION_MAJOR}")
	message(STATUS "QT_VERSION_MINOR = ${QT_VERSION_MINOR}")
	message(STATUS "QT_VERSION_PATCH = ${QT_VERSION_PATCH}")
	message(STATUS "WARNING: Qt4 core build-tree and install-tree inconsistency so qt_example will not be built")
	set(BUILD_qt_example OFF)
      endif(Qt4_FOUND AND QT_VERSION_MAJOR STREQUAL "${CORE_QT_VERSION_MAJOR}" AND QT_VERSION_MINOR STREQUAL "${CORE_QT_VERSION_MINOR}" AND QT_VERSION_PATCH STREQUAL "${CORE_QT_VERSION_PATCH}")
    endif(PLPLOT_USE_QT5)
  endif(CORE_BUILD)
  # Transform QT_LIBRARIES from list of libraries to the standard pkg-config form
  # for use in configuring Makefile.examples.
  # FIXME.  This currently does not work for Qt5.
  pkg_config_link_flags(pkg_config_QT_LIBRARIES "${QT_LIBRARIES}")
  #message(STATUS "QT_LIBRARIES = ${QT_LIBRARIES}")
  #message(STATUS "pkg_config_QT_LIBRARIES = ${pkg_config_QT_LIBRARIES}")
endif(PLD_extqt)

if(BUILD_TEST AND BUILD_qt_example)
  if(BUILD_SHARED_LIBS)
    set_source_files_properties(qt_example.cpp qt_PlotWindow.cpp
      PROPERTIES COMPILE_FLAGS "-DUSINGDLL")
  endif(BUILD_SHARED_LIBS)
  # For both Qt4 and Qt5 AUTOMOC method works fine to process
  # qt_PlotWindow.h in the same directory with the same base name as
  # qt_PlotWindow.cpp, but must add qt.h to explicit sources for
  # AUTOMOC method to work for that header file since it is in a
  # separate directory.
  if(CORE_BUILD)
    add_executable(qt_example qt_example.cpp qt_PlotWindow.cpp ${CMAKE_SOURCE_DIR}/include/qt.h )
  else(CORE_BUILD)
    add_executable(qt_example qt_example.cpp qt_PlotWindow.cpp ${INCLUDE_DIR}/qt.h )
  endif(CORE_BUILD)
    
  if(PLPLOT_USE_QT5)
    if(ENABLE_DYNDRIVERS)
      target_link_libraries(qt_example plplotqt plplot Qt5::Svg Qt5::Gui Qt5::PrintSupport)
    else(ENABLE_DYNDRIVERS)
      # In this case plplot contains all the code in plplotqt so there is no
      # need to link to plplotqt at all, and in fact for some reason it
      # causes memory management issues to link to both plplot and plplotqt in this case.
      target_link_libraries(qt_example plplot Qt5::Svg Qt5::Gui Qt5::PrintSupport)
    endif(ENABLE_DYNDRIVERS)
  else(PLPLOT_USE_QT5)
      if(ENABLE_DYNDRIVERS)
      target_link_libraries(qt_example ${QT_LIBRARIES} plplotqt plplot)
    else(ENABLE_DYNDRIVERS)
      # In this case plplot contains all the code in plplotqt so there is no
      # need to link to plplotqt at all, and in fact for some reason it
      # causes memory management issues to link to both plplot and plplotqt in this case.
      target_link_libraries(qt_example ${QT_LIBRARIES} plplot)
    endif(ENABLE_DYNDRIVERS)
    # Update the target COMPILE_DEFINITIONS and INCLUDE_DIRECTORIES
    set_qt_target_properties(qt_example)
  endif(PLPLOT_USE_QT5)
  set_target_properties(qt_example PROPERTIES
    AUTOMOC ON
    AUTOMOC_MOC_OPTIONS "${PLPLOT_AUTOMOC_MOC_OPTIONS}"
    )
endif(BUILD_TEST AND BUILD_qt_example)

if(CORE_BUILD)
  # This configuration must occur after the pkg_config variables are
  # determined above.
  configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/Makefile.examples.in
    ${CMAKE_CURRENT_BINARY_DIR}/Makefile.examples
    )

  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/Makefile.examples
    DESTINATION ${DATA_DIR}/examples/c++
    RENAME Makefile
    )

endif(CORE_BUILD)
