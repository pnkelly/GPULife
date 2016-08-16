cmake_minimum_required (VERSION 2.8.11)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")
# --- custom targets: ---
INCLUDE( cmake/Modules/TargetDistclean.cmake OPTIONAL)

project (gameOfLife C)

find_package(MPI)
if (MPI_FOUND)
   include_directories(${MPI_INCLUDE_PATH})
endif (MPI_FOUND)

# The version number.
set (gameOfLife_VERSION_MAJOR 2)
set (gameOfLife_VERSION_MINOR 0.7)
set (gameOfLife_VERSION "${gameOfLife_VERSION_MAJOR}.${gameOfLife_VERSION_MINOR}")

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

add_executable (gameOfLife main.c applyRules_OpenMP4.c applyRules_OpenACC.c) 
set_target_properties(gameOfLife PROPERTIES COMPILE_DEFINITIONS)

if (MPI_FOUND)
set_target_properties(gameOfLife HAVE_MPI)
target_link_libraries(gameOfLife ${MPI_LIBRARIES})
endif (MPI_FOUND)


if (OpenACC_FOUND)
		target_link_libraries(gameOfLife ${OpenMP_LIBRARIES})
endif (OpenACC_FOUND)

if (OpenMP_FOUND)
		target_link_libraries(gameOfLife ${OpenMP_LIBRARIES})
endif (OpenMP_FOUND)

# we need to add a version check
if(GCC_VERSION VERSION_LESS "4.9")
	#then cuda is allowed and openmp4 is not
#else
	# then openmp4 is allowed and cuda is not

