-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

-- Registers metatables for SoapySDR types
require("SoapySDR.MetaTables")

local enumerateDevices, Device = require("SoapySDR.Device")

local SoapySDR =
{
    API_VERSION = ffi.string(lib.SoapySDR_getAPIVersion()),
    ABI_VERSION = ffi.string(lib.SoapySDR_getABIVersion()),
    LIB_VERSION = ffi.string(lib.SoapySDR_getLibVersion()),

    enumerateDevices = enumerateDevices,

    Complex = require("SoapySDR.Complex"),
    Device = Device
}

return SoapySDR
