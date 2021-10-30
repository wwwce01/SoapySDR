########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.8.2)
project(SoapySDRCSharp CXX CSharp)
enable_testing()

find_package(SoapySDR CONFIG REQUIRED)

########################################################################
# Find SWIG
########################################################################
find_package(SWIG)
message(STATUS "SWIG_FOUND: ${SWIG_FOUND} - ${SWIG_VERSION}")

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
## Export variables for python3 subdirectory
########################################################################

#this directory used as a stand-alone build since the library is pulled in externally
#set ENABLE_LIBRARY for cmake_dependent_option() used in the feature setup below
if("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
    set(ENABLE_LIBRARY ${SoapySDR_FOUND})
endif()

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
add_subdirectory(swig)
add_subdirectory(assembly)

########################################################################
# Tests
########################################################################
add_subdirectory(tests)