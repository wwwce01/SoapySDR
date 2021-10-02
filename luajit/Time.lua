-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

---
-- Utility functions to convert time and ticks
-- @module SoapySDR.Time

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Time =
{
    ---
    -- Convert a tick count into a time in nanoseconds using the tick rate.
    -- @param ticks a integer tick count
    -- @param rate the ticks per second
    -- @return the time in nanoseconds
    ticksToTimeNs = function(ticks, rate)
        return tonumber(lib.SoapySDR_ticksToTimeNs(ticks, rate))
    end,

    ---
    -- Convert a time in nanoseconds into a tick count using the tick rate.
    -- @param timeNs time in nanoseconds
    -- @param rate the ticks per second
    -- @return the integer tick count
    timeNsToTicks = function(timeNs, rate)
        return tonumber(lib.SoapySDR_timeNsToTicks(timeNs, rate))
    end
}

return Time
