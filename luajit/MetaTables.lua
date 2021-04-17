-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("Lib")
local Utility = require("Utility")

local SoapySDRArgInfoMetaTable =
{
    __tostring = function(argInfo)
        local ret = ""

        if #argInfo.units > 0 then
            ret = string.format("%s: %s %s", argInfo.name, argInfo.value, argInfo.units)
        else
            ret = string.format("%s: %s", argInfo.name, argInfo.value)
        end

        return ret
    end
}
ffi.metatype(ffi.typeof'SoapySDRArgInfo', SoapySDRArgInfoMetaTable)

local SoapySDRKwargsMetaTable =
{
    __tostring = function(kwargs)
        return ffi.gc(lib.SoapySDRKwargs_toString(kwargs), ffi.C.free)
    end
}
ffi.metatype(ffi.typeof'SoapySDRKwargs', SoapySDRKwargsMetaTable)

local SoapySDRRangeMetaTable =
{
    __tostring = function(kwargs)
        return string.format("Min: %f, Max: %f, Step: %f", kwargs.minimum, kwargs.maximum, kwargs.step)
    end
}
ffi.metatype(ffi.typeof'SoapySDRRange', SoapySDRRangeMetaTable)
