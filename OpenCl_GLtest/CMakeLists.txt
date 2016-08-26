cmake_minimum_required (VERSION 2.8.11)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
# --- custom targets: ---
INCLUDE( cmake/Modules/TargetDistclean.cmake OPTIONAL)

project (OpenCl_GLtest)

# The version number.
set (OpenCL_GLtest_VERSION_MAJOR 2)
set (OpenCL_GLtest_VERSION_MINOR 0.7)
set (OpenCL_GLtest_VERSION "${OpenCL_GLtest_VERSION_MAJOR}.${OpenCL_GLtest_VERSION_MINOR}")

if (NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE RelWithDebInfo)
endif(NOT CMAKE_BUILD_TYPE)

# uncomment to build debug
#set(CMAKE_BUILD_TYPE Debug)

if ("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
   # using Clang
   set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -g -O0 -Wextra")
   set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g -O3")
elseif ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
   # using GCC
   set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -g -O0 -Wextra")
   set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g -O3")
elseif ("${CMAKE_C_COMPILER_ID}" STREQUAL "Intel")
   # using Intel C++
   set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -g -O0 -Wextra")
   set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g -O3")
   # using pgi
elseif ("${CMAKE_C_COMPILER_ID}" STREQUAL "pgCC")
   set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Wall -g -O0 -Wextra")
   set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -g -O3")
endif()

#find_package(MPI)

#find_package( OpenACC)

#find_package( OpenMP)

## This checks to see if the compiler supports the OpenMP4 standard and
## sets an OpenMP4_FOUND flag
#if (NOT OpenMP OR NOT EXISTS "${OpenMP_C_SPEC_DATE}" OR "${OpenMP_C_SPEC_DATE}" LESS 201307)
#  set (OpenMP4_FOUND false)
#  message(STATUS "OpenMP4 not found: " ${OpenMP_C_SPEC_DATE})
#else ()
#  set (OpenMP4_FOUND true)
#  message(STATUS "Found OpenMP4: " ${OpenMP_C_SPEC_DATE})
#endif ()


# Cuda does not work on OSX with GCC compiler
#if ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU" AND APPLE)
#  message(STATUS "CUDA disabled: cannot use GCC compiler on Mac OSx -- try using Clang instead")
#else ()
#  find_package( CUDA)
#  if (CUDA_VERSION_STRING VERSION_EQUAL "7.5")
#    if (("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU") AND
#        (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.9.0") ) # or with GCC greater than 4.9 with CUDA 7.5`
#      message(STATUS "CUDA disabled: cannot use GCC compiler greater than 4.9 with CUDA 7.5")
#      set(CUDA_FOUND false)
#    endif()
#    if (("${CMAKE_C_COMPILER_ID}" STREQUAL "Intel") AND
#        (CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "15.1.0") ) # or with Intel greater than 15.1.0 with CUDA 7.5`
#      message(STATUS "CUDA disabled: cannot use Intel compiler greater than 15.1.0 with CUDA 7.5")
#      set(CUDA_FOUND false)
#    endif()
#  endif (CUDA_VERSION_STRING VERSION_EQUAL "7.5")
#endif ()

find_package(OpenCL)
#  OPENCL_FOUND        : TRUE if found, FALSE otherwise
#  OPENCL_INCLUDE_DIRS : Include directories for OpenCL
#  OPENCL_LIBRARIES    : The libraries to link against
if (OPENCL_FOUND)
   include_directories(${OPENCL_INCLUDE_DIRS})
endif (OPENCL_FOUND)

find_package(OpenGL REQUIRED)
include_directories(${OPENGL_INCLUDE_DIR})

find_package(GLUT REQUIRED)
include_directories(${GLUT_INCLUDE_DIR})

#set( CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}; -O3 -gencode arch=compute_22,code=sm_22)
#set( CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}; -O3 -gencode code=sm_22)

set(OpenCL_GLtest_SOURCES main.c applyRules_OpenCL.c) 
if (CUDA_FOUND)
  set(OpenCL_GLtest_SOURCES ${OpenCL_GLtest_SOURCES} applyRules_CUDA.cu)
  cuda_add_executable (OpenCL_GLtest ${OpenCL_GLtest_SOURCES}) 
else (CUDA_FOUND)
   add_executable (OpenCL_GLtest ${OpenCL_GLtest_SOURCES}) 
endif (CUDA_FOUND)


#set_source_files_properties(applyRules_OpenMP4.c PROPERTIES COMPILE_FLAGS ${OpenMP_C_FLAGS})

#if (MPI_FOUND)
#   include_directories(${MPI_INCLUDE_PATH})
#   set(OpenCL_GLtest_DEFINITIONS "${OpenCL_GLtest_DEFINITIONS};HAVE_MPI")
#   target_link_libraries(OpenCL_GLtest ${MPI_LIBRARIES})
#endif (MPI_FOUND)

#if (OpenACC_FOUND)
#   set(OpenCL_GLtest_DEFINITIONS "${OpenCL_GLtest_DEFINITIONS};HAVE_ACC;_OPENACC")
#   set_source_files_properties(OpenCL_GLtest PROPERTIES COMPILE_FLAGS ${OpenACC_C_FLAGS})
#   target_link_libraries(OpenCL_GLtest ${OpenACC_LIBRARIES})
#endif (OpenACC_FOUND)

#if (OpenMP4_FOUND)
#   set(OpenCL_GLtest_DEFINITIONS "${OpenCL_GLtest_DEFINITIONS};HAVE_OPENMP4")
#   target_link_libraries(OpenCL_GLtest ${OpenMP_LIBRARIES})
#endif (OpenMP4_FOUND)

#if (CUDA_FOUND)
#   set(OpenCL_GLtest_DEFINITIONS "${OpenCL_GLtest_DEFINITIONS};HAVE_CUDA")
#   target_link_libraries(OpenCL_GLtest ${CUDA_LIBRARIES})
#endif (CUDA_FOUND)

if (OpenCL_FOUND)
   set_target_properties(OpenCL_GLtest PROPERTIES COMPILE_DEFINITIONS HAVE_OPENCL)
   #set_source_files_properties(applyRules_OpenCL.c PROPERTIES COMPILE_FLAGS "${OpenCL_C_FLAGS}")
   target_link_libraries(OpenCL_GLtest ${OpenCL_LIBRARIES})
endif (OpenCL_FOUND)

#if (OpenGL_FOUND)
#   set_target_properties(OpenCL_GLtest PROPERTIES COMPILE_DEFINITIONS HAVE_OPENGL)
#   set_target_properties(OpenCL_GLtest PROPERTIES COMPILE_FLAGS "${OpenGL_INCLUDE_DIR}")
#   target_link_libraries(OpenCL_GLtest ${OpenGL_LIBRARIES})
#endif (OpenGL_FOUND)

set_target_properties(OpenCL_GLtest PROPERTIES COMPILE_DEFINITIONS "${OpenCL_GLtest_DEFINITIONS}")


# we need to add a version check
#if(GCC_VERSION VERSION_LESS "4.9")
	#then cuda is allowed and openmp4 is not
#else
	# then openmp4 is allowed and cuda is not

