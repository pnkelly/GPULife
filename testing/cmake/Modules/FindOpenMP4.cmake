# Updated FindOpenMP file such that the failure of finding OpenMP is cached.

# - Finds OpenMP support
# This module can be used to detect OpenMP support in a compiler.
# If the compiler supports OpenMP, the flags required to compile with
# openmp support are set.  
#
# The following variables are set:
#   OpenMP_C_FLAGS - flags to add to the C compiler for OpenMP support
#   OpenMP_CXX_FLAGS - flags to add to the CXX compiler for OpenMP support
#   OPENMP_FOUND - true if openmp is detected
#
# Supported compilers can be found at http://openmp.org/wp/openmp-compilers/

#=============================================================================
# Copyright 2009 Kitware, Inc.
# Copyright 2008-2009 AndrÃ© Rigland Brodtkorb <Andre.Brodtkorb@ifi.uio.no>
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

if (NOT CMAKE_CURRENT_LIST_DIR)  # CMAKE_CURRENT_LIST_DIR only from cmake 2.8.3.
  get_filename_component(CMAKE_CURRENT_LIST_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
endif (NOT CMAKE_CURRENT_LIST_DIR)

# Do not try to find OpenMP if we know that it cannot be found.
if (_OPENMP_NOT_FOUND)
    return ()
endif ()

if(POLICY CMP0057)
  cmake_policy(SET CMP0057 NEW)
endif()

get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)

include(CheckCSourceCompiles)
if("CXX" IN_LIST languages)
  include(CheckCXXSourceCompiles)
endif("CXX" IN_LIST languages)

include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)

set(OpenMP_C_FLAG_CANDIDATES
  #Gnu
  "-fopenmp"
  #Intel
  "-openmp" 
  #Portland Group
  "-mp"
  #Microsoft Visual Studio
  "/openmp"
  #Intel windows
  "-Qopenmp" 
  #Empty, if compiler automatically accepts openmp
  " "
  #Sun
  "-xopenmp"
  #HP
  "+Oopenmp"
  #IBM XL C/c++
  "-qsmp"
)
if("CXX" IN_LIST languages)
  set(OpenMP_CXX_FLAG_CANDIDATES ${OpenMP_C_FLAG_CANDIDATES})
endif("CXX" IN_LIST languages)

# sample openmp source code to test
set(OpenMP_C_TEST_SOURCE 
"
#include <omp.h>
int main() { 
#ifdef _OPENMP
  return 0; 
#else
  breaks_on_purpose
#endif
}
")

if("CXX" IN_LIST languages)
# use the same source for CXX as C for now
  set(OpenMP_CXX_TEST_SOURCE ${OpenMP_C_TEST_SOURCE})
  # if these are set then do not try to find them again,
  # by avoiding any try_compiles for the flags
  if(DEFINED OpenMP_C_FLAGS AND DEFINED OpenMP_CXX_FLAGS)
    set(OpenMP_C_FLAG_CANDIDATES)
    set(OpenMP_CXX_FLAG_CANDIDATES)
  endif(DEFINED OpenMP_C_FLAGS AND DEFINED OpenMP_CXX_FLAGS)
else("CXX" IN_LIST languages)
  # if these are set then do not try to find them again,
  # by avoiding any try_compiles for the flags
  if(DEFINED OpenMP_C_FLAGS)
    set(OpenMP_C_FLAG_CANDIDATES)
  endif(DEFINED OpenMP_C_FLAGS)
endif("CXX" IN_LIST languages)

# check c compiler
foreach(FLAG ${OpenMP_C_FLAG_CANDIDATES})
  set(SAFE_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
  set(CMAKE_REQUIRED_FLAGS "${FLAG}")
  unset(OpenMP_FLAG_DETECTED CACHE)
  message(STATUS "Try OpenMP C flag = [${FLAG}]")
  check_c_source_compiles("${OpenMP_C_TEST_SOURCE}" OpenMP_FLAG_DETECTED)
  set(CMAKE_REQUIRED_FLAGS "${SAFE_CMAKE_REQUIRED_FLAGS}")
  if(OpenMP_FLAG_DETECTED)
    set(OpenMP_C_FLAGS_INTERNAL "${FLAG}")
    break()
  endif(OpenMP_FLAG_DETECTED) 
endforeach(FLAG ${OpenMP_C_FLAG_CANDIDATES})

if("CXX" IN_LIST languages)
  # check cxx compiler
  foreach(FLAG ${OpenMP_CXX_FLAG_CANDIDATES})
    set(SAFE_CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}")
    set(CMAKE_REQUIRED_FLAGS "${FLAG}")
    unset(OpenMP_FLAG_DETECTED CACHE)
    message(STATUS "Try OpenMP CXX flag = [${FLAG}]")
    check_cxx_source_compiles("${OpenMP_CXX_TEST_SOURCE}" OpenMP_FLAG_DETECTED)
    set(CMAKE_REQUIRED_FLAGS "${SAFE_CMAKE_REQUIRED_FLAGS}")
    if(OpenMP_FLAG_DETECTED)
      set(OpenMP_CXX_FLAGS_INTERNAL "${FLAG}")
      break()
    endif(OpenMP_FLAG_DETECTED)
  endforeach(FLAG ${OpenMP_CXX_FLAG_CANDIDATES})
endif("CXX" IN_LIST languages)

set(OpenMP_C_FLAGS "${OpenMP_C_FLAGS_INTERNAL}"
  CACHE STRING "C compiler flags for OpenMP parallization")

if("CXX" IN_LIST languages)
  set(OpenMP_CXX_FLAGS "${OpenMP_CXX_FLAGS_INTERNAL}"
    CACHE STRING "C++ compiler flags for OpenMP parallization")

  # handle the standard arguments for find_package
  find_package_handle_standard_args(OpenMP DEFAULT_MSG 
    OpenMP_C_FLAGS OpenMP_CXX_FLAGS )

  mark_as_advanced(
    OpenMP_C_FLAGS
    OpenMP_CXX_FLAGS
  )
else ("CXX" IN_LIST languages)
  # handle the standard arguments for find_package
  find_package_handle_standard_args(OpenMP DEFAULT_MSG 
    OpenMP_C_FLAGS )

  mark_as_advanced(
    OpenMP_C_FLAGS
  )
endif ("CXX" IN_LIST languages)

if (NOT OPENMP_FOUND)
    set (OPENMP_NOT_FOUND TRUE CACHE INTERNAL
        "Set such that OpenMP is not searched for more than once.")
endif ()
