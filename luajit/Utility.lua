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
    -- This check is for functions that return an error code.
    -- Before a call into the underlying driver, this code is
    -- set to 0, so this won't pose an issue when called after
    -- functions that don't return an error code.
    Utility.checkError(lib.SoapySDRDevice_lastStatus())

    -- See if an exception was caught in the last function call.
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

local kwargsType = ffi.typeof("SoapySDRKwargs")

function Utility.toKwargs(arg)
    local ret = nil

    local argType = tostring(type(arg))
    if ffi.typeof(arg) == kwargsType then
        return arg
    elseif argType == "table" then
        ret = Utility.tableToKwargs(arg)
    else
        ret = ffi.gc(lib.SoapySDRKwargs_fromString(tostring(arg)), lib.SoapySDRKwargs_clear)
    end

    return ret
end

function Utility.processRawString(str)
    -- Copy to a Lua string and add garbage collection for the C string.
    return ffi.string(ffi.gc(str, lib.SoapySDR_free))
end

function Utility.processRawKwargs(kwargs)
    local ret = Utility.kwargsToTable(kwargs)
    lib.SoapySDRKwargs_clear(kwargs)

    return ret
end

-- TODO
function Utility.processRawArgInfo(argInfo)
    return nil
end

function Utility.processRawPrimitiveList(list, lengthPtr, ffiTypeName)
    local len = tonumber(lengthPtr[0])

    -- Copy the data into a newly allocated array. This allows the data
    -- to be indexed as an array and properly garbage-collected. Generally,
    -- these allocations shouldn't be large enough for this to be an issue.
    local ret = ffi.new(ffiTypeName .. "[?]", len)
    ffi.copy(ret, list, ffi.sizeof(ret))
    lib.SoapySDR_free(arr)

    return ret
end

function Utility.processRawStringList(stringList, lengthPtr)
    local ret = {}
    local len = tonumber(lengthPtr[0])

    -- Copy to a Lua "array" of strings and clear the C string array.
    for i = 0,len-1 do
        ret[i+1] = ffi.string(stringList[i])
    end

    lib.SoapySDRStrings_clear(ffi.new("char**[1]", {cStrs}), len)

    return ret
end

-- TODO
function Utility.processRawArgInfoList(argInfoList, lengthPtr)
    return nil
end

function Utility.processRawKwargsList(kwargs, lengthPtr)
    local ret = {}
    local len = tonumber(lengthPtr[0])

    for i = 0,len-1 do
        ret[i+1] = Utility.kwargsToTable(kwargs[i])
    end

    lib.SoapySDRKwargsList_clear(kwargs, len)

    return ret
end

function Utility.luaArrayToFFIArray(arr, ffiTypeName)
    local ret = ffi.new(ffiTypeName .. "[?]", #arr)

    for i = 0,#arr do
        ret[i] = arr[i+1]
    end

    return ret
end

return Utility
