// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Collections.Generic;
using System.Linq;

// TODO: reorder for consistency, not to match Device.hpp

namespace SoapySDR
{    
    public class Device
    {
        private DeviceInternal device = null;

        internal Device(DeviceInternal deviceInternal) => device = deviceInternal;

        public Device(string args) => device = new DeviceInternal(args);

        public Device(IDictionary<string, string> args) => device = new DeviceInternal(Utility.AnyMapToKwargs(args));

        public string DriverKey => device.GetDriverKey();

        public string HardwareKey => device.GetHardwareKey();

        public Dictionary<string, string> HardwareInfo => device.GetHardwareInfo().ToDictionary(entry => entry.Key, entry => entry.Value);

        public void SetFrontendMapping(Direction direction, string mapping) => device.SetFrontendMapping(direction, mapping);

        public string GetFrontendMapping(Direction direction) => device.GetFrontendMapping(direction);

        public uint GetNumChannels(Direction direction) => device.GetNumChannels(direction);

        public Dictionary<string, string> GetChannelInfo(Direction direction, uint channel) => device.GetChannelInfo(direction, channel).ToDictionary(entry => entry.Key, entry => entry.Value);

        public bool GetFullDuplex(Direction direction, uint channel) => device.GetFullDuplex(direction, channel);

        public string[] GetStreamFormats(Direction direction, uint channel) => device.GetStreamFormats(direction, channel).ToArray();

        public string GetNativeStreamFormat(Direction direction, uint channel, out double fullScaleOut) => device.GetNativeStreamFormat(direction, channel, out fullScaleOut);

        public ArgInfo[] GetStreamArgsInfo(Direction direction, uint channel) => device.GetStreamArgsInfo(direction, channel).Select(x => new ArgInfo(x)).ToArray();

        public TxStream SetupTxStream(string format, uint[] channels, Dictionary<string, string> kwargs)
            => new TxStream(device, format, channels, Utility.AnyMapToKwargs(kwargs));

        // TODO: RxStream

        public string[] ListAntennas(Direction direction, uint channel) => device.ListAntennas(direction, channel).ToArray();

        public void SetAntenna(Direction direction, uint channel, string name) => device.SetAntenna(direction, channel, name);

        public string GetAntenna(Direction direction, uint channel) => device.GetAntenna(direction, channel);

        public bool HasDCOffsetMode(Direction direction, uint channel) => device.HasDCOffsetMode(direction, channel);

        public void SetDCOffsetMode(Direction direction, uint channel, bool automatic) => device.SetDCOffsetMode(direction, channel, automatic);

        public bool GetDCOffsetMode(Direction direction, uint channel) => device.GetDCOffsetMode(direction, channel);

        public bool HasDCOffset(Direction direction, uint channel) => device.HasDCOffset(direction, channel);

        public void SetDCOffset(Direction direction, uint channel, System.Numerics.Complex dcOffset) => device.SetDCOffset(direction, channel, dcOffset);

        public System.Numerics.Complex GetDCOffset(Direction direction, uint channel) => device.GetDCOffset(direction, channel);

        public bool HasIQBalance(Direction direction, uint channel) => device.HasIQBalance(direction, channel);

        public void SetIQBalance(Direction direction, uint channel, System.Numerics.Complex iqBalance) => device.SetIQBalance(direction, channel, iqBalance);

        public System.Numerics.Complex GetIQBalance(Direction direction, uint channel) => device.GetIQBalance(direction, channel);

        public bool HasIQBalanceMode(Direction direction, uint channel) => device.HasIQBalanceMode(direction, channel);

        public void SetIQBalanceMode(Direction direction, uint channel, bool automatic) => device.SetIQBalanceMode(direction, channel, automatic);

        public bool GetIQBalanceMode(Direction direction, uint channel) => device.GetIQBalanceMode(direction, channel);

        public bool HasFrequencyCorrection(Direction direction, uint channel) => device.HasFrequencyCorrection(direction, channel);

        public void SetFrequencyCorrection(Direction direction, uint channel, double correction) => device.SetFrequencyCorrection(direction, channel, correction);

        public double GetFrequencyCorrection(Direction direction, uint channel) => device.GetFrequencyCorrection(direction, channel);

        public string[] ListGains(Direction direction, uint channel) => device.ListGains(direction, channel).ToArray();

        public bool HasGainMode(Direction direction, uint channel) => device.HasGainMode(direction, channel);

        public void SetGainMode(Direction direction, uint channel, bool automatic) => device.SetGainMode(direction, channel, automatic);

        public bool GetGainMode(Direction direction, uint channel) => device.GetGainMode(direction, channel);

        public void SetGain(Direction direction, uint channel, double value) => device.SetGain(direction, channel, value);

        public void SetGain(Direction direction, uint channel, string name, double value) => device.SetGain(direction, channel, name, value);

        public double GetGain(Direction direction, uint channel) => device.GetGain(direction, channel);

        public double GetGain(Direction direction, uint channel, string name) => device.GetGain(direction, channel, name);

        public void SetFrequency(Direction direction, uint channel, double frequency, IDictionary<string, string> args) => device.SetFrequency(direction, channel, frequency, Utility.AnyMapToKwargs(args));

        public void SetFrequency(Direction direction, uint channel, string name, double frequency, IDictionary<string, string> args) => device.SetFrequency(direction, channel, name, frequency, Utility.AnyMapToKwargs(args));

        public double GetFrequency(Direction direction, uint channel) => device.GetFrequency(direction, channel);

        public double GetFrequency(Direction direction, uint channel, string name) => device.GetFrequency(direction, channel, name);

        public string[] ListFrequencies(Direction direction, uint channel) => device.ListFrequencies(direction, channel).ToArray();

        public Range[] GetFrequencyRange(Direction direction, uint channel) => device.GetFrequencyRange(direction, channel).ToArray();

        public Range[] GetFrequencyRange(Direction direction, uint channel, string name) => device.GetFrequencyRange(direction, channel, name).ToArray();

        public ArgInfo[] GetFrequencyArgsInfo(Direction direction, uint channel) => device.GetFrequencyArgsInfo(direction, channel).Select(x => new ArgInfo(x)).ToArray();

        public void SetSampleRate(Direction direction, uint channel, double rate) => device.SetSampleRate(direction, channel, rate);

        public void GetSampleRate(Direction direction, uint channel) => device.GetSampleRate(direction, channel);

        public Range[] GetSampleRateRange(Direction direction, uint channel) => device.GetSampleRateRange(direction, channel).ToArray();

        public void SetBandwidth(Direction direction, uint channel, double bandwidth) => device.SetBandwidth(direction, channel, bandwidth);

        public void GetBandwidth(Direction direction, uint channel) => device.GetBandwidth(direction, channel);

        public Range[] GetBandwidthRange(Direction direction, uint channel) => device.GetBandwidthRange(direction, channel).ToArray();

        public double MasterClockRate
        {
            get => device.GetMasterClockRate();
            set => device.SetMasterClockRate(value);
        }

        public Range[] MasterClockRates => device.GetMasterClockRates().ToArray();

        public double ReferenceClockRate
        {
            get => device.GetReferenceClockRate();
            set => device.SetReferenceClockRate(value);
        }

        public Range[] ReferenceClockRates => device.GetReferenceClockRates().ToArray();

        public string ClockSource
        {
            get => device.GetClockSource();
            set => device.SetClockSource(value);
        }

        public string[] ClockSources => device.ListClockSources().ToArray();

        //
        // Object overrides
        //

        public override string ToString() => device.__ToString();

        public override bool Equals(object obj) => (obj is Device) && ((Device)obj).device.Equals(device);

        public override int GetHashCode() => GetType().GetHashCode() ^ device.GetPointer().GetHashCode();
    }
}