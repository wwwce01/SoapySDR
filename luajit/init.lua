-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

-- Registers metatables for SoapySDR types
require("SoapySDR.MetaTables")

local enumerateDevices, Device = unpack(require("SoapySDR.Device"))

local SoapySDR =
{
    API_VERSION = ffi.string(lib.SoapySDR_getAPIVersion()),
    ABI_VERSION = ffi.string(lib.SoapySDR_getABIVersion()),
    LIB_VERSION = ffi.string(lib.SoapySDR_getLibVersion()),

    Direction =
    {
        TX = 0,
        RX = 1
    },

    Error =
    {
        TIMEOUT       = -1,
        STREAM_ERROR  = -2,
        CORRUPTION    = -3,
        OVERFLOW      = -4,
        NOT_SUPPORTED = -5,
        TIME_ERROR    = -6,
        UNDERFLOW     = -7,

        ToString = function(code)
            return ffi.string(lib.SoapySDR_errToStr(code))
        end
    },

    enumerateDevices = enumerateDevices,

    Complex = require("SoapySDR.Complex"),
    Device = Device,
    Logger = require("SoapySDR.Logger"),
    Time = require("SoapySDR.Time"),
}

return SoapySDR
