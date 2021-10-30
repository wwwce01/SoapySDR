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

# We need these for the assembly sources
set(CSHARP_SOURCE_DIRECTORY ${CSHARP_SOURCE_DIRECTORY} PARENT_SCOPE)
set(SWIG_TARGET_NAME ${SWIG_MODULE_SoapySDRCSharp_REAL_NAME} PARENT_SCOPE)