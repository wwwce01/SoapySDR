-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local debug = require("debug")
local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Utility = {}

local function isNativeLuaType(obj)
    local objTypeName = tostring(type(obj))

    return (objTypeName == "nil") or (objTypeName == "boolean") or
           (objTypeName == "number") or (objTypeName == "string")
end

--
-- FFI ctypes for comparison, these shouldn't be made often
--

local ffiCharPtrType = ffi.typeof("char*")
local ffiCharPtrPtrType = ffi.typeof("char**")
local ffiUnsignedIntPtrType = ffi.typeof("unsigned int*")
local ffiDoublePtrType = ffi.typeof("double*")

local ffiBoolType = ffi.typeof("bool")
local ffiIntType = ffi.typeof("int")
local ffiUnsignedIntType = ffi.typeof("unsigned int")
local ffiDoubleType = ffi.typeof("double")
local ffiSizeType = ffi.typeof("size_t")

local ffiArgInfoType = ffi.typeof("SoapySDRArgInfo")
local ffiKwargsType = ffi.typeof("SoapySDRKwargs")
local ffiRangeType = ffi.typeof("SoapySDRRange")

local ffiArgInfoPtrType = ffi.typeof("SoapySDRArgInfo*")
local ffiKwargsPtrType = ffi.typeof("SoapySDRKwargs*")
local ffiRangePtrType = ffi.typeof("SoapySDRRange*")

local function isFFIBool(obj)
    return (ffi.typeof(obj) == fiBoolType)
end

local function isFFINumeric(obj)
    local ffiType = ffi.typeof(obj)

    return (ffiType == ffiIntType) or (ffiType == ffiUnsignedIntType) or
           (ffiType == ffiDoubleType) or (ffiType == ffiSizeType)
end

local function isFFIRawString(obj)
    return (ffi.typeof(obj) == ffiCharPtrType)
end

local function isFFIRawStringList(obj)
    return (ffi.typeof(obj) == ffiCharPtrPtrType)
end

local function isFFIRawArgInfo(obj)
    return (ffi.typeof(obj) == ffiArgInfoType)
end

local function isFFIRawKwargs(obj)
    return (ffi.typeof(obj) == ffiKwargsType)
end

local function isFFIRawRange(obj)
    return (ffi.typeof(obj) == ffiRangeType)
end

local function isFFIArgInfoPtr(obj)
    return (ffi.typeof(obj) == ffiArgInfoPtrType)
end

local function isFFIKwargsPtr(obj)
    return (ffi.typeof(obj) == ffiKwargsPtrType)
end

local function isFFIRangePtr(obj)
    return (ffi.typeof(obj) == ffiRangePtrType)
end

--
-- Handling C <-> Lua types
--

local function kwargsToTable(kwargs)
    local tbl = {}
    for i = 0, tonumber(kwargs.size)-1 do
        tbl[ffi.string(kwargs.keys[i])] = ffi.string(kwargs.vals[i])
    end

    return tbl
end

local function tableToKwargs(tbl)
    kwargs = ffi.gc(ffi.new("SoapySDRKwargs"), lib.SoapySDRKwargs_clear)

    for k,v in pairs(tbl) do
        local code = lib.SoapySDRKwargs_set(kwargs, tostring(k), tostring(v))
        if code ~= 0 then
            error(lib.SoapySDR_errToStr(code))
        end
    end

    return kwargs
end


function Utility.toKwargs(arg)
    local ret = nil
    local argType = tostring(type(arg))

    if isFFIRawKwargs(arg) then return arg
    elseif argType == "table" then ret = tableToKwargs(arg)
    else
        ret = ffi.gc(lib.SoapySDRKwargs_fromString(tostring(arg)), lib.SoapySDRKwargs_clear)
    end

    return ret
end

local ffiTrue = ffi.new("bool", true)

local function processBool(bool)
    return (bool == ffiTrue)
end

local function processRawString(str)
    -- Copy to a Lua string and add garbage collection for the C string.
    return ffi.string(ffi.gc(str, lib.SoapySDR_free))
end

local function processRawKwargs(kwargs)
    local ret = kwargsToTable(kwargs)
    lib.SoapySDRKwargs_clear(kwargs)

    return ret
end

-- TODO
local function processRawArgInfo(argInfo)
    return nil
end

local function processRawPrimitiveList(list, lengthPtr, ffiTypeName)
    local len = tonumber(lengthPtr[0])

    -- Copy the data into a newly allocated array. This allows the data
    -- to be indexed as an array and properly garbage-collected. Generally,
    -- these allocations shouldn't be large enough for this to be an issue.
    local ret = ffi.new(ffiTypeName .. "[?]", len)
    ffi.copy(ret, list, ffi.sizeof(ret))
    lib.SoapySDR_free(arr)

    return ret
end

local function processRawStringList(stringList, lengthPtr)
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
local function processRawArgInfoList(argInfoList, lengthPtr)
    return nil
end

local function processRawKwargsList(kwargs, lengthPtr)
    local ret = {}
    local len = tonumber(lengthPtr[0])

    for i = 0,len-1 do
        ret[i+1] = kwargsToTable(kwargs[i])
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

-- Note: lengthPtr is only needed for lists
function Utility.processOutput(obj, lengthPtr)
    if isNativeLuaType(obj) then return obj
    elseif isFFINumeric(obj) then return tonumber(obj)
    elseif isFFIRawString(obj) then return processRawString(obj)
    elseif isFFIRawStringList(obj) then return processRawStringList(obj, lengthPtr)
    elseif isFFIBool(obj) then return processBool(obj)
    elseif isFFIRawArgInfo(obj) then return processRawArgInfo(obj)
    elseif isFFIRawKwargs(obj) then return processRawKwargs(obj)
    elseif isFFIRawRange(obj) then return obj
    elseif isFFIRawArgInfoPtr(obj) then return processRawArgInfoList(obj, lengthPtr)
    elseif isFFIRawKwargsPtr(obj) then return processRawKwargsList(obj, lengthPtr)
    elseif ifFFIRawRangePtr(obj) then return processRawPrimitiveList(obj, lengthPtr, "")
    end

    print(string.format("Warning: %s returned unhandled type %s. Returning nil.", debug.getinfo(2).name, ffi.typeof(obj)))

    return nil
end

return Utility
