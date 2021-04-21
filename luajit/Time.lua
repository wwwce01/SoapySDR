-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")
local lib = require("SoapySDR.Lib")

local Time =
{
    ticksToTimeNs = lib.SoapySDR_ticksToTimeNs,
    timeNsToTicks = lib.SoapySDR_timeNsToTicks
}

return Time;
