#!/usr/bin/env luajit

local SoapySDR = require("SoapySDR")

local ffi = require("ffi")

local argparse = require("argparse")
local signal = require("posix.signal")

--
--
--

local parser = argparse("SimpleSiggen")
parser:option("--args", "Device args", "")
parser:option("--rate", "Sample rate", 1e6):convert(tonumber)
parser:option("--ampl", "TX digital amplitude", 0.7):convert(tonumber)
parser:option("--tx-ant", "Optional TX antenna")
parser:option("--tx-gain", "Optional TX gain"):convert(tonumber)
parser:option("--tx-chan", "TX channel", 0):convert(tonumber)
parser:option("--freq", "Optional frequency (Hz)"):convert(tonumber)
parser:option("--tx-bw", "Optional TX filter bandwidth (Hz)", 5e6):convert(tonumber)
parser:option("--wave-freq", "Optional wave frequency (Hz)"):convert(tonumber)
parser:option("--clock-rate", "Optional clock rate (Hz)"):convert(tonumber)
parser:option("--debug", "Output debug messages", false)

local args = parser:parse()

--
--
--

-- Configure logger
local logLevel
if args.debug then logLevel = SoapySDR.Logger.Level.DEBUG
else               logLevel = SoapySDR.Logger.Level.WARNING
end
SoapySDR.Logger.setLevel(logLevel)

-- Initialize device
local sdr = SoapySDR.Device(args.args)
print("----------")
print(string.format("Device:  %s", sdr))
print(string.format("Channel: %d", args.tx_chan))

-- Set master clock rate
if args.clock_rate then
    print("----------")
    print(string.format("Setting master clock rate: %f Hz", args.clock_rate))
    sdr:setMasterClockRate(args.clock_rate)
    print(string.format("Actual:                    %f Hz", sdr:getMasterClockRate()))
end

-- Set sample rate
print("----------")
print(string.format("Setting TX sample rate: %f Hz", args.rate))
sdr:setSampleRate(SoapySDR.Direction.TX, args.tx_chan, args.rate)
print(string.format("Actual:                 %f Hz", sdr:getSampleRate(SoapySDR.Direction.TX, args.tx_chan)))

-- Set bandwidth
print("----------")
print(string.format("Setting TX bandwidth: %f Hz", args.tx_bw))
sdr:setBandwidth(SoapySDR.Direction.TX, args.tx_chan, args.tx_bw)
print(string.format("Actual:               %f Hz", sdr:getBandwidth(SoapySDR.Direction.TX, args.tx_chan)))

-- Set antenna
if args.tx_ant then
    print("----------")
    print(string.format("Setting TX antenna: %s", args.tx_ant))
    sdr:setAntenna(SoapySDR.Direction.TX, args.tx_chan, args.tx_ant)
    print(string.format("Actual:             %s", sdr:getAntenna(SoapySDR.Direction.TX, args.tx_chan)))
end

-- Set overall gain
if args.tx_gain then
    print("----------")
    print(string.format("Setting TX gain: %f dB", args.tx_gain))
    sdr:setGain(SoapySDR.Direction.TX, args.tx_chan, args.tx_gain)
    print(string.format("Actual:          %f dB", sdr:getGain(SoapySDR.Direction.TX, args.tx_chan)))
end

-- Tune frontend
if args.freq then
    print("----------")
    print(string.format("Setting TX frequency: %f dB", args.freq))
    sdr:setFrequency(SoapySDR.Direction.TX, args.tx_chan, args.freq)
    print(string.format("Actual:               %f dB", sdr:getFrequency(SoapySDR.Direction.TX, args.tx_chan)))
end

-- Initialize stream
local stream = sdr:setupStream(SoapySDR.Direction.TX, SoapySDR.Format.CF32, {args.tx_chan})
if stream == nil then
    error("Failed to set up TX stream")
end

-- Activate stream
local errorCode = sdr:activateStream(stream)
if errorCode ~= 0 then
    error("activateStream returned " .. SoapySDR.ErrorToString(errorCode))
end

-- Set up samples
local samps = ffi.new("complex float[?]", sdr:getStreamMTU(stream))
local samps2D = ffi.new("complex float*[1]", {samps})

local waveFreq = args.wave_freq or (args.rate / 10)
local phaseAcc = 0
local phaseInc = 2 * math.pi * waveFreq / args.rate

-- Run siggen until interrupted

-- Clean up
sdr:deactivateStream(stream)
sdr:closeStream(stream)
print("Done!")
