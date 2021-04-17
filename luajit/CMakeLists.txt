set(files
    Complex.lua
    Device.lua
    init.lua
    Lib.lua
    MetaTables.lua
    Utility.lua)

install(
    FILES ${files}
    DESTINATION share/lua/5.1/SoapySDR)
