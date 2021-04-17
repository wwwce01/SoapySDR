-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("Lib")

local Utility = {}

function Utility.checkError(code)
    if code ~= 0 then
        error(ffi.string(lib.SoapySDR_errToStr(code)))
    end
end

function Utility.checkDeviceError()
    Utility.checkError(lib.SoapySDRDevice_lastStatus())

    local lastError = ffi.string(lib.SoapySDRDevice_lastError())
    if #lastError > 0 then
        error(lastError)
    end
end

function Utility.rawCharStringsToList(cStrs, numStrings)
    local stringList = {}
    for i = 0,(numStrings-1) do
        stringList[i+1] = ffi.string(cStrs[i])
    end

    return stringList
end

function Utility.tableToKwargs(table)
    kwargs = ffi.gc(ffi.new("SoapySDRKwargs"), lib.SoapySDRKwargs_clear)

    for k,v in pairs(table) do
        checkError(lib.SoapySDRKwargs_set(kwargs, tostring(k), tostring(v)))
    end

    return kwargs
end

function Utility.getStringsGCFcn(numStrs)
    local function clearStrings(cStrs)
        lib.SoapySDRStrings_clear(ffi.new("char**[1]", {cStrs}), numStrs)
    end

    return clearStrings
end

function Utility.processRawStringList(stringList, lengthPtr)
    return ffi.gc(stringList, Utility.getStringsGCFcn(lengthPtr[0]))
end

function Utility.getArgInfoListGCFcn(length)
    local function clearArgInfoList(argInfoList)
        lib.SoapySDRArgInfoList_clear(argInfoList, length)
    end

    return clearArgInfoList
end

function Utility.processRawArgInfoList(argInfoList, lengthPtr)
    return ffi.gc(streamArgsInfo, Utility.getArgInfoListGCFcn(lengthPtr[0]))
end

function Utility.getKwargsListGCFcn(length)
    local function clearKwargsList(kwargs)
        lib.SoapySDRKwargsList_clear(kwargs, length)
    end

    return clearKwargsList
end

function Utility.processRawKwargsList(kwargs, lengthPtr)
    local freeFcn = function(kwargs)
        lib.SoapySDRKwargs_clear(ffi.new("SoapySDRKwargs*[1]", {kwargs}))
    end

    -- Convert to an array so we can index the array. This new object
    -- takes ownership of the pointers in each member.
    local len = tonumber(lengthPtr[0])
    local arrTypeName = "SoapySDRKwargs[" .. tostring(len) .. "]"
    local arrType = ffi.typeof(arrTypeName)
    local kwargsArr = ffi.new(arrType)
    for i=0,len-1 do
        kwargsArr[i] = ffi.gc(kwargs[i], freeFcn)
    end

    -- Free the outer C array.
    lib.SoapySDR_free(kwargs)

    return kwargsArr
end

function Utility.getRangeListGCFcn(length)
    local function clearRangeList(rangeList)
        lib.SoapySDRRangeList_clear(rangeList, length)
    end

    return clearRangeList
end

function Utility.processRawRangeList(rangeList, lengthPtr)
    return ffi.gc(rangeList, Utility.getRangeListGCFcn(lengthPtr[0]))
end

return Utility
