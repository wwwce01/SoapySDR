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

        public static Dictionary<string, string>[] Enumerate() => DeviceInternal.Enumerate().Select(x => x.ToDictionary(entry => entry.Key, entry => entry.Value)).ToArray();

        public static Dictionary<string, string>[] Enumerate(string args) => DeviceInternal.Enumerate(args).Select(x => x.ToDictionary(entry => entry.Key, entry => entry.Value)).ToArray();

        public static Dictionary<string, string>[] Enumerate(IDictionary<string, string> args) => DeviceInternal.Enumerate(Utility.AnyMapToKwargs(args)).Select(x => x.ToDictionary(entry => entry.Key, entry => entry.Value)).ToArray();

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

        public RxStream SetupRxStream(string format, uint[] channels, Dictionary<string, string> kwargs)
            => new RxStream(device, format, channels, Utility.AnyMapToKwargs(kwargs));

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

        public string[] TimeSources => device.ListTimeSources().ToArray();

        public string TimeSource
        {
            get => device.GetTimeSource();
            set => device.SetTimeSource(value);
        }

        public bool HasHardwareTime(string what) => device.HasHardwareTime(what);

        public long GetHardwareTime(string what) => device.GetHardwareTime(what);

        public void SetHardwareTime(long timeNs, string what = "") => device.SetHardwareTime(timeNs, what);

        public string[] ListSensors() => device.ListSensors().ToArray();

        public ArgInfo GetSensorInfo(string key) => new ArgInfo(device.GetSensorInfo(key));

        public object ReadSensor(string key) => new SoapyConvertible(device.ReadSensor(key)).ToArgType(GetSensorInfo(key).Type);

        public T ReadSensor<T>(string key) => (T)(new SoapyConvertible(device.ReadSensor(key)).ToType(typeof(T), null));

        public string[] ListSensors(Direction direction, uint channel) => device.ListSensors(direction, channel).ToArray();

        public ArgInfo GetSensorInfo(Direction direction, uint channel, string key) => new ArgInfo(device.GetSensorInfo(direction, channel, key));

        public string[] RegisterInterfaces => device.ListRegisterInterfaces().ToArray();

        public void WriteRegister(string name, uint addr, uint value) => device.WriteRegister(name, addr, value);

        public uint ReadRegister(string name, uint addr) => device.ReadRegister(name, addr);

        public void WriteRegisters(string name, uint addr, uint[] value) => device.WriteRegisters(name, addr, new SizeList(value));

        public uint[] ReadRegisters(string name, uint addr, uint length)
            => device.ReadRegisters(name, addr, length).Select(x => (uint)x).ToArray();

        public ArgInfo[] GetSettingInfo() => device.GetSettingInfo().Select(x => new ArgInfo(x)).ToArray();

        public void WriteSetting(string key, object value) => device.WriteSetting(key, new SoapyConvertible(value).ToString());

        public object ReadSetting(string key)
        {
            object setting = null;
            foreach(var info in GetSettingInfo())
            {
                if(info.Key.Equals(key))
                {
                    setting = new SoapyConvertible(device.ReadSetting(key)).ToArgType(info.Type);
                    break;
                }
            }
            if (setting == null) throw new System.ArgumentException("Invalid setting: "+key);

            return setting;
        }

        public T ReadSetting<T>(string key)
        {
            object setting = null;
            foreach (var info in GetSettingInfo())
            {
                if (info.Key.Equals(key))
                {
                    setting = new SoapyConvertible(device.ReadSetting(key)).ToType(typeof(T), null);
                    break;
                }
            }
            if (setting == null) throw new System.ArgumentException("Invalid setting: " + key);

            return (T)setting;
        }

        public ArgInfo[] GetSettingInfo(Direction direction, uint channel) => device.GetSettingInfo(direction, channel).Select(x => new ArgInfo(x)).ToArray();

        public void WriteSetting(Direction direction, uint channel, string key, object value) => device.WriteSetting(direction, channel, key, new SoapyConvertible(value).ToString());

        public object ReadSetting(Direction direction, uint channel, string key)
        {
            object setting = null;
            foreach (var info in GetSettingInfo(direction, channel))
            {
                if (info.Key.Equals(key))
                {
                    setting = new SoapyConvertible(device.ReadSetting(direction, channel, key)).ToArgType(info.Type);
                    break;
                }
            }
            if (setting == null) throw new System.ArgumentException("Invalid setting: " + key);

            return setting;
        }

        public T ReadSetting<T>(Direction direction, uint channel, string key)
        {
            object setting = null;
            foreach (var info in GetSettingInfo(direction, channel))
            {
                if (info.Key.Equals(key))
                {
                    setting = new SoapyConvertible(device.ReadSetting(direction, channel, key)).ToType(typeof(T), null);
                    break;
                }
            }
            if (setting == null) throw new System.ArgumentException("Invalid setting: " + key);

            return (T)setting;
        }

        public string[] GPIOBanks => device.ListGPIOBanks().ToArray();

        public void WriteGPIO(string bank, uint value) => device.WriteGPIO(bank, value);

        public void WriteGPIO(string bank, uint value, uint mask) => device.WriteGPIO(bank, value, mask);

        public uint ReadGPIO(string bank) => device.ReadGPIO(bank);

        public void WriteI2C(int addr, string data) => device.WriteI2C(addr, data);

        public string ReadI2C(int addr, uint numBytes) => device.ReadI2C(addr, numBytes);

        public uint TransactSPI(int addr, uint data, uint numBits) => device.TransactSPI(addr, data, numBits);

        public string[] UARTs => device.ListUARTs().ToArray();

        public void WriteUART(string which, string data) => device.WriteUART(which, data);

        public string ReadUART(string which, long timeoutUs = 100000) => device.ReadUART(which, timeoutUs);

        //
        // Object overrides
        //

        public override string ToString() => device.__ToString();

        public override bool Equals(object obj) => (obj is Device) && ((Device)obj).device.Equals(device);

        public override int GetHashCode() => GetType().GetHashCode() ^ device.GetPointer().GetHashCode();
    }
}