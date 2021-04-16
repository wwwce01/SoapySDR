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
        lib.SoapySDRArgInfoList_clear(ffi.new("SoapySDRArgInfo*[1]", {argInfoList}), length)
    end

    return clearArgInfoList
end

function Utility.processRawArgInfoList(argInfoList, lengthPtr)
    return ffi.gc(streamArgsInfo, Utility.getArgInfoListGCFcn(lengthPtr[0]))
end

return Utility
