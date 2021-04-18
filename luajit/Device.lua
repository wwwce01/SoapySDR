-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local Complex = require("SoapySDR.Complex")
local ffi = require("ffi")
local lib = require("SoapySDR.Lib")
local Utility = require("SoapySDR.Utility")

--
-- Device enumeration
--

local function enumerateDevices(args)
    local devs = nil
    local lengthPtr = ffi.new("size_t[1]")

    -- Abstract away different functions
    local argsType = tostring(type(args))
    if argsType == "table" then
        devs = Utility.processRawKwargsList(
            lib.SoapySDRDevice_enumerate(Utility.tableToKwargs(args), lengthPtr),
            lengthPtr)
    else
        devs = Utility.processRawKwargsList(
            lib.SoapySDRDevice_enumerateStrArgs(tostring(args), lengthPtr),
            lengthPtr)
    end

    return devs
end

--
-- Constructor
--

local Device = {}
Device.__index = Device

function Device.make(self, param)
    local mt =
    {
        __tostring = function(dev)
            return string.format("%s:%s", dev:getDriverKey(), dev:getHardwareKey())
        end
    }

    local self = setmetatable(mt, Device)

    -- Abstract away different C constructor functions
    local paramType = tostring(type(param))
    if paramType == "table" then
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_make(Utility.tableToKwargs(param)),
            lib.SoapySDRDevice_unmake)
    elseif (paramType == "SoapySDRKwargs") or (param == nil) then
        -- TODO: proper type check
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_make(param),
            lib.SoapySDRDevice_unmake)
    else
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_makeStrArgs(tostring(param)),
            lib.SoapySDRDevice_unmake)
    end
    Utility.checkDeviceError()

    if self == nil then
        error("Device: null self")
    end
    if self.__deviceHandle == nil then
        error("Device: null device handle")
    end

    return self
end

--
-- Identification API
--

function Device:getDriverKey()
    local ret = Utility.processRawString(lib.SoapySDRDevice_getDriverKey(self.__deviceHandle))
    Utility.checkDeviceError()

    return ret
end

function Device:getHardwareKey()
    local ret = Utility.processRawString(lib.SoapySDRDevice_getHardwareKey(self.__deviceHandle))
    Utility.checkDeviceError()

    return ret
end

function Device:getHardwareInfo()
    local ret = Utility.processRawKwargs(lib.SoapySDRDevice_getHardwareInfo(self.__deviceHandle))
    Utility.checkDeviceError()

    return ret
end

--
-- Channels API
--

function Device:setFrontendMapping(direction, mapping)
    Utility.checkError(lib.SoapySDRDevice_setFrontendMapping(
        self.__deviceHandle,
        direction,
        mapping))
    Utility.checkDeviceError()
end

function Device:getFrontendMapping(direction)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getFrontendMapping(self.__deviceHandle, direction),
        lib.SoapySDR_free))
    Utility.checkDeviceError()

    return ret
end

function Device:getNumChannels(direction)
    local ret = lib.SoapySDRDevice_getNumChannels(self.__deviceHandle, direction)
    Utility.checkDeviceError()

    return ret
end

function Device:getChannelInfo(direction, channel)
    local ret = Utility.processRawKwargs(lib.SoapySDRDevice_getChannelInfo(
        self.__deviceHandle,
        direction,
        channel))
    Utility.checkDeviceError()

    return ret
end

function Device:getFullDuplex(direction, channel)
    local ret = lib.SoapySDRDevice_getFullDuplex(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

--
-- Stream API (TODO: rest likely in own class)
--

function Device:getStreamFormats(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_getStreamFormats(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getNativeStreamFormat(direction, channel)
    local fullScalePtr = ffi.new("double[1]")

    local format = Utility.processRawString(lib.SoapySDRDevice_getNativeStreamFormat(
        self.__deviceHandle,
        direction,
        channel,
        fullScalePtr))
    Utility.checkDeviceError()

    return {format, fullScalePtr[0]}
end

function Device:getStreamArgsInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawArgInfoList(
        lib.SoapySDRDevice_getStreamArgsInfo(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

--
-- Direct buffer access API (TODO)
--

--
-- Antenna API
--

function Device:listAntennas(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_listAntennas(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:setAntenna(direction, channel, name)
    Utility.checkError(lib.SoapySDRDevice_setAntenna(
        self.__deviceHandle,
        direction,
        channel,
        name))
    Utility.checkDeviceError()
end

function Device:getAntenna(direction, channel)
    local ret = Utility.processRawString(lib.SoapySDRDevice_getAntenna(
        self.__deviceHandle,
        direction,
        channel))
    Utility.checkDeviceError()

    return ret
end

--
-- Frontend corrections API
--

function Device:hasDCOffsetMode(direction, channel)
    local ret = lib.SoapySDRDevice_hasDCOffsetMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setDCOffsetMode(direction, channel, automatic)
    Utility.checkError(lib.SoapySDRDevice_setDCOffsetMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
    Utility.checkDeviceError()
end

function Device:getDCOffsetMode(direction, channel)
    local ret = lib.SoapySDRDevice_getDCOffsetMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:hasDCOffset(direction, channel)
    local ret = lib.SoapySDRDevice_hasDCOffset(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setDCOffset(direction, channel, offset)
    local complexOffset = ffi.istype(offset, "complex") and offset or Complex(offset,0)

    Utility.checkError(lib.SoapySDRDevice_setDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
    Utility.checkDeviceError()
end

function Device:getDCOffset(direction, channel)
    local iPtr = ffi.new("double[1]")
    local qPtr = fii.new("double[1]")

    Utility.checkError(lib.SoapySDRDevice_getDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        iPtr,
        qPtr))
    Utility.checkDeviceError()

    return Complex(iPtr[0], qPtr[0])
end

function Device:hasIQBalance(direction, channel)
    local ret = lib.SoapySDRDevice_hasIQBalance(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setIQBalance(direction, channel, offset)
    local complexOffset = ffi.istype(offset, "complex") and offset or Complex(offset,0)

    Utility.checkError(lib.SoapySDRDevice_setIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
    Utility.checkDeviceError()
end

function Device:getIQBalance(direction, channel)
    local iPtr = ffi.new("double[1]")
    local qPtr = fii.new("double[1]")

    Utility.checkError(lib.SoapySDRDevice_getIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        iPtr,
        qPtr))
    Utility.checkDeviceError()

    return Complex(iPtr[0], qPtr[0])
end

function Device:hasIQBalanceMode(direction, channel)
    local ret = lib.SoapySDRDevice_hasIQBalanceMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setIQBalanceMode(direction, channel, automatic)
    Utility.checkError(lib.SoapySDRDevice_setIQBalanceMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
    Utility.checkDeviceError()
end

function Device:getIQBalanceMode(direction, channel)
    local ret = lib.SoapySDRDevice_getIQBalanceMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:hasFrequencyCorrection(direction, channel)
    local ret = lib.SoapySDRDevice_hasFrequencyCorrection(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setFrequencyCorrection(direction, channel, value)
    Utility.checkError(lib.SoapySDRDevice_setFrequencyCorrection(
        self.__deviceHandle,
        direction,
        channel,
        value))
    Utility.checkDeviceError()
end

function Device:getFrequencyCorrection(direction, channel)
    local ret = lib.SoapySDRDevice_getFrequencyCorrection(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

--
-- Gain API
--

function Device:listGains(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_listGains(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:hasGainMode(direction, channel)
    local ret = lib.SoapySDRDevice_hasGainMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setGainMode(direction, channel, automatic)
    Utility.checkError(lib.SoapySDRDevice_setGainMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
    Utility.checkDeviceError()
end

function Device:getGainMode(direction, channel)
    local ret = lib.SoapySDRDevice_getGainMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setGain(direction, channel, value)
    Utility.checkError(lib.SoapySDRDevice_setGain(
        self.__deviceHandle,
        direction,
        channel,
        value))
    Utility.checkDeviceError()
end

function Device:setGainElement(direction, channel, name, value)
    Utility.checkError(lib.SoapySDRDevice_setGainElement(
        self.__deviceHandle,
        direction,
        channel,
        name,
        value))
    Utility.checkDeviceError()
end

function Device:getGain(direction, channel)
    local ret = lib.SoapySDRDevice_getGain(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:getGainElement(direction, channel, name)
    local ret = lib.SoapySDRDevice_getGainElement(self.__deviceHandle, direction, channel, name)
    Utility.checkDeviceError()

    return ret
end

function Device:getGainRange(direction, channel)
    local ret = lib.SoapySDRDevice_getGainRange(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:getGainElementRange(direction, channel, name)
    local ret = lib.SoapySDRDevice_getGainElementRange(self.__deviceHandle, direction, channel, name)
    Utility.checkDeviceError()

    return ret
end

--
-- Frequency API
--

function Device:setFrequency(direction, channel, frequency, args)
    Utility.checkError(lib.SoapySDRDevice_setFrequency(
        self.__deviceHandle,
        direction,
        channel,
        frequency,
        args))
    Utility.checkDeviceError()
end

function Device:setFrequencyComponent(direction, channel, name, frequency, args)
    Utility.checkError(lib.SoapySDRDevice_setFrequencyComponent(
        self.__deviceHandle,
        direction,
        channel,
        name,
        frequency,
        args))
    Utility.checkDeviceError()
end

function Device:getFrequency(direction, channel)
    local ret = lib.SoapySDRDevice_getFrequency(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyComponent(direction, channel, name)
    local ret = lib.SoapySDRDevice_getFrequencyComponent(self.__deviceHandle, direction, channel, name)
    Utility.checkDeviceError()

    return ret
end

function Device:listFrequencies(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_listFrequencies(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawRangeList(
        lib.SoapySDRDevice_getFrequencyRange(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyRangeComponent(direction, channel, name)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawRangeList(
        lib.SoapySDRDevice_getFrequencyRangeComponent(self.__deviceHandle, direction, channel, name, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyArgsInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawArgInfoList(
        lib.SoapySDRDevice_getFrequencyArgsInfo(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

--
-- Sample Rate API
--

return {enumerateDevices, Device}
