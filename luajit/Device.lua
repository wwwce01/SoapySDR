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

    -- No parameter means no args
    args = args or ""

    -- Abstract away different functions
    local argsType = tostring(type(args))
    if argsType == "string" then
        devs = Utility.processRawKwargsList(
            lib.SoapySDRDevice_enumerateStrArgs(args, lengthPtr),
            lengthPtr)
    else
        devs = Utility.processRawKwargsList(
            lib.SoapySDRDevice_enumerate(Utility.toKwargs(args), lengthPtr),
            lengthPtr)
    end

    return devs
end

--
-- Constructor
--

local Device = {}
Device.__index = Device

function Device.make(param)
    local mt =
    {
        __tostring = function(dev)
            return string.format("%s:%s", dev:getDriverKey(), dev:getHardwareKey())
        end
    }

    local self = setmetatable(mt, Device)

    -- No parameter means no args
    param = param or ""

    -- Abstract away different C constructor functions
    local paramType = tostring(type(param))
    if paramType == "string" then
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_makeStrArgs(param),
            lib.SoapySDRDevice_unmake)
    else
        self.__deviceHandle = ffi.gc(
            lib.SoapySDRDevice_make(Utility.toKwargs(param)),
            lib.SoapySDRDevice_unmake)
    end

    if self.__deviceHandle == nil then
        error("Invalid device args")
    end

    return self
end

--
-- Identification API
--

function Device:getDriverKey()
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_getDriverKey(self.__deviceHandle)))
end

function Device:getHardwareKey()
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_getHardwareKey(self.__deviceHandle)))
end

function Device:getHardwareInfo()
    return Utility.processRawKwargs(Utility.checkDeviceError(lib.SoapySDRDevice_getHardwareInfo(self.__deviceHandle)))
end

--
-- Channels API
--

function Device:setFrontendMapping(direction, mapping)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setFrontendMapping(
        self.__deviceHandle,
        direction,
        mapping))
end

function Device:getFrontendMapping(direction)
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_getFrontendMapping(
        self.__deviceHandle,
        direction)))
end

function Device:getNumChannels(direction)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getNumChannels(self.__deviceHandle, direction))
end

function Device:getChannelInfo(direction, channel)
    return Utility.processRawKwargs(Utility.checkDeviceError(lib.SoapySDRDevice_getChannelInfo(
        self.__deviceHandle,
        direction,
        channel)))
end

function Device:getFullDuplex(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getFullDuplex(self.__deviceHandle, direction, channel))
end

--
-- Stream API
--

function Device:getStreamFormats(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getStreamFormats(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

function Device:getNativeStreamFormat(direction, channel)
    local fullScalePtr = ffi.new("double[1]")

    local format = Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_getNativeStreamFormat(
        self.__deviceHandle,
        direction,
        channel,
        fullScalePtr)))

    return {format, fullScalePtr[0]}
end

function Device:getStreamArgsInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawArgInfoList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getStreamArgsInfo(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

function Device:setupStream(direction, format, channels, args)
    local ret = Utility.checkDeviceError(lib.SoapySDRDevice_setupStream(
        self.__deviceHandle,
        direction,
        format,
        Utility.luaArrayToFFIArray(channels, "size_t"),
        #channels,
        Utility.toKwargs(args)))

    if ret == nil then
        error("setupStream returned null stream")
    end

    return ret
end

function Device:closeStream(stream)
    return Utility.checkDeviceError(lib.SoapySDRDevice_closeStream(
        self.__deviceHandle,
        stream))
end

function Device:getStreamMTU(stream)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getStreamMTU(
        self.__deviceHandle,
        stream))
end

function Device:activateStream(stream, flags, timeNs, numElems)
    -- To allow for optional parameters
    flags = flags or 0
    timeNs = timeNs or 0
    numElems = numElems or 0

    return Utility.checkDeviceError(lib.SoapySDRDevice_activateStream(
        self.__deviceHandle,
        stream,
        flags,
        timeNs,
        numElems))
end

function Device:deactivateStream(stream, flags, timeNs)
    -- To allow for optional parameters
    flags = flags or 0
    timeNs = timeNs or 0

    return Utility.checkDeviceError(lib.SoapySDRDevice_deactivateStream(
        self.__deviceHandle,
        stream,
        flags,
        timeNs))
end

function Device:readStream(stream, buffs, numElems, timeoutUs)
    -- To allow for optional parameters
    timeoutUs = timeoutUs or 100000

    local flagsPtr = ffi.new("int[1]")
    local timeNsPtr = ffi.new("long long[1]")

    local ret = Utility.checkDeviceError(lib.SoapySDRDevice_readStream(
        self.__deviceHandle,
        stream,
        ffi.cast("void* const*", buffs),
        numElems,
        flagsPtr,
        timeNsPtr,
        timeoutUs))

    return {ret, flagsPtr[0], timeNsPtr[0]}
end

function Device:writeStream(stream, buffs, numElems, flagsIn, timeNs, timeoutUs)
    -- To allow for optional parameters
    flagsIn = flagsIn or 0
    timeNs = timeNs or 0
    timeoutUs = timeoutUs or 100000

    local flagsPtr = ffi.new("int[1]", {flagsIn})
    local timeNsPtr = ffi.new("long long[1]")

    local ret = Utility.checkDeviceError(lib.SoapySDRDevice_writeStream(
        self.__deviceHandle,
        stream,
        ffi.cast("const void* const*", buffs),
        numElems,
        flagsPtr,
        timeNs,
        timeoutUs))

    return {ret, flagsPtr[0]}
end

function Device:readStreamStatus(stream, timeoutUs)
    -- To allow for optional parameters
    timeoutUs = timeoutUs or 100000

    local chanMaskPtr = ffi.new("size_t[1]")
    local flagsPtr = ffi.new("int[1]")
    local timeNsPtr = ffi.new("long long[1]")

    local ret = Utility.checkDeviceError(lib.SoapySDRDevice_readStreamStatus(
        self.__deviceHandle,
        stream,
        chanMaskPtr,
        flagsPtr,
        timeNsPtr,
        timeoutUs))

    return {ret, chanMaskPtr[0], flagsPtr[0], timeNsPtr[0]}
end

--
-- Direct buffer access API (TODO?)
--

--
-- Antenna API
--

function Device:listAntennas(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listAntennas(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

function Device:setAntenna(direction, channel, name)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setAntenna(
        self.__deviceHandle,
        direction,
        channel,
        name))
end

function Device:getAntenna(direction, channel)
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_getAntenna(
        self.__deviceHandle,
        direction,
        channel)))
end

--
-- Frontend corrections API
--

function Device:hasDCOffsetMode(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasDCOffsetMode(self.__deviceHandle, direction, channel))
end

function Device:setDCOffsetMode(direction, channel, automatic)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setDCOffsetMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
end

function Device:getDCOffsetMode(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getDCOffsetMode(self.__deviceHandle, direction, channel))
end

function Device:hasDCOffset(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasDCOffset(self.__deviceHandle, direction, channel))
end

function Device:setDCOffset(direction, channel, offset)
    local complexOffset = ffi.istype(offset, "complex") and offset or Complex(offset,0)

    return Utility.checkDeviceError(lib.SoapySDRDevice_setDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
end

function Device:getDCOffset(direction, channel)
    local iPtr = ffi.new("double[1]")
    local qPtr = fii.new("double[1]")

    Utility.checkDeviceError(lib.SoapySDRDevice_getDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        iPtr,
        qPtr))

    return Complex(iPtr[0], qPtr[0])
end

function Device:hasIQBalance(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasIQBalance(self.__deviceHandle, direction, channel))
end

function Device:setIQBalance(direction, channel, offset)
    local complexOffset = ffi.istype(offset, "complex") and offset or Complex(offset,0)

    return Utility.checkDeviceError(lib.SoapySDRDevice_setIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
end

function Device:getIQBalance(direction, channel)
    local iPtr = ffi.new("double[1]")
    local qPtr = fii.new("double[1]")

    Utility.checkDeviceError(lib.SoapySDRDevice_getIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        iPtr,
        qPtr))

    return Complex(iPtr[0], qPtr[0])
end

function Device:hasIQBalanceMode(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasIQBalanceMode(self.__deviceHandle, direction, channel))
end

function Device:setIQBalanceMode(direction, channel, automatic)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setIQBalanceMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
end

function Device:getIQBalanceMode(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getIQBalanceMode(self.__deviceHandle, direction, channel))
end

function Device:hasFrequencyCorrection(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasFrequencyCorrection(self.__deviceHandle, direction, channel))
end

function Device:setFrequencyCorrection(direction, channel, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setFrequencyCorrection(
        self.__deviceHandle,
        direction,
        channel,
        value))
end

function Device:getFrequencyCorrection(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getFrequencyCorrection(self.__deviceHandle, direction, channel))
end

--
-- Gain API
--

function Device:listGains(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listGains(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

function Device:hasGainMode(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasGainMode(self.__deviceHandle, direction, channel))
end

function Device:setGainMode(direction, channel, automatic)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setGainMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
end

function Device:getGainMode(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getGainMode(self.__deviceHandle, direction, channel))
end

function Device:setGain(direction, channel, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setGain(
        self.__deviceHandle,
        direction,
        channel,
        value))
end

function Device:setGainElement(direction, channel, name, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setGainElement(
        self.__deviceHandle,
        direction,
        channel,
        name,
        value))
end

function Device:getGain(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getGain(self.__deviceHandle, direction, channel))
end

function Device:getGainElement(direction, channel, name)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getGainElement(self.__deviceHandle, direction, channel, name))
end

function Device:getGainRange(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getGainRange(self.__deviceHandle, direction, channel))
end

function Device:getGainElementRange(direction, channel, name)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getGainElementRange(self.__deviceHandle, direction, channel, name))
end

--
-- Frequency API
--

function Device:setFrequency(direction, channel, frequency, args)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setFrequency(
        self.__deviceHandle,
        direction,
        channel,
        frequency,
        args))
end

function Device:setFrequencyComponent(direction, channel, name, frequency, args)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setFrequencyComponent(
        self.__deviceHandle,
        direction,
        channel,
        name,
        frequency,
        args))
end

function Device:getFrequency(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getFrequency(self.__deviceHandle, direction, channel))
end

function Device:getFrequencyComponent(direction, channel, name)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getFrequencyComponent(self.__deviceHandle, direction, channel, name))
end

function Device:listFrequencies(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listFrequencies(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

function Device:getFrequencyRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getFrequencyRange(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr,
        "double"))
end

function Device:getFrequencyRangeComponent(direction, channel, name)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getFrequencyRangeComponent(self.__deviceHandle, direction, channel, name, lengthPtr),
        lengthPtr,
        "double"))
end

function Device:getFrequencyArgsInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawArgInfoList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getFrequencyArgsInfo(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

--
-- Sample Rate API
--

function Device:setSampleRate(direction, channel, rate)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setSampleRate(
        self.__deviceHandle,
        direction,
        channel,
        rate))
end

function Device:getSampleRate(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getSampleRate(self.__deviceHandle, direction, channel))
end

function Device:listSampleRates(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listSampleRates(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr,
        "double"))
end

function Device:getSampleRateRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getSampleRateRange(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr,
        "SoapySDRRange"))
end

--
-- Bandwidth API
--

function Device:setBandwidth(direction, channel, bw)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setBandwidth(
        self.__deviceHandle,
        direction,
        channel,
        bw))
end

function Device:getBandwidth(direction, channel)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getBandwidth(self.__deviceHandle, direction, channel))
end

function Device:listBandwidths(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listBandwidths(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr,
        "double"))
end

function Device:getBandwidthRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getBandwidthRange(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr,
        "SoapySDRRange"))
end

--
-- Clocking API
--

function Device:setMasterClockRate(rate)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setMasterClockRate(
        self.__deviceHandle,
        rate))
end

function Device:getMasterClockRate()
    return Utility.checkDeviceError(lib.SoapySDRDevice_getMasterClockRate(self.__deviceHandle))
end

function Device:getMasterClockRates()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getMasterClockRates(self.__deviceHandle, lengthPtr),
        lengthPtr,
        "double"))
end

function Device:setReferenceClockRate(rate)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setReferenceClockRate(
        self.__deviceHandle,
        rate))
end

function Device:getReferenceClockRate()
    return Utility.checkDeviceError(lib.SoapySDRDevice_getReferenceClockRate(self.__deviceHandle))
end

function Device:getReferenceClockRates()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getReferenceClockRates(self.__deviceHandle, lengthPtr),
        lengthPtr,
        "double"))
end

function Device:listClockSources()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listClockSources(self.__deviceHandle),
        lengthPtr))
end

function Device:setClockSource(source)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setClockSource(
        self.__deviceHandle,
        source))
end

function Device:getClockSource()
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_getClockSource(self.__deviceHandle)))
end

--
-- Time API
--

function Device:getTimeSources()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getTimeSources(self.__deviceHandle, lengthPtr),
        lengthPtr))
end

function Device:setTimeSource(source)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setTimeSource(
        self.__deviceHandle,
        source))
end

function Device:getTimeSource()
    return Utility.processRawString(Utility.checkDeviceError(
        lib.SoapySDRDevice_getTimeSource(self.__deviceHandle)))
end

function Device:hasHardwareTime(optionalArg)
    return Utility.checkDeviceError(lib.SoapySDRDevice_hasHardwareTime(self.__deviceHandle, optionalArg))
end

function Device:getHardwareTime(optionalArg)
    return Utility.checkDeviceError(lib.SoapySDRDevice_getHardwareTime(self.__deviceHandle, optionalArg))
end

function Device:setHardwareTime(time, optionalArg)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setHardwareTime(
        self.__deviceHandle,
        time,
        optionalArg))
end

function Device:setCommandTime(time, optionalArg)
    return Utility.checkDeviceError(lib.SoapySDRDevice_setCommandTime(
        self.__deviceHandle,
        time,
        optionalArg))
end

--
-- Sensor API
--

function Device:listSensors()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listSensors(self.__deviceHandle, lengthPtr),
        lengthPtr))
end

function Device:getSensorInfo(key)
    return Utility.processRawArgInfo(Utility.checkDeviceError(lib.SoapySDRDevice_getSensorInfo(self.__deviceHandle, key)))
end

function Device:readSensor(key)
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_readSensor(self.__deviceHandle, key)))
end

function Device:listChannelSensors(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listChannelSensors(self.__deviceHandle, lengthPtr, direction, channel),
        lengthPtr))
end

function Device:getChannelSensorInfo(direction, channel, key)
    return Utility.processRawArgInfo(Utility.checkDeviceError(lib.SoapySDRDevice_getChannelSensorInfo(
        self.__deviceHandle,
        direction,
        channel,
        key)))
end

function Device:readChannelSensor(direction, channel, key)
    Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_readChannelSensor(
        self.__deviceHandle,
        direction,
        channel,
        key)))
end

--
-- Register API
--

function Device:listRegisterInterfaces()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listRegisterInterfaces(self.__deviceHandle, lengthPtr),
        lengthPtr))
end

function Device:writeRegister(name, addr, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeRegister(
        self.__deviceHandle,
        name,
        addr,
        value))
end

function Device:readRegister(name, addr)
    return Utility.checkDeviceError(lib.SoapySDRDevice_readRegister(self.__deviceHandle, name, addr))
end

function Device:writeRegisters(name, addr, values)
    -- TODO: support LuaJIT arrays (more likely case anyway)
    if tostring(type(values)) ~= "table" then
        error("The \"values\" array must be a Lua table/array.")
    end

    -- TODO: check for LuaJIT array, which is 0-indexed
    valuesFFI = ffi.new("unsigned[?]", #values)
    for i = 0,#values do
        valuesFFI[i] = values[i+1]
    end

    return Utility.checkDeviceError(lib.SoapySDRDevice_writeRegisters(
        self.__deviceHandle,
        name,
        addr,
        ffi.cast("unsigned*", valuesFFI),
        #values))
end

function Device:readRegisters(direction, name, addr)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawPrimitiveList(Utility.checkDeviceError(
        lib.SoapySDRDevice_readRegisters(self.__deviceHandle, name, addr, lengthPtr),
        lengthPtr,
        "unsigned"))
end

--
-- Settings API
--

function Device:getSettingInfo()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawArgInfoList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getSettingInfo(self.__deviceHandle, lengthPtr),
        lengthPtr))
end

-- TODO: smarter tostring() logic. What if FFI number?
function Device:writeSetting(key, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeSetting(
        self.__deviceHandle,
        key,
        tostring(value)))
end

function Device:readSetting(key)
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_readSetting(self.__deviceHandle, key)))
end

function Device:getChannelSettingInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawArgInfoList(Utility.checkDeviceError(
        lib.SoapySDRDevice_getChannelSettingInfo(self.__deviceHandle, direction, channel, lengthPtr),
        lengthPtr))
end

-- TODO: smarter tostring() logic. What if FFI number?
function Device:writeChannelSetting(direction, channel, key, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeChannelSetting(
        self.__deviceHandle,
        direction,
        channel,
        key,
        tostring(value)))
end

function Device:readChannelSetting(direction, channel, key)
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_readChannelSetting(
        self.__deviceHandle,
        direction,
        channel,
        key)))
end

--
-- GPIO API
--

function Device:listGPIOBanks()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listGPIOBanks(self.__deviceHandle, lengthPtr),
        lengthPtr))
end

function Device:writeGPIO(bank, value)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeGPIO(
        self.__deviceHandle,
        bank,
        value))
end

function Device:writeGPIOMasked(bank, value, mask)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeGPIOMasked(
        self.__deviceHandle,
        bank,
        value,
        mask))
end

function Device:readGPIO(bank)
    return Utility.checkDeviceError(lib.SoapySDRDevice_readGPIO(self.__deviceHandle, bank))
end

function Device:writeGPIODir(bank, dir)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeGPIODir(
        self.__deviceHandle,
        bank,
        dir))
end

function Device:writeGPIODirMasked(bank, dir, mask)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeGPIODirMasked(
        self.__deviceHandle,
        bank,
        dir,
        mask))
end

function Device:readGPIODir(bank)
    return Utility.checkDeviceError(lib.SoapySDRDevice_readGPIODir(self.__deviceHandle, bank))
end

--
-- I2C API
--

-- TODO: smarter input conversion to const char*
function Device:writeI2C(addr, data)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeI2C(
        self.__deviceHandle,
        addr,
        ffi.cast("const char*", data),
        ffi.sizeof(data)))
end

function Device:readI2C(bank, addr)
    local lengthPtr = ffi.new("size_t[1]")
    return ffi.string(Utility.processRawPrimitiveList(Utility.checkDeviceError(lib.SoapySDRDevice_readI2C(
        self.__deviceHandle,
        bank,
        addr,
        lengthPtr),
        "char")))
end

--
-- SPI API
--

function Device:transactSPI(addr, data, numBits)
    return Utility.checkDeviceError(lib.SoapySDRDevice_transactSPI(
        self.__deviceHandle,
        addr,
        data,
        numBits))
end

--
-- UART API
--

function Device:listUARTs()
    local lengthPtr = ffi.new("size_t[1]")
    return Utility.processRawStringList(Utility.checkDeviceError(
        lib.SoapySDRDevice_listUARTs(self.__deviceHandle, lengthPtr),
        lengthPtr))
end

function Device:writeUART(which, data)
    return Utility.checkDeviceError(lib.SoapySDRDevice_writeUART(
        self.__deviceHandle,
        which,
        data))
end

function Device:readUART(which, timeoutUs)
    return Utility.processRawString(Utility.checkDeviceError(lib.SoapySDRDevice_readUART(
        self.__deviceHandle,
        which,
        timeoutUs)))
end

--
-- Native Access API
--

function Device:getNativeDeviceHandle()
    return Utility.checkDeviceError(lib.SoapySDRDevice_readGPIO(self.__deviceHandle))
end

--
-- Return both of these
--

return {enumerateDevices, Device}
