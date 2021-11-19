-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

SoapySDR = require("SoapySDR")

ffi = require("ffi")
io = require("io")
luaunit = require("luaunit")

function testLogger()
    local tmpFile = io.tmpfile()

    function logFunction(logLevel, rawMessage)
        tmpFile:write(ffi.string(rawMessage), "\n")
    end

    SoapySDR.Logger.registerHandler(logFunction)
    SoapySDR.Logger.setLevel(SoapySDR.Logger.Level.INFO)

    SoapySDR.Logger.log(SoapySDR.Logger.Level.WARNING, "Warning")
    SoapySDR.Logger.log(SoapySDR.Logger.Level.ERROR, "Error")
    SoapySDR.Logger.logf(SoapySDR.Logger.Level.INFO, "Info")
    SoapySDR.Logger.logf(SoapySDR.Logger.Level.INFO, "Info %s %d", "foo", 418)

    -- Reset to default logger, make sure the next call doesn't log to the file
    SoapySDR.Logger.registerHandler(nil)
    SoapySDR.Logger.log(SoapySDR.Logger.Level.INFO, "Info")

    tmpFile:seek("set")
    local logContents = tmpFile:read("*a")

    luaunit.assertEquals(logContents, "Warning\nError\nInfo\nInfo foo 418\n")
end

local runner = luaunit.LuaUnit.new()
os.exit(runner:runSuite())
