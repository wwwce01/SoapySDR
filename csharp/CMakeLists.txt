########################################################################
# Feature setup
########################################################################
find_package(SoapySDR CONFIG REQUIRED)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

########################################################################
# Make sure CMake supports native C#
########################################################################
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.8.0")
    set(CMAKE_SUPPORTS_NATIVE_CSHARP TRUE)
endif()

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
## Feature registration
########################################################################
include(FeatureSummary)
include(CMakeDependentOption)
cmake_dependent_option(ENABLE_CSHARP "Enable C# bindings" ON "MSVC;CMAKE_SUPPORTS_NATIVE_CSHARP;ENABLE_LIBRARY;SWIG_FOUND" OFF)
add_feature_info(CSharp ENABLE_CSHARP "C# bindings")
if (NOT ENABLE_CSHARP)
    return()
endif()

enable_language(CSharp)

########################################################################
# Build Module
########################################################################
add_subdirectory(swig)
add_subdirectory(assembly)

########################################################################
# Tests
########################################################################
add_subdirectory(tests)