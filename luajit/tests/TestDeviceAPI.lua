-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

SoapySDR = require("SoapySDR")

bit = require("bit")
ffi = require("ffi")
luaunit = require("luaunit")

local function testNativeStreamFormat(device, direction)
end

local function testDeviceWithDirection(device, direction)
    -- For the null device, functions generally don't do anything or return some
    -- hardcoded value, but we can still make sure the LuaJIT translates data
    -- back and forth as expected.

    -- Channels API
    device:setFrontendMapping(direction, "0:0")
    device:setFrontendMapping(SoapySDR.Direction.RX, "0:0")
    luaunit.assertIsString(device:getFrontendMapping(direction))
    luaunit.assertIsTable(device:getChannelInfo(direction, 0))
    luaunit.assertIsBoolean(device:getFullDuplex(direction, 0))

    -- Stream API
    luaunit.assertIsTable(device:getStreamFormats(direction, 0))
    local format, fullScale = unpack(device:getNativeStreamFormat(direction, 0))
    luaunit.assertEquals(format, SoapySDR.Format.CS16)
    luaunit.assertEquals(fullScale, bit.lshift(1, 15))
    luaunit.assertIsTable(device:getStreamArgsInfo(direction, 0))
end

function test_Device()
    -- Make sure either method works.
    local device = SoapySDR.Device("type=null")
    device = SoapySDR.Device({type="null"})
    luaunit.assertEquals(tostring(device), "null:null")

    -- Identification API
    luaunit.assertEquals("null", device:getDriverKey())
    luaunit.assertEquals("null", device:getHardwareKey())
    luaunit.assertIsTable(device:getHardwareInfo())

    testDeviceWithDirection(device, SoapySDR.Direction.TX)
    testDeviceWithDirection(device, SoapySDR.Direction.RX)
end

local runner = luaunit.LuaUnit.new()
os.exit(runner:runSuite())
