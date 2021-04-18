-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Time = {}

function Time.ticksToTimeNs(ticks, rate)
    return lib.SoapySDR_ticksToTimeNs(ticks, rate)
end

function Time.timeNsToTicks(timeNs, rate)
    return lib.SoapySDR_timeNsToTicks(timeNs, rate)
end

return Time;
