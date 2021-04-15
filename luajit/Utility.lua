-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local Utility = {}

function Utility.checkError(code)
    local ffi = require("ffi")
    local lib = require("Lib")

    if code ~= 0 then
        error(ffi.string(lib.SoapySDR_errToStr(code)))
    end
end

function Utility.checkDeviceError()
    local ffi = require("ffi")
    local lib = require("Lib")

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
    local ffi = require("ffi")
    local lib = require("Lib")

    kwargs = ffi.gc(ffi.new("SoapySDRKwargs"), lib.SoapySDRKwargs_clear)

    for k,v in pairs(table) do
        checkError(lib.SoapySDRKwargs_set(kwargs, tostring(k), tostring(v)))
    end

    return kwargs
end

return Utility
