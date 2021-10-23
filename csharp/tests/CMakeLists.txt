function(BUILD_CSHARP_TEST name)
    # NUnit tests are DLLs processed by executable
    set(library_name CSharp_${name})
    add_library(${library_name} SHARED ${name}.cs)
    target_link_libraries(${library_name} SoapySDR.CSharp)
    
    set_property(TARGET ${library_name} PROPERTY COMPILE_FLAGS /unsafe)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set_property(TARGET ${library_name} PROPERTY COMPILE_DEFINITIONS _64BIT)
    endif()

    set_property(TARGET ${library_name} PROPERTY DOTNET_TARGET_FRAMEWORK_VERSION "v4.7.2")
    set_property(
        TARGET ${library_name}
        PROPERTY VS_DOTNET_REFERENCES
        "System"
        "System.Core"
        "System.Numerics"
        "Microsoft.CSharp")
    set_property(
        TARGET ${library_name}
        PROPERTY VS_PACKAGE_REFERENCES
        "NUnit_3.12.0")
endfunction()

BUILD_CSHARP_TEST(TestDeviceAPI)
BUILD_CSHARP_TEST(TestEnumerateDevices)
BUILD_CSHARP_TEST(TestGenericStreamingAPI)
BUILD_CSHARP_TEST(TestSoapyTypes)
BUILD_CSHARP_TEST(TestTimeConversion)