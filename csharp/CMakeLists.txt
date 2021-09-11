########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 2.8)
project(SoapySDRCSharp CXX)
enable_testing()

find_package(SoapySDR CONFIG REQUIRED)

########################################################################
# Find C# compiler
########################################################################
find_package(CSharp)

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
cmake_dependent_option(ENABLE_CSHARP "Enable C# bindings" ON "ENABLE_LIBRARY;CSHARP_FOUND;SWIG_FOUND" OFF)
add_feature_info(CSharp ENABLE_CSHARP "C# bindings (${CSHARP_TYPE} ${CSHARP_VERSION})")
if (NOT ENABLE_CSHARP)
    return()
endif()

########################################################################
# Build Module
########################################################################
include(UseSWIG)
include(SWIGCSharp) # Convenient SWIG CMake stuff
SWIG_CSHARP_INIT()

set(SWIG_MODULE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(SWIG_CSHARP_INCLUDE_DIRS ${SoapySDR_INCLUDE_DIRS})
set(SWIG_CSHARP_LIBRARIES SoapySDR)

message(STATUS "SWIG_MODULE_DIR=${SWIG_MODULE_DIR}")
message(STATUS "SWIG_CSHARP_INCLUDE_DIRS=${SWIG_CSHARP_INCLUDE_DIRS}")
message(STATUS "SWIG_CSHARP_LIBRARIES=${SWIG_CSHARP_LIBRARIES}")

SWIG_BUILD_CSHARP_MODULE(SoapySDR SoapySDRCSharp SoapySDR TRUE SoapySDR)

########################################################################
# Build C# assembly
########################################################################

set(csharp_srcs
    ${CMAKE_CURRENT_SOURCE_DIR}/Logger.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Stream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/TxStream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Utility.cs
    ${CMAKE_CURRENT_BINARY_DIR}/ArgInfo.cs
    ${CMAKE_CURRENT_BINARY_DIR}/ArgInfoList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/BuildInfo.cs
    ${CMAKE_CURRENT_BINARY_DIR}/Device.cs
    ${CMAKE_CURRENT_BINARY_DIR}/DeviceList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/Direction.cs
    ${CMAKE_CURRENT_BINARY_DIR}/DoubleList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/ErrorCode.cs
    ${CMAKE_CURRENT_BINARY_DIR}/Kwargs.cs
    ${CMAKE_CURRENT_BINARY_DIR}/KwargsList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/LogHandlerBase.cs
    ${CMAKE_CURRENT_BINARY_DIR}/LogLevel.cs
    ${CMAKE_CURRENT_BINARY_DIR}/Range.cs
    ${CMAKE_CURRENT_BINARY_DIR}/RangeList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/SizeList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/SoapySDR.cs
    ${CMAKE_CURRENT_BINARY_DIR}/SoapySDRPINVOKE.cs
    ${CMAKE_CURRENT_BINARY_DIR}/StreamFlags.cs
    ${CMAKE_CURRENT_BINARY_DIR}/StreamFormats.cs
    ${CMAKE_CURRENT_BINARY_DIR}/StreamHandle.cs
    ${CMAKE_CURRENT_BINARY_DIR}/StreamResult.cs
    ${CMAKE_CURRENT_BINARY_DIR}/StreamResultPair.cs
    ${CMAKE_CURRENT_BINARY_DIR}/StringList.cs
    ${CMAKE_CURRENT_BINARY_DIR}/Time.cs
    ${CMAKE_CURRENT_BINARY_DIR}/UnsignedList.cs)

CSHARP_BUILD_DLL(SoapySDR.CSharp "SoapySDRCSharp" "${csharp_srcs}")
add_dependencies(SoapySDR.CSharp ${csharp_srcs})
