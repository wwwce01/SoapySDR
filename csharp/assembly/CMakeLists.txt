########################################################################
# Build C# assembly
########################################################################

set(csharp_swig_outputs
    ${CSHARP_SOURCE_DIRECTORY}/ArgInfoInternal.cs
    ${CSHARP_SOURCE_DIRECTORY}/ArgInfoInternalList.cs
    ${CSHARP_SOURCE_DIRECTORY}/BuildInfo.cs
    ${CSHARP_SOURCE_DIRECTORY}/ConverterFunctionPriority.cs
    ${CSHARP_SOURCE_DIRECTORY}/DeviceInternal.cs
    ${CSHARP_SOURCE_DIRECTORY}/DeviceInternalList.cs
    ${CSHARP_SOURCE_DIRECTORY}/Direction.cs
    ${CSHARP_SOURCE_DIRECTORY}/DoubleList.cs
    ${CSHARP_SOURCE_DIRECTORY}/ErrorCode.cs
    ${CSHARP_SOURCE_DIRECTORY}/Kwargs.cs
    ${CSHARP_SOURCE_DIRECTORY}/KwargsList.cs
    ${CSHARP_SOURCE_DIRECTORY}/LogHandlerBase.cs
    ${CSHARP_SOURCE_DIRECTORY}/LogLevel.cs
    ${CSHARP_SOURCE_DIRECTORY}/RangeInternal.cs
    ${CSHARP_SOURCE_DIRECTORY}/RangeInternalList.cs
    ${CSHARP_SOURCE_DIRECTORY}/SizeList.cs
    ${CSHARP_SOURCE_DIRECTORY}/SoapySDR.cs
    ${CSHARP_SOURCE_DIRECTORY}/SoapySDRPINVOKE.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamFlags.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamFormat.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamHandle.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamResult.cs
    ${CSHARP_SOURCE_DIRECTORY}/StreamResultPair.cs
    ${CSHARP_SOURCE_DIRECTORY}/StringList.cs
    ${CSHARP_SOURCE_DIRECTORY}/Time.cs
    ${CSHARP_SOURCE_DIRECTORY}/TypeConversion.cs)

set_source_files_properties(
    FILES ${csharp_swig_outputs}
    PROPERTIES GENERATED TRUE)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/AssemblyInfo.cs
    ${CSHARP_SOURCE_DIRECTORY}/AssemblyInfo.cs)

set(csharp_srcs
    ${CMAKE_CURRENT_SOURCE_DIR}/ArgInfo.cs
    ${CSHARP_SOURCE_DIRECTORY}/AssemblyInfo.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Device.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Logger.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Range.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/RxStream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/SoapyConvertible.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Stream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/TxStream.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/Utility.cs
    
    ${csharp_swig_outputs})

add_library(SoapySDR.CSharp SHARED ${csharp_srcs})
set_property(TARGET SoapySDR.CSharp PROPERTY COMPILE_FLAGS /unsafe)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_property(TARGET SoapySDR.CSharp PROPERTY COMPILE_DEFINITIONS _64BIT)
endif()

set_property(TARGET SoapySDR.CSharp PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION "v4.7.2")
set_property(
    TARGET SoapySDR.CSharp
    PROPERTY VS_DOTNET_REFERENCES
    "System"
    "System.Core"
    "System.Numerics")

add_dependencies(SoapySDR.CSharp ${SWIG_TARGET_NAME})