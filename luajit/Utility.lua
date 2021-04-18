-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Utility = {}

--
-- Error checking
--

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

--
-- Handling C <-> Lua types
--

function Utility.kwargsToTable(kwargs)
    local tbl = {}
    for i = 0, tonumber(kwargs.size)-1 do
        tbl[ffi.string(kwargs.keys[i])] = ffi.string(kwargs.vals[i])
    end

    return tbl
end

function Utility.tableToKwargs(tbl)
    kwargs = ffi.gc(ffi.new("SoapySDRKwargs"), lib.SoapySDRKwargs_clear)

    for k,v in pairs(tbl) do
        Utility.checkError(lib.SoapySDRKwargs_set(kwargs, tostring(k), tostring(v)))
    end

    return kwargs
end

function Utility.processRawString(str)
    return ffi.string(ffi.gc(str, lib.SoapySDR_free))
end

function Utility.processRawKwargs(kwargs)
    local ret = Utility.kwargsToTable(kwargs)
    lib.SoapySDRKwargs_clear(kwargs)

    return ret
end

function Utility.processRawPrimitiveList(rangeList, lengthPtr)
    local arr = {}
    local len = tonumber(lengthPtr[0])

    for i = 0,len-1 do
        arr[i+1] = rangeList[i]
    end

    lib.SoapySDR_free(rangeList)

    return arr
end

function Utility.processRawStringList(stringList, lengthPtr)
    local arr = {}
    local len = tonumber(lengthPtr[0])

    for i = 0,len-1 do
        arr[i+1] = ffi.string(stringList[i])
    end

    lib.SoapySDRStrings_clear(ffi.new("char**[1]", {cStrs}), len)

    return arr
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

function Utility.processRawKwargsList(kwargs, lengthPtr)
    local arr = {}
    local len = tonumber(lengthPtr[0])

    for i = 0,len-1 do
        arr[i+1] = Utility.kwargsToTable(kwargs[i])
    end

    lib.SoapySDRKwargsList_clear(kwargs, len)

    return arr
end

return Utility
