########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 2.8)
project(SoapySDRCSharp CXX)
enable_testing()

find_package(SoapySDR CONFIG REQUIRED)

########################################################################
# Find SWIG
########################################################################
find_package(SWIG)
message(STATUS "SWIG_FOUND: ${SWIG_FOUND} - ${SWIG_VERSION}")

########################################################################
## set the SWIG flags
########################################################################
set(CMAKE_SWIG_FLAGS -c++ -I${SoapySDR_INCLUDE_DIRS} -namespace SoapySDR)

# SWIG doesn't deal well with (s)size_t and (u)intptr_t
include(CheckCXXSourceCompiles)
CHECK_CXX_SOURCE_COMPILES("
    #include <cstddef>
    int main() {
    size_t *x = (unsigned int *)(NULL);
    return 0; }" SIZE_T_IS_UNSIGNED_INT)

if (SIZE_T_IS_UNSIGNED_INT)
    list(APPEND CMAKE_SWIG_FLAGS -DSIZE_T_IS_UNSIGNED_INT)
endif (SIZE_T_IS_UNSIGNED_INT)

########################################################################
## Check for SoapySDR if this is used as a standalone build
########################################################################

#this directory used as a stand-alone build since the library is pulled in externally
#set ENABLE_LIBRARY for cmake_dependent_option() used in the feature setup below
if("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    set(ENABLE_LIBRARY ${SoapySDR_FOUND})
endif ()

########################################################################
## Feature registration
########################################################################
include(FeatureSummary)
include(CMakeDependentOption)
cmake_dependent_option(ENABLE_CSHARP "Enable C# bindings" ON "ENABLE_LIBRARY;SWIG_FOUND" OFF)
add_feature_info(CSharp ENABLE_CSHARP "C# bindings")
if (NOT ENABLE_CSHARP)
    return()
endif()

########################################################################
# Build Module
########################################################################
include(UseSWIG)

message(STATUS "CMAKE_SWIG_FLAGS=${CMAKE_SWIG_FLAGS}")
set_source_files_properties(SoapySDR.i PROPERTIES CPLUSPLUS ON)

# TODO: remove CSharp in DLL name output
if(${CMAKE_VERSION} VERSION_LESS "3.8")
    SWIG_ADD_MODULE(SoapySDRCSharp csharp SoapySDR.i)
else()
    SWIG_ADD_LIBRARY(SoapySDRCSharp LANGUAGE csharp SOURCES SoapySDR.i)
endif()

target_include_directories(${SWIG_MODULE_SoapySDRCSharp_REAL_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
