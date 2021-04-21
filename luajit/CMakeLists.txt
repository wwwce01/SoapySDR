configure_file(
    init.in.lua
    ${CMAKE_CURRENT_BINARY_DIR}/init.lua
@ONLY)

set(files
    Complex.lua
    Device.lua
    ${CMAKE_CURRENT_BINARY_DIR}/init.lua
    Lib.lua
    Logger.lua
    MetaTables.lua
    Time.lua
    Utility.lua)

install(
    FILES ${files}
    DESTINATION share/lua/5.1/SoapySDR)
