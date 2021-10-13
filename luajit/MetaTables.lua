-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")
local Utility = require("SoapySDR.Utility")

local SoapySDRRangeMetaTable =
{
    __tostring = function(kwargs)
        return string.format("Min: %f, Max: %f, Step: %f", kwargs.minimum, kwargs.maximum, kwargs.step)
    end
}
ffi.metatype(ffi.typeof'SoapySDRRange', SoapySDRRangeMetaTable)
