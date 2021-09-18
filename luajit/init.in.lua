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

    ArgTypes =
    {
        BOOL   = 0,
        INT    = 1,
        FLOAT  = 2,
        STRING = 3
    },

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

    Format =
    {
        CF64 = "CF64",
        CF32 = "CF32",
        CS32 = "CS32",
        CU32 = "CU32",
        CS16 = "CS16",
        CU16 = "CU16",
        CS12 = "CS12",
        CU12 = "CU12",
        CS8 = "CS8",
        CU8 = "CU8",
        CS4 = "CS4",
        CU4 = "CU4",

        F64 = "F64",
        F32 = "F32",
        S32 = "S32",
        U32 = "U32",
        S16 = "S16",
        U16 = "U16",
        S8 = "S8",
        U8 = "U8",

        FormatToSize = function(format)
            return tonumber(lib.SoapySDR_formatToSize(format))
        end
    },

    StreamFlags =
    {
        END_BURST      = 2,  -- (1 << 1)
        HAS_TIME       = 4,  -- (1 << 2)
        END_ABRUPT     = 8,  -- (1 << 3)
        ONE_PACKET     = 16, -- (1 << 4)
        MORE_FRAGMENTS = 32, -- (1 << 5)
        WAIT_TRIGGER   = 64, -- (1 << 6)
    },

    enumerateDevices = enumerateDevices,

    Device = Device,
    Logger = require("SoapySDR.Logger"),
    Time = require("SoapySDR.Time")
}

-- Error out before attempting to call invalid function
local COMPILE_ABI_VERSION = "@SOAPY_SDR_ABI_VERSION@"
if SoapySDR.ABI_VERSION ~= COMPILE_ABI_VERSION then
    error(string.format(
        "Failed ABI check. SoapySDR %s. LuaJIT API %s. Rebuild the module.",
        SoapySDR.ABI_VERSION,
        COMPILE_ABI_VERSION))
end

return SoapySDR
