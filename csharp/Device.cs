// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Collections.Generic;
using System.Linq;

// TODO: reorder for consistency, not to match Device.hpp

namespace SoapySDR
{    
    public class Device
    {
        private DeviceInternal _device = null;

        internal Device(DeviceInternal deviceInternal) => _device = deviceInternal;

        public Device(string args) => _device = new DeviceInternal(args);

        public Device(IDictionary<string, string> args) => _device = new DeviceInternal(Utility.ToKwargs(args));

        public static Dictionary<string, string>[] Enumerate() => Utility.ToDictionaryArray(DeviceInternal.Enumerate());

        public static Dictionary<string, string>[] Enumerate(string args) => Utility.ToDictionaryArray(DeviceInternal.Enumerate(args));

        public static Dictionary<string, string>[] Enumerate(IDictionary<string, string> args) => Utility.ToDictionaryArray(DeviceInternal.Enumerate(Utility.ToKwargs(args)));

        public string DriverKey => _device.GetDriverKey();

        public string HardwareKey => _device.GetHardwareKey();

        public Dictionary<string, string> HardwareInfo => Utility.ToDictionary(_device.GetHardwareInfo());

        public void SetFrontendMapping(Direction direction, string mapping) => _device.SetFrontendMapping(direction, mapping);

        public string GetFrontendMapping(Direction direction) => _device.GetFrontendMapping(direction);

        public uint GetNumChannels(Direction direction) => _device.GetNumChannels(direction);

        public Dictionary<string, string> GetChannelInfo(Direction direction, uint channel) => Utility.ToDictionary(_device.GetChannelInfo(direction, channel));

        public bool GetFullDuplex(Direction direction, uint channel) => _device.GetFullDuplex(direction, channel);

        public string[] GetStreamFormats(Direction direction, uint channel) => _device.GetStreamFormats(direction, channel).ToArray();

        public string GetNativeStreamFormat(Direction direction, uint channel, out double fullScaleOut) => _device.GetNativeStreamFormat(direction, channel, out fullScaleOut);

        public ArgInfo[] GetStreamArgsInfo(Direction direction, uint channel) => Utility.ToArgInfoArray(_device.GetStreamArgsInfo(direction, channel));

        public TxStream SetupTxStream(string format, uint[] channels, IDictionary<string, string> kwargs)
            => new TxStream(_device, format, channels, Utility.ToKwargs(kwargs));

        public RxStream SetupRxStream(string format, uint[] channels, IDictionary<string, string> kwargs)
            => new RxStream(_device, format, channels, Utility.ToKwargs(kwargs));

        public string[] ListAntennas(Direction direction, uint channel) => _device.ListAntennas(direction, channel).ToArray();

        public void SetAntenna(Direction direction, uint channel, string name) => _device.SetAntenna(direction, channel, name);

        public string GetAntenna(Direction direction, uint channel) => _device.GetAntenna(direction, channel);

        public bool HasDCOffsetMode(Direction direction, uint channel) => _device.HasDCOffsetMode(direction, channel);

        public void SetDCOffsetMode(Direction direction, uint channel, bool automatic) => _device.SetDCOffsetMode(direction, channel, automatic);

        public bool GetDCOffsetMode(Direction direction, uint channel) => _device.GetDCOffsetMode(direction, channel);

        public bool HasDCOffset(Direction direction, uint channel) => _device.HasDCOffset(direction, channel);

        public void SetDCOffset(Direction direction, uint channel, System.Numerics.Complex dcOffset) => _device.SetDCOffset(direction, channel, dcOffset);

        public System.Numerics.Complex GetDCOffset(Direction direction, uint channel) => _device.GetDCOffset(direction, channel);

        public bool HasIQBalance(Direction direction, uint channel) => _device.HasIQBalance(direction, channel);

        public void SetIQBalance(Direction direction, uint channel, System.Numerics.Complex iqBalance) => _device.SetIQBalance(direction, channel, iqBalance);

        public System.Numerics.Complex GetIQBalance(Direction direction, uint channel) => _device.GetIQBalance(direction, channel);

        public bool HasIQBalanceMode(Direction direction, uint channel) => _device.HasIQBalanceMode(direction, channel);

        public void SetIQBalanceMode(Direction direction, uint channel, bool automatic) => _device.SetIQBalanceMode(direction, channel, automatic);

        public bool GetIQBalanceMode(Direction direction, uint channel) => _device.GetIQBalanceMode(direction, channel);

        public bool HasFrequencyCorrection(Direction direction, uint channel) => _device.HasFrequencyCorrection(direction, channel);

        public void SetFrequencyCorrection(Direction direction, uint channel, double correction) => _device.SetFrequencyCorrection(direction, channel, correction);

        public double GetFrequencyCorrection(Direction direction, uint channel) => _device.GetFrequencyCorrection(direction, channel);

        public string[] ListGains(Direction direction, uint channel) => _device.ListGains(direction, channel).ToArray();

        public bool HasGainMode(Direction direction, uint channel) => _device.HasGainMode(direction, channel);

        public void SetGainMode(Direction direction, uint channel, bool automatic) => _device.SetGainMode(direction, channel, automatic);

        public bool GetGainMode(Direction direction, uint channel) => _device.GetGainMode(direction, channel);

        public void SetGain(Direction direction, uint channel, double value) => _device.SetGain(direction, channel, value);

        public void SetGain(Direction direction, uint channel, string name, double value) => _device.SetGain(direction, channel, name, value);

        public double GetGain(Direction direction, uint channel) => _device.GetGain(direction, channel);

        public double GetGain(Direction direction, uint channel, string name) => _device.GetGain(direction, channel, name);

        public void SetFrequency(Direction direction, uint channel, double frequency, IDictionary<string, string> args) => _device.SetFrequency(direction, channel, frequency, Utility.ToKwargs(args));

        public void SetFrequency(Direction direction, uint channel, string name, double frequency, IDictionary<string, string> args) => _device.SetFrequency(direction, channel, name, frequency, Utility.ToKwargs(args));

        public double GetFrequency(Direction direction, uint channel) => _device.GetFrequency(direction, channel);

        public double GetFrequency(Direction direction, uint channel, string name) => _device.GetFrequency(direction, channel, name);

        public string[] ListFrequencies(Direction direction, uint channel) => _device.ListFrequencies(direction, channel).ToArray();

        public Range[] GetFrequencyRange(Direction direction, uint channel) => Utility.ToRangeArray(_device.GetFrequencyRange(direction, channel));

        public Range[] GetFrequencyRange(Direction direction, uint channel, string name) => Utility.ToRangeArray(_device.GetFrequencyRange(direction, channel, name));

        public ArgInfo[] GetFrequencyArgsInfo(Direction direction, uint channel) => Utility.ToArgInfoArray(_device.GetFrequencyArgsInfo(direction, channel));

        public void SetSampleRate(Direction direction, uint channel, double rate) => _device.SetSampleRate(direction, channel, rate);

        public void GetSampleRate(Direction direction, uint channel) => _device.GetSampleRate(direction, channel);

        public Range[] GetSampleRateRange(Direction direction, uint channel) => Utility.ToRangeArray(_device.GetSampleRateRange(direction, channel));

        public void SetBandwidth(Direction direction, uint channel, double bandwidth) => _device.SetBandwidth(direction, channel, bandwidth);

        public void GetBandwidth(Direction direction, uint channel) => _device.GetBandwidth(direction, channel);

        public Range[] GetBandwidthRange(Direction direction, uint channel) => Utility.ToRangeArray(_device.GetBandwidthRange(direction, channel));

        public double MasterClockRate
        {
            get => _device.GetMasterClockRate();
            set => _device.SetMasterClockRate(value);
        }

        public Range[] MasterClockRates => Utility.ToRangeArray(_device.GetMasterClockRates());

        public double ReferenceClockRate
        {
            get => _device.GetReferenceClockRate();
            set => _device.SetReferenceClockRate(value);
        }

        public Range[] ReferenceClockRates => Utility.ToRangeArray(_device.GetReferenceClockRates());

        public string ClockSource
        {
            get => _device.GetClockSource();
            set => _device.SetClockSource(value);
        }

        public string[] ClockSources => _device.ListClockSources().ToArray();

        public string[] TimeSources => _device.ListTimeSources().ToArray();

        public string TimeSource
        {
            get => _device.GetTimeSource();
            set => _device.SetTimeSource(value);
        }

        public bool HasHardwareTime(string what) => _device.HasHardwareTime(what);

        public long GetHardwareTime(string what) => _device.GetHardwareTime(what);

        public void SetHardwareTime(long timeNs, string what = "") => _device.SetHardwareTime(timeNs, what);

        public string[] ListSensors() => _device.ListSensors().ToArray();

        public ArgInfo GetSensorInfo(string key) => new ArgInfo(_device.GetSensorInfo(key));

        public object ReadSensor(string key) => new SoapyConvertible(_device.ReadSensor(key)).ToArgType(GetSensorInfo(key).Type);

        public T ReadSensor<T>(string key) => (T)(new SoapyConvertible(_device.ReadSensor(key)).ToType(typeof(T), null));

        public string[] ListSensors(Direction direction, uint channel) => _device.ListSensors(direction, channel).ToArray();

        public ArgInfo GetSensorInfo(Direction direction, uint channel, string key) => new ArgInfo(_device.GetSensorInfo(direction, channel, key));

        public string[] RegisterInterfaces => _device.ListRegisterInterfaces().ToArray();

        public void WriteRegister(string name, uint addr, uint value) => _device.WriteRegister(name, addr, value);

        public uint ReadRegister(string name, uint addr) => _device.ReadRegister(name, addr);

        public void WriteRegisters(string name, uint addr, uint[] value) => _device.WriteRegisters(name, addr, new SizeList(value));

        public uint[] ReadRegisters(string name, uint addr, uint length)
            => _device.ReadRegisters(name, addr, length).Select(x => (uint)x).ToArray();

        public ArgInfo[] GetSettingInfo() => Utility.ToArgInfoArray(_device.GetSettingInfo());

        public void WriteSetting(string key, object value) => _device.WriteSetting(key, new SoapyConvertible(value).ToString());

        public object ReadSetting(string key)
        {
            var query = GetSettingInfo().Where(x => x.Key.Equals(key));

            if (query.Any())
            {
                var info = query.First();
                return new SoapyConvertible(_device.ReadSetting(key)).ToArgType(info.Type);
            }
            else throw new System.ArgumentException("Invalid setting: " + key);
        }

        public T ReadSetting<T>(string key)
        {
            if(GetSettingInfo().Any(x => x.Key.Equals(key)))
                return (T)(new SoapyConvertible(_device.ReadSetting(key)).ToType(typeof(T), null));
            else
                throw new System.ArgumentException("Invalid setting: " + key);
        }

        public ArgInfo[] GetSettingInfo(Direction direction, uint channel) => Utility.ToArgInfoArray(_device.GetSettingInfo(direction, channel));

        public void WriteSetting(Direction direction, uint channel, string key, object value) => _device.WriteSetting(direction, channel, key, new SoapyConvertible(value).ToString());

        public object ReadSetting(Direction direction, uint channel, string key)
        {
            var query = GetSettingInfo(direction, channel).Where(x => x.Key.Equals(key));

            if (query.Any())
            {
                var info = query.First();
                return new SoapyConvertible(_device.ReadSetting(direction, channel, key)).ToArgType(info.Type);
            }
            else throw new System.ArgumentException("Invalid setting: " + key);
        }

        public T ReadSetting<T>(Direction direction, uint channel, string key)
        {
            if (GetSettingInfo(direction, channel).Any(x => x.Key.Equals(key)))
                return (T)(new SoapyConvertible(_device.ReadSetting(direction, channel, key)).ToType(typeof(T), null));
            else
                throw new System.ArgumentException("Invalid setting: " + key);
        }

        public string[] GPIOBanks => _device.ListGPIOBanks().ToArray();

        public void WriteGPIO(string bank, uint value) => _device.WriteGPIO(bank, value);

        public void WriteGPIO(string bank, uint value, uint mask) => _device.WriteGPIO(bank, value, mask);

        public uint ReadGPIO(string bank) => _device.ReadGPIO(bank);

        public void WriteI2C(int addr, string data) => _device.WriteI2C(addr, data);

        public string ReadI2C(int addr, uint numBytes) => _device.ReadI2C(addr, numBytes);

        public uint TransactSPI(int addr, uint data, uint numBits) => _device.TransactSPI(addr, data, numBits);

        public string[] UARTs => _device.ListUARTs().ToArray();

        public void WriteUART(string which, string data) => _device.WriteUART(which, data);

        public string ReadUART(string which, long timeoutUs = 100000) => _device.ReadUART(which, timeoutUs);

        //
        // Object overrides
        //

        public override string ToString() => _device.__ToString();

        public override bool Equals(object obj) => ((Device)obj)?._device.Equals(_device) ?? false;

        public override int GetHashCode() => GetType().GetHashCode() ^ _device.GetPointer().GetHashCode();
    }
}