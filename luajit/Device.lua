-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("Lib")
local Utility = require("Utility")

--
-- Constructor
--

Device = {}
Device.__index = Device

function Device.new(param)
    local self = setmetatable({}, Device)

    -- Abstract away different C constructor functions
    local paramType = tostring(type(param))
    if paramType == "string" then
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_makeStrArgs(param),
            lib.SoapySDRDevice_unmake)
    elseif paramType == "table" then
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_make(Utility.tableToKwargs(param)),
            lib.SoapySDRDevice_unmake)
    elseif paramType == "SoapySDRKwargs" then
        -- TODO: proper type check
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_make(param),
            lib.SoapySDRDevice_unmake)
    else
        -- Last-ditch effort
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
        ffi.C.free))
    Utility.checkDeviceError()

    return ret
end

function Device:getHardwareKey(self)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getHardwareKey(self.__deviceHandle),
        ffi.C.free))
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
end

function Device:getFrontendMapping(self, direction)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getFrontendMapping(self.__deviceHandle, direction),
        ffi.C.free))
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
        ffi.C.free))
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
end

function Device:getAntenna(self, direction, channel)
    local ret = ffi.string(ffi.gc(
        lib.SoapySDRDevice_getAntenna(self.__deviceHandle, direction, channel),
        ffi.C.free))
    Utility.checkDeviceError()

    return ret
end

return Device
