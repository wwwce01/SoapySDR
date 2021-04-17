-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("Lib")

local enumerateDevices, Device = require("Device")

local SoapySDR =
{
    API_VERSION = ffi.string(lib.SoapySDR_getAPIVersion()),
    ABI_VERSION = ffi.string(lib.SoapySDR_getABIVersion()),
    LIB_VERSION = ffi.string(lib.SoapySDR_getLibVersion()),

    enumerateDevices = enumerateDevices,

    Complex = require("Complex"),
    Device = Device
}

return SoapySDR
