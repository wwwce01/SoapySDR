-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

---
-- @module SoapySDR

local class = require("SoapySDR.Class")

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")
local Utility = require("SoapySDR.Utility")

-- TODO: code formatting consistency

--
-- Device-specific utility
--

-- Note: lengthPtr is only needed for lists
local function processDeviceOutput(ret, lengthPtr)
    -- See if an exception was caught in the last function call.
    local lastError = ffi.string(lib.SoapySDRDevice_lastError())
    if #lastError > 0 then
        error(lastError)
    end

    return Utility.processOutput(ret, lengthPtr)
end

local function processDeviceSetting(settingRet, settingName, allSettingInfo)
    local settingStr = processDeviceOutput(settingRet)
    local nativeSetting = ""

    for i=1,#allSettingInfo do
        local settingInfo = allSettingInfo[i]
        if settingInfo["name"] == settingName then
            nativeSetting = Utility.stringToSoapySetting(settingStr, settingInfo["argType"])
            break
        end
    end

    return nativeSetting
end

--
-- Device enumeration
--

--- Enumerate a list of available devices on the system.
-- @function enumerateDevices
-- @param args device construction key/value argument filters
--
-- This parameter can either be a comma-delimited string (e.g. "type=rtlsdr,serial=12345") or a
-- table (e.g. {type: "rtlsdr", serial: 12345}).
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

--- Abstraction for an SDR transceiver device.
-- @type Device
-- @todo how to do constructor?
Device = class(
    function(dev,param)
        -- No parameter means no args
        param = param or ""

        -- Abstract away different C constructor functions
        local paramType = tostring(type(param))
        if paramType == "string" then
            dev.__deviceHandle = ffi.gc(
                lib.SoapySDRDevice_makeStrArgs(param),
                lib.SoapySDRDevice_unmake)
        else
            dev.__deviceHandle = ffi.gc(
                lib.SoapySDRDevice_make(Utility.toKwargs(param)),
                lib.SoapySDRDevice_unmake)
        end

        if dev.__deviceHandle == nil then
            error("Invalid device args")
        end
    end)

--
-- Identification API
--

--- Return a string representation of the device.
-- Ex. "uhd:B210"
-- @see Device:getDriverKey
-- @see Device:getHardwareKey
function Device:__tostring()
    return string.format("%s:%s", self:getDriverKey(), self:getHardwareKey())
end

---
-- A key that uniquely identifies the device driver.
-- This key identifies the underlying implementation.
-- Several variants of a product may share a driver.
function Device:getDriverKey()
    return processDeviceOutput(lib.SoapySDRDevice_getDriverKey(self.__deviceHandle))
end

---
-- A key that uniquely identifies the hardware.
-- This key should be meaningful to the user
-- to optimize for the underlying hardware.
function Device:getHardwareKey()
    return processDeviceOutput(lib.SoapySDRDevice_getHardwareKey(self.__deviceHandle))
end

---
-- Query a dictionary of available device information.
-- This dictionary can any number of values like
-- vendor name, product name, revisions, serials...
--
-- This data is returned in a Lua table and can be iterated
-- with Lua's pairs(tbl) function.
function Device:getHardwareInfo()
    return processDeviceOutput(lib.SoapySDRDevice_getHardwareInfo(self.__deviceHandle))
end

--
-- Channels API
--

---
-- Set the frontend mapping of available DSP units to RF frontends.
-- This mapping controls channel mapping and channel availability.
-- @param direction the channel direction (RX or TX)
-- @see SoapySDR.Direction
-- @param mapping a vendor-specific mapping string
function Device:setFrontendMapping(direction, mapping)
    return processDeviceOutput(lib.SoapySDRDevice_setFrontendMapping(
        self.__deviceHandle,
        direction,
        Utility.toString(mapping)))
end

---
-- Get the mapping configuration string.
-- @param direction the channel direction (RX or TX)
-- @see SoapySDR.Direction
-- @return the vendor-specific mapping string
function Device:getFrontendMapping(direction)
    return processDeviceOutput(lib.SoapySDRDevice_getFrontendMapping(
        self.__deviceHandle,
        direction))
end

---
-- Get a number of channels given the streaming direction
-- @param direction the channel direction (RX or TX)
-- @see SoapySDR.Direction
function Device:getNumChannels(direction)
    return processDeviceOutput(lib.SoapySDRDevice_getNumChannels(
        self.__deviceHandle,
        direction))
end

---
-- Query a dictionary of available channel information.
-- This dictionary can any number of values like
-- decoder type, version, available functions...
--
-- This data is returned in a Lua table and can be iterated
-- with Lua's pairs(tbl) function.
-- @param direction the channel direction (RX or TX)
-- @see SoapySDR.Direction
-- @param channel an available channel on the device
-- @return channel information
function Device:getChannelInfo(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getChannelInfo(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:getFullDuplex(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getFullDuplex(
        self.__deviceHandle,
        direction,
        channel))
end

--- Stream API
-- @section stream

function Device:getStreamFormats(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getStreamFormats(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:getNativeStreamFormat(direction, channel)
    local fullScalePtr = ffi.new("double[1]")

    local format = processDeviceOutput(
        lib.SoapySDRDevice_getNativeStreamFormat(
            self.__deviceHandle,
            direction,
            channel,
            fullScalePtr),
        fullScalePtr)

    return {format, tonumber(fullScalePtr[0])}
end

function Device:getStreamArgsInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getStreamArgsInfo(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:setupStream(direction, format, channels, args)
    local ret = processDeviceOutput(lib.SoapySDRDevice_setupStream(
        self.__deviceHandle,
        direction,
        Utility.toString(format),
        Utility.luaArrayToFFIArray(channels, "size_t"),
        #channels,
        Utility.toKwargs(args)))

    return ret
end

function Device:closeStream(stream)
    return processDeviceOutput(lib.SoapySDRDevice_closeStream(
        self.__deviceHandle,
        stream))
end

function Device:getStreamMTU(stream)
    return processDeviceOutput(lib.SoapySDRDevice_getStreamMTU(
        self.__deviceHandle,
        stream))
end

function Device:activateStream(stream, flags, timeNs, numElems)
    -- To allow for optional parameters
    flags = flags or 0
    timeNs = timeNs or 0
    numElems = numElems or 0

    return processDeviceOutput(lib.SoapySDRDevice_activateStream(
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

    return processDeviceOutput(lib.SoapySDRDevice_deactivateStream(
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

    local ret = processDeviceOutput(lib.SoapySDRDevice_readStream(
        self.__deviceHandle,
        stream,
        ffi.cast("void* const*", buffs),
        numElems,
        flagsPtr,
        timeNsPtr,
        timeoutUs))

    return {ret, tonumber(flagsPtr[0]), tonumber(timeNsPtr[0])}
end

function Device:writeStream(stream, buffs, numElems, flagsIn, timeNs, timeoutUs)
    -- To allow for optional parameters
    flagsIn = flagsIn or 0
    timeNs = timeNs or 0
    timeoutUs = timeoutUs or 100000

    local flagsPtr = ffi.new("int[1]", {flagsIn})

    local ret = processDeviceOutput(lib.SoapySDRDevice_writeStream(
        self.__deviceHandle,
        stream,
        ffi.cast("const void* const*", buffs),
        numElems,
        flagsPtr,
        timeNs,
        timeoutUs))

    return {ret, tonumber(flagsPtr[0])}
end

function Device:readStreamStatus(stream, timeoutUs)
    -- To allow for optional parameters
    timeoutUs = timeoutUs or 100000

    local chanMaskPtr = ffi.new("size_t[1]")
    local flagsPtr = ffi.new("int[1]")
    local timeNsPtr = ffi.new("long long[1]")

    local ret = processDeviceOutput(lib.SoapySDRDevice_readStreamStatus(
        self.__deviceHandle,
        stream,
        chanMaskPtr,
        flagsPtr,
        timeNsPtr,
        timeoutUs))

    return {ret, tonumber(chanMaskPtr[0]), tonumber(flagsPtr[0]), tonumber(timeNsPtr[0])}
end

--- Antenna API
-- @section antenna

function Device:listAntennas(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listAntennas(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:setAntenna(direction, channel, name)
    return processDeviceOutput(lib.SoapySDRDevice_setAntenna(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(name)))
end

function Device:getAntenna(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getAntenna(
        self.__deviceHandle,
        direction,
        channel))
end

--- Frontend corrections API
-- @section frontend_corrections

function Device:hasDCOffsetMode(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_hasDCOffsetMode(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setDCOffsetMode(direction, channel, automatic)
    return processDeviceOutput(lib.SoapySDRDevice_setDCOffsetMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
end

function Device:getDCOffsetMode(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getDCOffsetMode(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:hasDCOffset(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_hasDCOffset(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setDCOffset(direction, channel, offset)
    local complexOffset = Utility.toComplex(offset)

    return processDeviceOutput(lib.SoapySDRDevice_setDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        complexOffset.re,
        complexOffset.im))
end

function Device:getDCOffset(direction, channel)
    local iPtr = ffi.new("double[1]")
    local qPtr = ffi.new("double[1]")

    processDeviceOutput(lib.SoapySDRDevice_getDCOffset(
        self.__deviceHandle,
        direction,
        channel,
        iPtr,
        qPtr))

    return ffi.new("complex", iPtr[0], qPtr[0])
end

function Device:hasIQBalance(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_hasIQBalance(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setIQBalance(direction, channel, balance)
    local complexBalance = Utility.toComplex(balance)

    return processDeviceOutput(lib.SoapySDRDevice_setIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        complexBalance.re,
        complexBalance.im))
end

function Device:getIQBalance(direction, channel)
    local iPtr = ffi.new("double[1]")
    local qPtr = ffi.new("double[1]")

    processDeviceOutput(lib.SoapySDRDevice_getIQBalance(
        self.__deviceHandle,
        direction,
        channel,
        iPtr,
        qPtr))

    return ffi.new("complex", iPtr[0], qPtr[0])
end

function Device:hasIQBalanceMode(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_hasIQBalanceMode(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setIQBalanceMode(direction, channel, automatic)
    return processDeviceOutput(lib.SoapySDRDevice_setIQBalanceMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
end

function Device:getIQBalanceMode(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getIQBalanceMode(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:hasFrequencyCorrection(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_hasFrequencyCorrection(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setFrequencyCorrection(direction, channel, value)
    return processDeviceOutput(lib.SoapySDRDevice_setFrequencyCorrection(
        self.__deviceHandle,
        direction,
        channel,
        value))
end

function Device:getFrequencyCorrection(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getFrequencyCorrection(
        self.__deviceHandle,
        direction,
        channel))
end

--- Gain API
-- @section gain

function Device:listGains(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listGains(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:hasGainMode(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_hasGainMode(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setGainMode(direction, channel, automatic)
    return processDeviceOutput(lib.SoapySDRDevice_setGainMode(
        self.__deviceHandle,
        direction,
        channel,
        automatic))
end

function Device:getGainMode(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getGainMode(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:setGain(direction, channel, value)
    return processDeviceOutput(lib.SoapySDRDevice_setGain(
        self.__deviceHandle,
        direction,
        channel,
        value))
end

function Device:setGainElement(direction, channel, name, value)
    return processDeviceOutput(lib.SoapySDRDevice_setGainElement(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(name),
        value))
end

function Device:getGain(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getGain(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:getGainElement(direction, channel, name)
    return processDeviceOutput(lib.SoapySDRDevice_getGainElement(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(name)))
end

function Device:getGainRange(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getGainRange(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:getGainElementRange(direction, channel, name)
    return processDeviceOutput(lib.SoapySDRDevice_getGainElementRange(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(name)))
end

--- Frequency API
-- @section frequency

function Device:setFrequency(direction, channel, frequency, args)
    return processDeviceOutput(lib.SoapySDRDevice_setFrequency(
        self.__deviceHandle,
        direction,
        channel,
        frequency,
        Utility.toKwargs(args)))
end

function Device:setFrequencyComponent(direction, channel, name, frequency, args)
    return processDeviceOutput(lib.SoapySDRDevice_setFrequencyComponent(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(name),
        frequency,
        Utility.toKwargs(args)))
end

function Device:getFrequency(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getFrequency(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:getFrequencyComponent(direction, channel, name)
    return processDeviceOutput(lib.SoapySDRDevice_getFrequencyComponent(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(name)))
end

function Device:getFrequencyRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getFrequencyRange(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:getFrequencyRangeComponent(direction, channel, name)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getFrequencyRangeComponent(
            self.__deviceHandle,
            direction,
            channel,
            Utility.toString(name),
            lengthPtr),
        lengthPtr)
end

function Device:getFrequencyArgsInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getFrequencyArgsInfo(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

--- Sample Rate API
-- @section sample_rate

function Device:setSampleRate(direction, channel, rate)
    return processDeviceOutput(lib.SoapySDRDevice_setSampleRate(
        self.__deviceHandle,
        direction,
        channel,
        rate))
end

function Device:getSampleRate(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getSampleRate(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:getSampleRateRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getSampleRateRange(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

--- Bandwidth API
-- @section bandwidth

function Device:setBandwidth(direction, channel, bw)
    return processDeviceOutput(lib.SoapySDRDevice_setBandwidth(
        self.__deviceHandle,
        direction,
        channel,
        bw))
end

function Device:getBandwidth(direction, channel)
    return processDeviceOutput(lib.SoapySDRDevice_getBandwidth(
        self.__deviceHandle,
        direction,
        channel))
end

function Device:getBandwidthRange(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getBandwidthRange(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

--- Clocking API
-- @section clocking

function Device:setMasterClockRate(rate)
    return processDeviceOutput(lib.SoapySDRDevice_setMasterClockRate(
        self.__deviceHandle,
        rate))
end

function Device:getMasterClockRate()
    return processDeviceOutput(lib.SoapySDRDevice_getMasterClockRate(self.__deviceHandle))
end

function Device:getMasterClockRates()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getMasterClockRates(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:setReferenceClockRate(rate)
    return processDeviceOutput(lib.SoapySDRDevice_setReferenceClockRate(
        self.__deviceHandle,
        rate))
end

function Device:getReferenceClockRate()
    return processDeviceOutput(lib.SoapySDRDevice_getReferenceClockRate(self.__deviceHandle))
end

function Device:getReferenceClockRates()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getReferenceClockRates(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:listClockSources()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listClockSources(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:setClockSource(source)
    return processDeviceOutput(lib.SoapySDRDevice_setClockSource(
        self.__deviceHandle,
        Utility.toString(source)))
end

function Device:getClockSource()
    return processDeviceOutput(lib.SoapySDRDevice_getClockSource(self.__deviceHandle))
end

--- Time API
-- @section time

function Device:listTimeSources()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listTimeSources(
            self.__deviceHandle,
            lengthPtr),
        lengthPtr)
end

function Device:setTimeSource(source)
    return processDeviceOutput(lib.SoapySDRDevice_setTimeSource(
        self.__deviceHandle,
        Utility.toString(source)))
end

function Device:getTimeSource()
    return processDeviceOutput(lib.SoapySDRDevice_getTimeSource(self.__deviceHandle))
end

function Device:hasHardwareTime(what)
    return processDeviceOutput(lib.SoapySDRDevice_hasHardwareTime(
        self.__deviceHandle,
        Utility.toString(what)))
end

function Device:getHardwareTime(what)
    return processDeviceOutput(lib.SoapySDRDevice_getHardwareTime(
        self.__deviceHandle,
        Utility.toString(what)))
end

function Device:setHardwareTime(time, what)
    return processDeviceOutput(lib.SoapySDRDevice_setHardwareTime(
        self.__deviceHandle,
        time,
        Utility.toString(what)))
end

--- Sensor API
-- @section sensor

function Device:listSensors()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listSensors(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:getSensorInfo(key)
    return processDeviceOutput(
        lib.SoapySDRDevice_getSensorInfo(
            self.__deviceHandle,
            Utility.toString(key)))
end

function Device:readSensor(key)
    return processDeviceOutput(
        lib.SoapySDRDevice_readSensor(
            self.__deviceHandle,
            Utility.toString(key)))
end

function Device:listChannelSensors(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listChannelSensors(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:getChannelSensorInfo(direction, channel, key)
    return processDeviceOutput(lib.SoapySDRDevice_getChannelSensorInfo(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(key)))
end

function Device:readChannelSensor(direction, channel, key)
    return processDeviceOutput(lib.SoapySDRDevice_readChannelSensor(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(key)))
end

--- Register API
-- @section register

function Device:listRegisterInterfaces()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listRegisterInterfaces(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:writeRegister(name, addr, value)
    return processDeviceOutput(lib.SoapySDRDevice_writeRegister(
        self.__deviceHandle,
        Utility.toString(name),
        addr,
        value))
end

function Device:readRegister(name, addr)
    return processDeviceOutput(lib.SoapySDRDevice_readRegister(
        self.__deviceHandle,
        Utility.toString(name),
        addr))
end

function Device:writeRegisters(name, addr, values)
    return processDeviceOutput(lib.SoapySDRDevice_writeRegisters(
        self.__deviceHandle,
        Utility.toString(name),
        addr,
        ffi.cast("unsigned*", Utility.luaArrayToFFIArray(values, "unsigned")),
        #values))
end

function Device:readRegisters(name, addr, len)
    local lengthPtr = ffi.new("size_t[1]", len)
    return processDeviceOutput(
        lib.SoapySDRDevice_readRegisters(
            self.__deviceHandle,
            Utility.toString(name),
            addr,
            lengthPtr),
        lengthPtr)
end

--- Settings API
-- @section setting

function Device:getSettingInfo()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getSettingInfo(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:writeSetting(key, value)
    return processDeviceOutput(lib.SoapySDRDevice_writeSetting(
        self.__deviceHandle,
        Utility.toString(key),
        Utility.soapySettingToString(value)))
end

function Device:readSetting(key)
    local keyStr = Utility.toString(key)

    return processDeviceSetting(
        lib.SoapySDRDevice_readSetting(
            self.__deviceHandle,
            keyStr),
        keyStr,
        self:getSettingInfo())
end

function Device:getChannelSettingInfo(direction, channel)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_getChannelSettingInfo(
            self.__deviceHandle,
            direction,
            channel,
            lengthPtr),
        lengthPtr)
end

function Device:writeChannelSetting(direction, channel, key, value)
    return processDeviceOutput(lib.SoapySDRDevice_writeChannelSetting(
        self.__deviceHandle,
        direction,
        channel,
        Utility.toString(key),
        Utility.soapySettingToString(value)))
end

function Device:readChannelSetting(direction, channel, key)
    local keyStr = Utility.toString(key)

    return processDeviceSetting(
        lib.SoapySDRDevice_readChannelSetting(
            self.__deviceHandle,
            direction,
            channel,
            keyStr),
        keyStr,
        self:getChannelSettingInfo(direction, channel))
end

--- GPIO API
-- @section gpio

function Device:listGPIOBanks()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listGPIOBanks(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:writeGPIO(bank, value)
    return processDeviceOutput(lib.SoapySDRDevice_writeGPIO(
        self.__deviceHandle,
        Utility.toString(bank),
        value))
end

function Device:writeGPIOMasked(bank, value, mask)
    return processDeviceOutput(lib.SoapySDRDevice_writeGPIOMasked(
        self.__deviceHandle,
        Utility.toString(bank),
        value,
        mask))
end

function Device:readGPIO(bank)
    return processDeviceOutput(lib.SoapySDRDevice_readGPIO(
        self.__deviceHandle,
        Utility.toString(bank)))
end

function Device:writeGPIODir(bank, dir)
    return processDeviceOutput(lib.SoapySDRDevice_writeGPIODir(
        self.__deviceHandle,
        Utility.toString(bank),
        dir))
end

function Device:writeGPIODirMasked(bank, dir, mask)
    return processDeviceOutput(lib.SoapySDRDevice_writeGPIODirMasked(
        self.__deviceHandle,
        Utility.toString(bank),
        dir,
        mask))
end

function Device:readGPIODir(bank)
    return processDeviceOutput(lib.SoapySDRDevice_readGPIODir(
        self.__deviceHandle,
        Utility.toString(bank)))
end

--- I2C API
-- @section i2c

function Device:writeI2C(addr, data)
    local convertedData = Utility.toString(data)

    return processDeviceOutput(lib.SoapySDRDevice_writeI2C(
        self.__deviceHandle,
        addr,
        convertedData,
        #convertedData))
end

function Device:readI2C(bank, addr)
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(lib.SoapySDRDevice_readI2C(
        self.__deviceHandle,
        addr,
        lengthPtr))
end

--- SPI API
-- @section spi

function Device:transactSPI(addr, data, numBits)
    return processDeviceOutput(lib.SoapySDRDevice_transactSPI(
        self.__deviceHandle,
        addr,
        data,
        numBits))
end

--- UART API
-- @section uart

function Device:listUARTs()
    local lengthPtr = ffi.new("size_t[1]")
    return processDeviceOutput(
        lib.SoapySDRDevice_listUARTs(self.__deviceHandle, lengthPtr),
        lengthPtr)
end

function Device:writeUART(which, data)
    return lib.SoapySDRDevice_writeUART(
        self.__deviceHandle,
        Utility.toString(which),
        data)
end

function Device:readUART(which, timeoutUs)
    -- To allow for optional parameter
    timeoutUs = timeoutUs or 100000

    return processDeviceOutput(lib.SoapySDRDevice_readUART(
        self.__deviceHandle,
        Utility.toString(which),
        timeoutUs))
end

return {enumerateDevices, Device}
