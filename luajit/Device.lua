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

function Device.new(param)
    local self = setmetatable({}, Device)

    -- Abstract away different C constructor functions
    local paramType = tostring(type(param))
    if paramType == "table" then
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_make(Utility.tableToKwargs(param)),
            lib.SoapySDRDevice_unmake)
    elseif paramType == "SoapySDRKwargs" then
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

    if self.__deviceHandle == nil then
        error("Device: null device handle")
    end

    return self
end

--
-- Identification API
--

function Device:getDriverKey(self)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getDriverKey(self.__deviceHandle),
        lib.SoapySDR_free))
    Utility.checkDeviceError()

    return ret
end

function Device:getHardwareKey(self)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getHardwareKey(self.__deviceHandle),
        lib.SoapySDR_free))
    Utility.checkDeviceError()

    return ret
end

function Device:getHardwareInfo(self)
    local ret = ffi.gc(
        lib.SoapySDRDevice_getHardwareInfo(self.__deviceHandle),
        lib.SoapySDRKwargs_clear)
    Utility.checkDeviceError()

    return ret
end

--
-- Channels API
--

function Device:setFrontendMapping(self, direction, mapping)
    Utility.checkError(lib.SoapySDRDevice_setFrontendMapping(
        self.__deviceHandle,
        direction,
        mapping))
    Utility.checkDeviceError()
end

function Device:getFrontendMapping(self, direction)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getFrontendMapping(self.__deviceHandle, direction),
        lib.SoapySDR_free))
    Utility.checkDeviceError()

    return ret
end

function Device:getNumChannels(self, direction)
    local ret = lib.SoapySDRDevice_getNumChannels(self.__deviceHandle, direction)
    Utility.checkDeviceError()

    return ret
end

function Device:getChannelInfo(self, direction, channel)
    local ret = ffi.gc(
        lib.SoapySDRDevice_getChannelInfo(self.__deviceHandle, direction, channel),
        lib.SoapySDRKwargs_clear)
    Utility.checkDeviceError()

    return ret
end

function Device:getFullDuplex(self, direction, channel)
    local ret = lib.SoapySDRDevice_getFullDuplex(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

--
-- Stream API (TODO: rest likely in own class)
--

function Device:getStreamFormats(self, direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_getStreamFormats(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getNativeStreamFormat(self, direction, channel)
    local fullScalePtr = ffi.new("double[1]")

    local format = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getNativeStreamFormat(self.__deviceHandle, direction, channel, fullScalePtr),
        lib.SoapySDR_free))
    Utility.checkDeviceError()

    return format, fullScalePtr[0]
end

function Device:getStreamArgsInfo(self, direction, channel)
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

function Device:listAntennas(self, direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_listAntennas(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:setAntenna(self, direction, channel, name)
    Utility.checkError(lib.SoapySDRDevice_setAntenna(
        self.__deviceHandle,
        direction,
        channel,
        name))
    Utility.checkDeviceError()
end

function Device:getAntenna(self, direction, channel)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getAntenna(self.__deviceHandle, direction, channel),
        lib.SoapySDR_free))
    Utility.checkDeviceError()

    return ret
end

--
-- Frontend corrections API
--

function Device:hasDCOffsetMode(self, direction, channel)
    local ret = lib.SoapySDRDevice_hasDCOffsetMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setDCOffsetMode(self, direction, channel, automatic)
    Utility.checkError(lib.SoapySDRDevice_setDCOffsetMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
    Utility.checkDeviceError()
end

function Device:getDCOffsetMode(self, direction, channel)
    local ret = lib.SoapySDRDevice_getDCOffsetMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:hasDCOffset(self, direction, channel)
    local ret = lib.SoapySDRDevice_hasDCOffset(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setDCOffset(self, direction, channel, offset)
    local complexOffset = ffi.istype(offset, "complex") and offset or Complex(offset,0)

    Utility.checkError(lib.SoapySDRDevice_setDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
    Utility.checkDeviceError()
end

function Device:getDCOffset(self, direction, channel)
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

function Device:hasIQBalance(self, direction, channel)
    local ret = lib.SoapySDRDevice_hasIQBalance(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setIQBalance(self, direction, channel, offset)
    local complexOffset = ffi.istype(offset, "complex") and offset or Complex(offset,0)

    Utility.checkError(lib.SoapySDRDevice_setIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
    Utility.checkDeviceError()
end

function Device:getIQBalance(self, direction, channel)
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

function Device:hasIQBalanceMode(self, direction, channel)
    local ret = lib.SoapySDRDevice_hasIQBalanceMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setIQBalanceMode(self, direction, channel, automatic)
    Utility.checkError(lib.SoapySDRDevice_setIQBalanceMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
    Utility.checkDeviceError()
end

function Device:getIQBalanceMode(self, direction, channel)
    local ret = lib.SoapySDRDevice_getIQBalanceMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:hasFrequencyCorrection(self, direction, channel)
    local ret = lib.SoapySDRDevice_hasFrequencyCorrection(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setFrequencyCorrection(self, direction, channel, value)
    Utility.checkError(lib.SoapySDRDevice_setFrequencyCorrection(
        self.__deviceHandle,
        direction,
        channel,
        value))
    Utility.checkDeviceError()
end

function Device:getFrequencyCorrection(self, direction, channel)
    local ret = lib.SoapySDRDevice_getFrequencyCorrection(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

--
-- Gain API
--

function Device:listGains(self, direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_listGains(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:hasGainMode(self, direction, channel)
    local ret = lib.SoapySDRDevice_hasGainMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setGainMode(self, direction, channel, automatic)
    Utility.checkError(lib.SoapySDRDevice_setGainMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
    Utility.checkDeviceError()
end

function Device:getGainMode(self, direction, channel)
    local ret = lib.SoapySDRDevice_getGainMode(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:setGain(self, direction, channel, value)
    Utility.checkError(lib.SoapySDRDevice_setGain(
        self.__deviceHandle,
        direction,
        channel,
        value))
    Utility.checkDeviceError()
end

function Device:setGainElement(self, direction, channel, name, value)
    Utility.checkError(lib.SoapySDRDevice_setGainElement(
        self.__deviceHandle,
        direction,
        channel,
        name,
        value))
    Utility.checkDeviceError()
end

function Device:getGain(self, direction, channel)
    local ret = lib.SoapySDRDevice_getGain(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:getGainElement(self, direction, channel, name)
    local ret = lib.SoapySDRDevice_getGainElement(self.__deviceHandle, direction, channel, name)
    Utility.checkDeviceError()

    return ret
end

function Device:getGainRange(self, direction, channel)
    local ret = lib.SoapySDRDevice_getGainRange(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:getGainElementRange(self, direction, channel, name)
    local ret = lib.SoapySDRDevice_getGainElementRange(self.__deviceHandle, direction, channel, name)
    Utility.checkDeviceError()

    return ret
end

--
-- Frequency API
--

function Device:setFrequency(self, direction, channel, frequency, args)
    Utility.checkError(lib.SoapySDRDevice_setFrequency(
        self.__deviceHandle,
        direction,
        channel,
        frequency,
        args))
    Utility.checkDeviceError()
end

function Device:setFrequencyComponent(self, direction, channel, name, frequency, args)
    Utility.checkError(lib.SoapySDRDevice_setFrequencyComponent(
        self.__deviceHandle,
        direction,
        channel,
        name,
        frequency,
        args))
    Utility.checkDeviceError()
end

function Device:getFrequency(self, direction, channel)
    local ret = lib.SoapySDRDevice_getFrequency(self.__deviceHandle, direction, channel)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyComponent(self, direction, channel, name)
    local ret = lib.SoapySDRDevice_getFrequencyComponent(self.__deviceHandle, direction, channel, name)
    Utility.checkDeviceError()

    return ret
end

function Device:listFrequencies(self, direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawStringList(
        lib.SoapySDRDevice_listFrequencies(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyRange(self, direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawRangeList(
        lib.SoapySDRDevice_getFrequencyRange(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyRangeComponent(self, direction, channel, name)
    local lengthPtr = ffi.new("size_t[1]")
    local ret = Utility.processRawRangeList(
        lib.SoapySDRDevice_getFrequencyRangeComponent(self.__deviceHandle, direction, channel, name, lengthPtr),
        lengthPtr)
    Utility.checkDeviceError()

    return ret
end

function Device:getFrequencyArgsInfo(self, direction, channel)
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

return enumerateDevices, Device
