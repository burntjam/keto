#.rst:
# FindAsn1
# ------------
#
# Locate and configure the ASN1 library.
#
# The following variables can be set and are optional:
#
# ``ASN1_SRC_ROOT_FOLDER``
#   When compiling with MSVC, if this cache variable is set
#   the asn1-default VS project build locations
#   (vsprojects/Debug and vsprojects/Release
#   or vsprojects/x64/Debug and vsprojects/x64/Release)
#   will be searched for libraries and binaries.
# ``ASN1_IMPORT_DIRS``
#   List of additional directories to be searched for
#   imported .proto files.
#
# Defines the following variables:
#
# ``ASN1_FOUND``
#   Found the Google Protocol Buffers library
#   (libasn1 & header files)
#
# The following cache variables are also available to set or use:
#
# ``ASN1_EXECUTABLE``
#   The asn1 compiler
#
# Example:
#
# .. code-block:: cmake
#
#   find_package(Asn1 REQUIRED)
#   ans1_generate_cpp(ASN1_SRCS ASN1_HDRS foo.asn1)
#   add_executable(bar bar.cc ${ASN1_SRCS} ${ASN1_HDRS})
#   target_link_libraries(bar ${PROTOBUF_LIBRARIES})
#
# .. note::
#   The ``asn1_generate_cpp``
#   functions and :command:`add_executable` or :command:`add_library`
#   calls only work properly within the same directory.
#
# .. command:: asn1_generate_cpp
#
#   Add custom commands to process ``.asm1`` files to C++::
#
#     asn1_generate_cpp (<SRCS> <HDRS> [<ARGN>...])
#
#   ``SRCS``
#     Variable to define with autogenerated source files
#   ``HDRS``
#     Variable to define with autogenerated header files
#   ``ARGN``
#     ``.proto`` files
#

#=============================================================================
# Copyright 2009 Kitware, Inc.
# Copyright 2009-2011 Philip Lowman <philip@yhbt.com>
# Copyright 2008 Esben Mose Hansen, Ange Optimization ApS
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

function(ASN1_GENERATE_CPP SRCS HDRS)
    
  if(NOT ARGN)
    message(SEND_ERROR "Error: ASN1_GENERATE_CPP() called without any asn1 files")
    return()
  endif()
    message(STATUS "Generate CPP files" )
  if(ASN1_GENERATE_CPP_APPEND_PATH)
    # Create an include path for each file specified
    foreach(FIL ${ARGN})
      get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
      get_filename_component(ABS_PATH ${ABS_FIL} PATH)
      list(FIND _asn1_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _asn1_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  else()
    set(_asn1_include_path -I ${CMAKE_CURRENT_SOURCE_DIR})
  endif()

  if(DEFINED ASN1_IMPORT_DIRS)
    foreach(DIR ${ASN1_IMPORT_DIRS})
      get_filename_component(ABS_PATH ${DIR} ABSOLUTE)
      list(FIND _asn1_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _asn1_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  endif()

  set(${SRCS})
  set(${HDRS})
  set(ABSFILES "")
  list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/asn_bit_data.c")
  list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/asn_bit_data.h")
     
  foreach(FIL ${ARGN})
    get_filename_component(ABS_FILE ${FIL} ABSOLUTE)
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    list(APPEND ABSFILES "${ABS_FILE}")
  endforeach()
  
  message(STATUS "The list of files is " ${ABSFILES})
  # execute the asn1 process as we need to update the dependencies after this
  # is complete.
  execute_process(
      COMMAND  ${ASN1_EXECUTABLE} -fcompound-names -no-gen-example -D ${CMAKE_CURRENT_BINARY_DIR} ${ABSFILES})

  file (GLOB ASN_SOURCE_FILES "${CMAKE_CURRENT_BINARY_DIR}/*.c")
  message(STATUS "Generated the source files")
  foreach(FIL ${ASN_SOURCE_FILES})
    message(STATUS "Add source file " ${FIL})
    list(APPEND ${SRCS} "${FIL}")
  endforeach()
  file (GLOB ASN_HEADER_FILES "${CMAKE_CURRENT_BINARY_DIR}/*.h")
  foreach(FIL ${ASN_HEADER_FILES})
    message(STATUS "Add header file " ${FIL})
    list(APPEND ${HDRS} "${FIL}")
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)

endfunction()

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(_ASN1_ARCH_DIR x64/)
endif()

#
# Main.
#

# By default have PROTOBUF_GENERATE_CPP macro pass -I to protoc
# for each directory where a proto file is referenced.
if(NOT DEFINED ASN1_GENERATE_CPP_APPEND_PATH)
  set(ASN1_GENERATE_CPP_APPEND_PATH TRUE)
endif()


if (NOT DEFINED ASN1_ROOT_FOLDER)
  set(ASN1_ROOT_FOLDER $ENV{ASN1_ROOT_FOLDER})
endif()

# Find the protoc Executable
find_program(ASN1_EXECUTABLE
    NAMES asn1c
    DOC "Ans1 Compiler"
    PATHS
    ${ASN1_ROOT_FOLDER}/bin/
)
mark_as_advanced(ASN1_EXECUTABLE)

message(STATUS "ASN1_EXECUTABLE " ${ASN1_EXECUTABLE})


#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Asn1 DEFAULT_MSG
    ASN1_EXECUTABLE)

if(PROTOBUF_FOUND)
    set(ASN1_EXECUTABLE ${ASN1_EXECUTABLE})
endif()