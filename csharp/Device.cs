// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Collections.Generic;
using System.Linq;

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

        //
        // Object overrides
        //

        public override string ToString() => device.__ToString();

        public override bool Equals(object obj)
        {
            var objAsDevice = obj as Device;
            return (objAsDevice != null) ? device.Equals(objAsDevice.device) : false;
        }

        public override int GetHashCode() => GetType().GetHashCode() ^ device.GetPointer().GetHashCode();
    }
}