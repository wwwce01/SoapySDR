-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Time =
{
    ticksToTimeNs = function(ticks, rate)
        return tonumber(lib.SoapySDR_ticksToTimeNs(ticks, rate))
    end,

    timeNsToTicks = function(timeNs, rate)
        return tonumber(lib.SoapySDR_timeNsToTicks(timeNs, rate))
    end
}

return Time;
