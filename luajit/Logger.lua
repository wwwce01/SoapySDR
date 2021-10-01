-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

---
-- Logger API for SoapySDR devices
-- @module SoapySDR.Logger

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Logger =
{
    --- The available priority levels for log messages.
    --
    -- The default log level threshold is INFO.
    -- Log messages with lower priorities are dropped.
    --
    -- The default threshold can be set via the
    -- SOAPY_SDR_LOG_LEVEL environment variable.
    --
    -- Set SOAPY_SDR_LOG_LEVEL to the string value:
    -- "WARNING", "ERROR", "DEBUG", etc...
    -- or set it to the equivalent integer value.
    Level =
    {
        FATAL    = lib.SOAPY_SDR_FATAL,    -- A fatal error. The application will most likely terminate. This is the highest priority.
        CRITICAL = lib.SOAPY_SDR_CRITICAL, -- A critical error. The application might not be able to continue running successfully.
        ERROR    = lib.SOAPY_SDR_ERROR,    -- An error. An operation did not complete successfully, but the application as a whole is not affected.
        WARNING  = lib.SOAPY_SDR_WARNING,  -- A warning. An operation completed with an unexpected result.
        NOTICE   = lib.SOAPY_SDR_NOTICE,   -- A notice, which is an information with just a higher priority.
        INFO     = lib.SOAPY_SDR_INFO,     -- An informational message, usually denoting the successful completion of an operation.
        DEBUG    = lib.SOAPY_SDR_DEBUG,    -- A debugging message.
        TRACE    = lib.SOAPY_SDR_TRACE,    -- A tracing message. This is the lowest priority.
        SSI      = lib.SOAPY_SDR_SSI,      -- Streaming status indicators such as "U" (underflow) and "O" (overflow).
    },

    ---
    -- Send a message to the registered logger.
    -- @param logLevel a possible logging level
    -- @param message a logger message string
    -- @see Level
    log = function(logLevel, message)
        lib.SoapySDR_log(logLevel, message)
    end,

    ---
    -- Register a new system log handler.
    -- Platforms should call this to replace the default stdio handler.
    -- @param[opt] handler A function that takes in a log level and message, or nil to restore the default handler 
    -- @see Level
    registerHandler = function(handler)
        lib.SoapySDR_registerLogHandler(handler)
    end,

    ---
    -- Set the log level threshold.
    -- Log messages with lower priority are dropped.
    -- @param logLevel a possible logging level
    -- @see Level
    setLevel = function(logLevel)
        lib.SoapySDR_setLogLevel(logLevel)
    end
}

return Logger
