-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

SoapySDR = require("SoapySDR")

bit = require("bit")
ffi = require("ffi")
luaunit = require("luaunit")

local function testDeviceWithDirection(device, direction)
    -- For the null device, functions generally don't do anything or return some
    -- hardcoded value, but we can still make sure the LuaJIT translates values
    -- back and forth as expected.

    --
    -- Channels API
    --
    device:setFrontendMapping(direction, "0:0")
    device:setFrontendMapping(direction, "0:0")
    luaunit.assertIsString(device:getFrontendMapping(direction))
    luaunit.assertIsTable(device:getChannelInfo(direction, 0))
    luaunit.assertIsBoolean(device:getFullDuplex(direction, 0))

    --
    -- Stream API
    --
    luaunit.assertIsTable(device:getStreamFormats(direction, 0))
    local format, fullScale = unpack(device:getNativeStreamFormat(direction, 0))
    luaunit.assertEquals(format, SoapySDR.Format.CS16)
    luaunit.assertEquals(fullScale, bit.lshift(1, 15))
    luaunit.assertIsTable(device:getStreamArgsInfo(direction, 0))

    local format = SoapySDR.Format.CF32
    local channels = {0,1}
    local args = "bufflen=8192,buffers=15"
    local stream = device:setupStream(direction, format, channels, args)

    luaunit.assertEquals(device:getStreamMTU(stream), 1024)

    local flags = bit.bor(SoapySDR.StreamFlags.HAS_TIME, SoapySDR.StreamFlags.END_BURST)
    local timeNs = 1000
    local numElems = 1024
    luaunit.assertEquals(
        device:activateStream(stream, flags, timeNs, numElems),
        SoapySDR.Error.NOT_SUPPORTED)
    -- Default parameter causes specific null device behavior
    luaunit.assertEquals(device:activateStream(stream), 0)

    local cf32Buff = ffi.new("complex float[?]", numElems)
    local cf32Buff2D = ffi.new("complex float*[1]", {cf32Buff})
    local timeoutUs = 100000

    local readOutput = device:readStream(stream, cf32Buff2D, numElems, timeoutUs)
    luaunit.assertEquals(readOutput[1], SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(readOutput[2], 0)
    luaunit.assertEquals(readOutput[3], 0)

    readOutput = device:readStream(stream, cf32Buff2D, numElems) -- Without optional parameter
    luaunit.assertEquals(readOutput[1], SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(readOutput[2], 0)
    luaunit.assertEquals(readOutput[3], 0)

    local writeOutput = device:writeStream(stream, cf32Buff2D, numElems, flags, timeNs, timeoutUs)
    luaunit.assertEquals(writeOutput[1], SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(writeOutput[2], flags)

    writeOutput = device:writeStream(stream, cf32Buff2D, numElems) -- Without optional parameters
    luaunit.assertEquals(writeOutput[1], SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(writeOutput[2], 0)

    local readStreamStatusOutput = device:readStreamStatus(stream, timeoutUs)
    luaunit.assertEquals(readStreamStatusOutput[1], SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(readStreamStatusOutput[2], 0)
    luaunit.assertEquals(readStreamStatusOutput[3], 0)
    luaunit.assertEquals(readStreamStatusOutput[4], 0)

    local readStreamStatusOutput = device:readStreamStatus(stream) -- Without optional parameter
    luaunit.assertEquals(readStreamStatusOutput[1], SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(readStreamStatusOutput[2], 0)
    luaunit.assertEquals(readStreamStatusOutput[3], 0)
    luaunit.assertEquals(readStreamStatusOutput[4], 0)

    luaunit.assertEquals(
        device:deactivateStream(stream, flags, timeNs),
        SoapySDR.Error.NOT_SUPPORTED)
    luaunit.assertEquals(device:closeStream(stream), 0)

    --
    -- Antenna API
    --
    luaunit.assertIsTable(device:listAntennas(direction, 0))
    device:setAntenna(direction, 0, "ANT")
    luaunit.assertIsString(device:getAntenna(direction, 0))

    --
    -- Frontend corrections API
    --
    luaunit.assertIsBoolean(device:hasDCOffsetMode(direction, 0))
    device:setDCOffsetMode(direction, 0, true)
    luaunit.assertIsBoolean(device:getDCOffsetMode(direction, 0))
    luaunit.assertIsBoolean(device:hasDCOffset(direction, 0))

    -- Test all valid types
    device:setDCOffset(direction, 0, ffi.new("complex", 1.0, 0.0))
    device:setDCOffset(direction, 0, ffi.new("complex float", 1.0, 0.0))
    device:setDCOffset(direction, 0, 1.0)
    luaunit.assertEquals(
        ffi.typeof(device:getDCOffset(direction, 0)),
        ffi.typeof("complex"))

    luaunit.assertIsBoolean(device:hasIQBalance(direction, 0))

    -- Test all valid types
    device:setIQBalance(direction, 0, ffi.new("complex", 1.0, 0.0))
    device:setIQBalance(direction, 0, ffi.new("complex float", 1.0, 0.0))
    device:setIQBalance(direction, 0, 1.0)
    luaunit.assertEquals(
        ffi.typeof(device:getIQBalance(direction, 0)),
        ffi.typeof("complex"))

    luaunit.assertIsBoolean(device:hasIQBalanceMode(direction, 0))
    device:setIQBalanceMode(direction, 0, true)
    luaunit.assertIsBoolean(device:getIQBalanceMode(direction, 0))

    luaunit.assertIsBoolean(device:hasFrequencyCorrection(direction, 0))
    device:setFrequencyCorrection(direction, 0, 0.0)
    luaunit.assertIsNumber(device:getFrequencyCorrection(direction, 0))

    --
    -- Gain API
    --
    luaunit.assertIsTable(device:listGains(direction, 0))
    luaunit.assertIsBoolean(device:hasGainMode(direction, 0))
    device:setGainMode(direction, 0, true)
    luaunit.assertIsBoolean(device:getGainMode(direction, 0))

    device:setGain(direction, 0, 0.0)
    device:setGainElement(direction, 0, "", 0.0)
    luaunit.assertIsNumber(device:getGain(direction, 0))
    luaunit.assertIsNumber(device:getGainElement(direction, 0, ""))

    luaunit.assertEquals(
        ffi.typeof(device:getGainRange(direction, 0)),
        ffi.typeof("SoapySDRRange"))
    luaunit.assertEquals(
        ffi.typeof(device:getGainElementRange(direction, 0, "")),
        ffi.typeof("SoapySDRRange"))
end

function testDevice()
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
