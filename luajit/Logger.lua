-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Logger =
{
    Level =
    {
        FATAL    = lib.SOAPY_SDR_FATAL,
        CRITICAL = lib.SOAPY_SDR_CRITICAL,
        ERROR    = lib.SOAPY_SDR_ERROR,
        WARNING  = lib.SOAPY_SDR_WARNING,
        NOTICE   = lib.SOAPY_SDR_NOTICE,
        INFO     = lib.SOAPY_SDR_INFO,
        DEBUG    = lib.SOAPY_SDR_DEBUG,
        TRACE    = lib.SOAPY_SDR_TRACE,
        SSI      = lib.SOAPY_SDR_SSI
    },

    log = function(logLevel, message)
        lib.SoapySDR_log(logLevel, message)
    end,

    registerHandler = function(handler)
        lib.SoapySDR_registerLogHandler(handler)
    end,

    setLevel = function(level)
        lib.SoapySDR_setLogLevel(level)
    end
}

return Logger;
