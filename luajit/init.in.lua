-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

---
-- @module SoapySDR

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

-- TODO: ArgInfoType: see ArgInfo

-- Registers metatables for SoapySDR types
require("SoapySDR.MetaTables")

local enumerateDevices, Device = unpack(require("SoapySDR.Device"))

local SoapySDR =
{
    ---
    -- The ABI version string of the SoapySDR build corresponding to this LuaJIT
    -- API installation.
    --
    -- On import, this ABI version is checked against the ABI of the currently
    -- installed SoapySDR library, and an error will be thrown if they do not match.
    BUILDTIME_ABI_VERSION = "@SOAPY_SDR_ABI_VERSION@",

    ---
    -- The ABI version string of the currently installed SoapySDR library.
    --
    -- On import, this ABI version is checked against the ABI of the LuaJIT API,
    -- and an error will be thrown if they do not match.
    ABI_VERSION = ffi.string(lib.SoapySDR_getABIVersion()),

    ---
    -- A version string corresponding to the currently installed SoapySDR library.
    -- The format of the version string is "major.minor.increment".
    API_VERSION = ffi.string(lib.SoapySDR_getAPIVersion()),

    ---
    -- The library version and build information string.
    -- The format of the version string is "major.minor.patch-buildInfo".
    -- This string is commonly used to identify the software back-end
    -- to the user for command-line utilities and graphical applications.
    LIB_VERSION = ffi.string(lib.SoapySDR_getLibVersion()),

    ---
    -- An enum used by SoapySDR.ArgInfo to correspond to different sensor/setting types.
    --
    -- SoapySDR.Device sensor and setting getter functions use this field to determine what
    -- type to return.
    --
    -- @field BOOL boolean
    -- @field INT integer
    -- @field FLOAT float
    -- @field STRING string
    -- @see SoapySDR.Device
    ArgInfoType =
    {
        BOOL   = 0,
        INT    = 1,
        FLOAT  = 2,
        STRING = 3
    },

    ---
    -- An enum used by SoapySDR.Device functions to specify transmit or receive.
    --
    -- @field TX transmit
    -- @field RX receive
    -- @see SoapySDR.Device
    Direction =
    {
        TX = 0,
        RX = 1
    },

    ---
    -- Error codes returned by SoapySDR.Device's streaming functions.
    --
    -- @field TIMEOUT returned when read has a timeout
    -- @field STREAM_ERROR returned for non-specific stream errors.
    -- @field CORRUPTION returned when read has data corruption. For example, the driver saw a malformed packet.
    -- @field OVERFLOW returned when read has an overflow condition. For example, and internal buffer has filled.
    -- @field NOT_SUPPORTED Returned when a requested operation or flag setting is not supported by the underlying implementation.
    -- @field TIME_ERROR Returned when a the device encountered a stream time which was expired (late) or too early to process.
    -- @field UNDERFLOW Returned when write caused an underflow condition. For example, a continuous stream was interrupted.
    -- @see SoapySDR.Device
    -- @see Error.ToString
    Error =
    {
        TIMEOUT       = -1,
        STREAM_ERROR  = -2,
        CORRUPTION    = -3,
        OVERFLOW      = -4,
        NOT_SUPPORTED = -5,
        TIME_ERROR    = -6,
        UNDERFLOW     = -7,
    },

    ---
    -- String constants representing different data types for streaming.
    --
    -- @field CF64 LuaJIT type "complex"
    -- @field CF32 LuaJIT type "complex float"
    -- @field CS32 complex int32_t (no native LuaJIT type)
    -- @field CU32 complex uint32_t (no native LuaJIT type)
    -- @field CS16 complex int16_t (no native LuaJIT type)
    -- @field CU16 complex uint16_t (no native LuaJIT type)
    -- @field CS12 complex int12_t (usually over-the-wire)
    -- @field CU12 complex uint12_t (usually over-the-wire)
    -- @field CS8 complex int8_t (no native LuaJIT type)
    -- @field CU8 complex uint8_t (no native LuaJIT type)
    -- @field CS4 complex int4_t (usually over-the-wire)
    -- @field CU4 complex uint4_t (usually over-the-wire)
    -- @field F64 double
    -- @field F32 float
    -- @field S32 int32_t
    -- @field U32 uint32_t
    -- @field S16 int16_t
    -- @field U16 uint16_t
    -- @field S8 int8_t
    -- @field U8 uint8_t
    -- @see SoapySDR.Device
    -- @see Format.ToSize
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
    },

    ---
    -- Flags passed into SoapySDR.Device streaming functions.
    --
    -- @field END_BURST
    -- Indicate end of burst for transmit or receive.
    -- For write, end of burst if set by the caller.
    -- For read, end of burst is set by the driver.
    -- @field HAS_TIME
    -- Indicates that the time stamp is valid.
    -- For write, the caller must set has time when timeNs is provided.
    -- For read, the driver sets has time when timeNs is provided.
    -- @field END_ABRUPT
    -- Indicates that stream terminated prematurely.
    -- This is the flag version of an overflow error
    -- that indicates an overflow with the end samples.
    -- @field ONE_PACKET
    -- Indicates transmit or receive only a single packet.
    -- Applicable when the driver fragments samples into packets.
    -- For write, the user sets this flag to only send a single packet.
    -- For read, the user sets this flag to only receive a single packet.
    -- @field MORE_FRAGMENTS
    -- Indicate that this read call and the next results in a fragment.
    -- Used when the implementation has an underlying packet interface.
    -- The caller can use this indicator and the ONE_PACKET flag
    -- on subsequent read stream calls to re-align with packet boundaries.
    -- @field WAIT_TRIGGER
    -- Indicate that the stream should wait for an external trigger event.
    -- This flag might be used with the flags argument in any of the
    -- stream API calls. The trigger implementation is hardware-specific.
    --
    -- @usage
    -- local flags = bit.bor(SoapySDR.StreamFlags.HAS_TIME, SoapySDR.StreamFlags.END_BURST)
    -- @see SoapySDR.Device
    StreamFlags =
    {
        END_BURST      = 2,
        HAS_TIME       = 4,
        END_ABRUPT     = 8,
        ONE_PACKET     = 16,
        MORE_FRAGMENTS = 32,
        WAIT_TRIGGER   = 64,
    },

    --- Enumerate a list of available devices on the system.
    -- @function enumerateDevices
    -- @param[opt] args device construction key/value argument filters
    --
    -- If omitted, no filter will be applied, and all accessible devices
    -- will be included.
    --
    -- If given, this parameter can either be a comma-delimited string
    -- (e.g. "type=rtlsdr,serial=12345") or a table (e.g. {type: "rtlsdr",
    -- serial: 12345}).
    enumerateDevices = enumerateDevices,

    Device = Device,
    Logger = require("SoapySDR.Logger"),
    Time = require("SoapySDR.Time")
}

---
-- Return a string corresponding to the given error code
-- @function Error.ToString
-- @param code error code
-- @see Error
--
-- @return A string representation of the error code, or "UNKNOWN" for invalid input
function SoapySDR.Error.ToString(code)
    return ffi.string(lib.SoapySDR_errToStr(code))
end

---
-- Return the size of the data type corresponding to the given format string.
-- @function Format.ToSize
-- @param format stream format
-- @see Format
--
-- @return The size of the given format string's data type
function SoapySDR.Format.ToSize(format)
    return tonumber(lib.SoapySDR_formatToSize(format))
end

-- Error out before attempting to call invalid function
if SoapySDR.ABI_VERSION ~= SoapySDR.BUILDTIME_ABI_VERSION then
    error(string.format(
        "Failed ABI check. SoapySDR %s. LuaJIT API %s. Rebuild the module.",
        SoapySDR.ABI_VERSION,
        BUILDTIME_ABI_VERSION))
end

return SoapySDR
