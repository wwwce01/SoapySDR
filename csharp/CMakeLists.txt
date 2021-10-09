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

if (NOT SIZE_T_IS_UNSIGNED_INT)
    list(APPEND CMAKE_SWIG_FLAGS -DSWIG64)
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
include(UseSWIG)
include(SWIGCSharp) # Convenient SWIG CMake stuff
SWIG_CSHARP_INIT()

set(SWIG_MODULE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(SWIG_CSHARP_INCLUDE_DIRS ${SoapySDR_INCLUDE_DIRS})
set(SWIG_CSHARP_LIBRARIES SoapySDR)

SWIG_BUILD_CSHARP_MODULE(SoapySDR SoapySDRCSharp SoapySDR TRUE SoapySDR)

########################################################################
# Build C# assembly
########################################################################

set(csharp_swig_outputs
    ${CSHARP_SOURCE_DIRECTORY}/ArgInfoInternal.cs
    ${CSHARP_SOURCE_DIRECTORY}/ArgInfoInternalList.cs
    ${CSHARP_SOURCE_DIRECTORY}/BuildInfo.cs
    ${CSHARP_SOURCE_DIRECTORY}/DeviceInternal.cs
    ${CSHARP_SOURCE_DIRECTORY}/DeviceInternalList.cs
    ${CSHARP_SOURCE_DIRECTORY}/Direction.cs
    ${CSHARP_SOURCE_DIRECTORY}/DoubleList.cs
    ${CSHARP_SOURCE_DIRECTORY}/ErrorCode.cs
    ${CSHARP_SOURCE_DIRECTORY}/Kwargs.cs
    ${CSHARP_SOURCE_DIRECTORY}/KwargsList.cs
    ${CSHARP_SOURCE_DIRECTORY}/LogHandlerBase.cs
    ${CSHARP_SOURCE_DIRECTORY}/LogLevel.cs
    ${CSHARP_SOURCE_DIRECTORY}/Range.cs
    ${CSHARP_SOURCE_DIRECTORY}/RangeList.cs
    ${CSHARP_SOURCE_DIRECTORY}/SoapySDR.cs
    ${CSHARP_SOURCE_DIRECTORY}/SettingConversion.cs
    ${CSHARP_SOURCE_DIRECTORY}/SoapySDRPINVOKE.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamFlags.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamFormats.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamHandle.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamResult.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamResultPair.cs
    ${CSHARP_SOURCE_DIRECTORY}/StringList.cs
    ${CSHARP_SOURCE_DIRECTORY}/Time.cs
    ${CSHARP_SOURCE_DIRECTORY}/UIntList.cs
    ${CSHARP_SOURCE_DIRECTORY}/ULongList.cs
    ${CSHARP_SOURCE_DIRECTORY}/ULongLongList.cs)

set_source_files_properties(
    FILES ${csharp_swig_outputs}
    PROPERTIES GENERATED TRUE)

set(csharp_srcs
    ${CMAKE_CURRENT_SOURCE_DIR}/ArgInfo.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/ArgValue.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Device.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Logger.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Stream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/TxStream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Utility.cs
    
    ${csharp_swig_outputs})

add_library(SoapySDR.CSharp SHARED ${csharp_srcs})
set_property(TARGET SoapySDR.CSharp PROPERTY COMPILE_FLAGS /unsafe)
set_property(TARGET SoapySDR.CSharp PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION "v4.7.2")
set_property(
    TARGET SoapySDR.CSharp
    PROPERTY VS_DOTNET_REFERENCES
    "System"
    "System.Core"
    "System.Numerics")

add_dependencies(SoapySDR.CSharp ${SWIG_MODULE_SoapySDRCSharp_REAL_NAME})