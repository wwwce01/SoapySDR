-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

SoapySDR = require("SoapySDR")

ffi = require("ffi")
luaunit = require("luaunit")

--
-- Utility
--

local function hasNullDevice(devices)
    for i=1,#devices do
        luaunit.assertIsTable(devices[i])
        luaunit.assertIsString(devices[i]["driver"])
        if(devices[i]["driver"] == "null") then
            return true
        end
    end

    return false
end

--
-- Tests
--

function test_EnumerateDevicesNoParam()
    -- We can't guarantee the number of devices connected to the
    -- machine, so just make sure this doesn't error out.
    SoapySDR.enumerateDevices()
end

function test_EnumerateDevicesStringParam()
    local devices = SoapySDR.enumerateDevices("type=null")
    luaunit.assertTrue(#devices >= 1)
    luaunit.assertTrue(hasNullDevice(devices))
end

function test_EnumerateDevicesTableParam()
    local devices = SoapySDR.enumerateDevices({type="null"})
    luaunit.assertTrue(#devices >= 1)
    luaunit.assertTrue(hasNullDevice(devices))
end

function test_ErrorCodes()
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.TIMEOUT), "TIMEOUT")
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.STREAM_ERROR), "STREAM_ERROR")
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.CORRUPTION), "CORRUPTION")
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.OVERFLOW), "OVERFLOW")
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.NOT_SUPPORTED), "NOT_SUPPORTED")
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.TIME_ERROR), "TIME_ERROR")
    luaunit.assertEquals(SoapySDR.Error.ToString(SoapySDR.Error.UNDERFLOW), "UNDERFLOW")
    luaunit.assertEquals(SoapySDR.Error.ToString(0), "UNKNOWN")
end

local runner = luaunit.LuaUnit.new()
os.exit(runner:runSuite())
