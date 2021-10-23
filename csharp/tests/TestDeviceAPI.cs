// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Collections.Generic;

using NUnit.Framework;

// For the null device, functions generally don't do anything or return some
// hardcoded value, but we can still make sure functions compile and run as
// expected, especially for the added C# fanciness.

[TestFixture]
public class TestSoapyTypes
{
    private void TestDeviceKeys(SoapySDR.Device device)
    {
        Assert.AreEqual("null", device.DriverKey);
        Assert.AreEqual("null", device.HardwareKey);
        Assert.AreEqual("null:null", device.ToString());
    }

    private SoapySDR.Device GetTestDevice()
    {
        // Make sure either method works.
        TestDeviceKeys(new SoapySDR.Device("driver=null,type=null"));

        var args = new Dictionary<string, string>();
        args.Add("driver", "null");
        args.Add("type", "null");

        var device = new SoapySDR.Device(args);
        TestDeviceKeys(device);

        return device;
    }

    [Test]
    public void Test_DeviceGeneralFunctions()
    {
        var device = GetTestDevice();

        //
        // Clocking API
        //

        device.MasterClockRate = 0.0;
        Assert.AreEqual(0.0, device.MasterClockRate);
        _ = device.MasterClockRates;

        device.ReferenceClockRate = 0.0;
        Assert.AreEqual(0.0, device.ReferenceClockRate);
        _ = device.ReferenceClockRates;

        device.ClockSource = "";
        Assert.AreEqual("", device.ClockSource);
        _ = device.ClockSources;

        //
        // Time API
        //

        device.TimeSource = "";
        Assert.AreEqual("", device.TimeSource);
        _ = device.TimeSources;

        _ = device.HasHardwareTime("");
        Assert.AreEqual(0, device.GetHardwareTime(""));
        device.SetHardwareTime(0);
        device.SetHardwareTime(0, "");

        //
        // Sensor API
        //

        _ = device.ListSensors();
        _ = device.GetSensorInfo("");

        _ = device.ReadSensor("");
        _ = device.ReadSensor<bool>("");
        _ = device.ReadSensor<short>("");
        _ = device.ReadSensor<int>("");
        _ = device.ReadSensor<long>("");
        _ = device.ReadSensor<ushort>("");
        _ = device.ReadSensor<uint>("");
        _ = device.ReadSensor<ulong>("");
        _ = device.ReadSensor<float>("");
        _ = device.ReadSensor<double>("");
        _ = device.ReadSensor<string>("");

        //
        // Register API
        //

        _ = device.RegisterInterfaces;

        device.WriteRegister("", 0, 0);
        Assert.AreEqual(0, device.ReadRegister("", 0));

        device.WriteRegisters("", 0, new uint[] { 0, 0, 0 });
        _ = device.ReadRegisters("", 0, 1);

        //
        // Settings API
        //

        _ = device.GetSettingInfo();

        device.WriteSetting("", 0);
        device.WriteSetting("", 0.0);
        device.WriteSetting("", false);
        device.WriteSetting("", "");

        _ = device.ReadSetting("");
        _ = device.ReadSetting<bool>("");
        _ = device.ReadSetting<short>("");
        _ = device.ReadSetting<int>("");
        _ = device.ReadSetting<long>("");
        _ = device.ReadSetting<ushort>("");
        _ = device.ReadSetting<uint>("");
        _ = device.ReadSetting<ulong>("");
        _ = device.ReadSetting<float>("");
        _ = device.ReadSetting<double>("");
        _ = device.ReadSetting<string>("");

        //
        // GPIO API
        //

        _ = device.GPIOBanks;

        device.WriteGPIO("", 0);
        device.WriteGPIO("", 0, 0);
        Assert.AreEqual("", device.ReadGPIO(""));

        device.WriteGPIODir("", 0);
        device.WriteGPIODir("", 0, 0);
        Assert.AreEqual(0, device.ReadGPIODir(""));

        //
        // I2C API
        //

        device.WriteI2C(0, "");
        Assert.AreEqual("", device.ReadI2C(0, 0));

        //
        // SPI API
        //

        Assert.AreEqual(0, device.TransactSPI(0, 0, 0));

        //
        // UART API
        //

        _ = device.UARTs;
        device.WriteUART("", "");
        Assert.AreEqual("", device.ReadUART(""));
        Assert.AreEqual("", device.ReadUART("", 1000));
    }

    [Test]
    [TestCase(SoapySDR.Direction.Rx)]
    [TestCase(SoapySDR.Direction.Tx)]
    public void Test_DeviceNonStreamingDirectionFunctions(SoapySDR.Direction direction)
    {
        var device = GetTestDevice();

        //
        // Channels API
        //

        device.SetFrontendMapping(direction, "");
        _ = device.GetFrontendMapping(direction);
        _ = device.GetNumChannels(direction);
        _ = device.GetChannelInfo(direction, 0);
        _ = device.GetFullDuplex(direction, 0);

        //
        // Stream API
        //

        _ = device.GetStreamFormats(direction, 0);

        double fullScale;
        Assert.AreEqual(SoapySDR.StreamFormats.CS16, device.GetNativeStreamFormat(direction, 0, out fullScale));
        Assert.AreEqual(1 << 15, fullScale);

        _ = device.GetStreamArgsInfo(direction, 0);

        //
        // Antenna API
        //

        _ = device.ListAntennas(direction, 0);
        _ = device.GetAntenna(direction, 0);
        device.SetAntenna(direction, 0, "ANT");

        //
        // Frontend corrections API
        //

        _ = device.HasDCOffsetMode(direction, 0);
        _ = device.GetDCOffsetMode(direction, 0);
        device.SetDCOffsetMode(direction, 0, true);

        _ = device.HasDCOffset(direction, 0);
        _ = device.GetDCOffset(direction, 0);
        device.SetDCOffset(direction, 0, new System.Numerics.Complex(1.0, 0.0));

        _ = device.HasIQBalanceMode(direction, 0);
        _ = device.GetIQBalanceMode(direction, 0);
        device.SetIQBalanceMode(direction, 0, true);

        _ = device.HasIQBalance(direction, 0);
        _ = device.GetIQBalance(direction, 0);
        device.SetIQBalance(direction, 0, new System.Numerics.Complex(1.0, 0.0));

        _ = device.HasFrequencyCorrection(direction, 0);
        _ = device.GetFrequencyCorrection(direction, 0);
        device.SetFrequencyCorrection(direction, 0, 0.0);

        //
        // Gain API
        //

        _ = device.ListGains(direction, 0);

        _ = device.HasGainMode(direction, 0);
        _ = device.GetGainMode(direction, 0);
        device.SetGainMode(direction, 0, true);

        _ = device.GetGain(direction, 0);
        _ = device.GetGain(direction, 0, "");
        device.SetGain(direction, 0, 0.0);
        device.SetGain(direction, 0, "", 0.0);

        _ = device.GetGainRange(direction, 0);
        _ = device.GetGainRange(direction, 0, "");

        //
        // Frequency API
        //

        var frequencyArgs = new Dictionary<string, string>();
        frequencyArgs["key0"] = "val0";
        frequencyArgs["key1"] = "val1";

        device.SetFrequency(direction, 0, 0.0);
        device.SetFrequency(direction, 0, 0.0, frequencyArgs);
        _ = device.GetFrequency(direction, 0);

        device.SetFrequency(direction, 0, "", 0.0);
        device.SetFrequency(direction, 0, "", 0.0, frequencyArgs);
        _ = device.GetFrequency(direction, 0, "");

        _ = device.ListFrequencies(direction, 0);

        _ = device.GetFrequencyRange(direction, 0);
        _ = device.GetFrequencyRange(direction, 0, "");
        _ = device.GetFrequencyArgsInfo(direction, 0);

        //
        // Sample rate API
        //

        device.SetSampleRate(direction, 0, 0.0);
        _ = device.GetSampleRate(direction, 0);
        _ = device.GetSampleRateRange(direction, 0);

        //
        // Bandwidth API
        //

        device.SetBandwidth(direction, 0, 0.0);
        _ = device.GetBandwidth(direction, 0);
        _ = device.GetBandwidthRange(direction, 0);

        //
        // Sensor API
        //

        _ = device.ListSensors(direction, 0);

        _ = device.ReadSensor(direction, 0, "");
        _ = device.ReadSensor<bool>(direction, 0, "");
        _ = device.ReadSensor<short>(direction, 0, "");
        _ = device.ReadSensor<int>(direction, 0, "");
        _ = device.ReadSensor<long>(direction, 0, "");
        _ = device.ReadSensor<ushort>(direction, 0, "");
        _ = device.ReadSensor<uint>(direction, 0, "");
        _ = device.ReadSensor<ulong>(direction, 0, "");
        _ = device.ReadSensor<float>(direction, 0, "");
        _ = device.ReadSensor<double>(direction, 0, "");
        _ = device.ReadSensor<string>(direction, 0, "");

        //
        // Settings API
        //

        _ = device.GetSettingInfo(direction, 0);

        device.WriteSetting("", 0);
        device.WriteSetting("", 0.0);
        device.WriteSetting("", false);
        device.WriteSetting("", "");

        _ = device.ReadSetting(direction, 0, "");
        _ = device.ReadSetting<bool>(direction, 0, "");
        _ = device.ReadSetting<short>(direction, 0, "");
        _ = device.ReadSetting<int>(direction, 0, "");
        _ = device.ReadSetting<long>(direction, 0, "");
        _ = device.ReadSetting<ushort>(direction, 0, "");
        _ = device.ReadSetting<uint>(direction, 0, "");
        _ = device.ReadSetting<ulong>(direction, 0, "");
        _ = device.ReadSetting<float>(direction, 0, "");
        _ = device.ReadSetting<double>(direction, 0, "");
        _ = device.ReadSetting<string>(direction, 0, "");
    }

    //
    // This is needed because the StreamFormats strings aren't known at build-time,
    // which is required for test attributes.
    //

    private void GetTxStreamTestParams(
        out uint[] oneChannel,
        out uint[] twoChannels,
        out Dictionary<string, string> streamArgs,
        out SoapySDR.StreamFlags streamFlags,
        out long timeNs,
        out int timeoutUs,
        out uint numElems)
    {
        oneChannel = new uint[]{ 0 };
        twoChannels = new uint[]{ 0, 1 };

        streamArgs = new Dictionary<string, string>();
        streamArgs["bufflen"] = "8192";
        streamArgs["buffers"] = "15";

        streamFlags = SoapySDR.StreamFlags.HasTime | SoapySDR.StreamFlags.EndBurst;
        timeNs = 1000;
        timeoutUs = 1000;
        numElems = 1024;
    }

    private unsafe void TestTxStreamNonGeneric(string format)
    {
        var device = GetTestDevice();

        GetTxStreamTestParams(
            out uint[] channel,
            out uint[] channels,
            out Dictionary<string, string> streamArgs,
            out SoapySDR.StreamFlags streamFlags,
            out long timeNs,
            out int timeoutUs,
            out uint numElems);

        SoapySDR.StreamResult streamResult = new SoapySDR.StreamResult();

        //
        // Test with single channel
        //

        var txStream = device.SetupTxStream(format, channel, streamArgs);
        Assert.AreEqual(format, txStream.Format);
        Assert.AreEqual(channel, txStream.Channels);
        Assert.AreEqual(streamArgs, txStream.StreamArgs);
        Assert.False(txStream.Active);
        Assert.AreEqual(1024, txStream.MTU);

        txStream.Activate(streamFlags, timeNs, numElems);
        Assert.True(txStream.Active);

        byte[] buf = new byte[numElems * SoapySDR.StreamFormats.FormatToSize(format)];
        fixed(void* ptr = &buf[0])
        {
            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write((IntPtr)ptr, numElems, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write((UIntPtr)ptr, numElems, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);
        }

        txStream.Deactivate();
        Assert.False(txStream.Active);
        txStream.Close();

        //
        // Test with multiple channels
        //
        
        txStream = device.SetupTxStream(format, channels, streamArgs);
        Assert.AreEqual(format, txStream.Format);
        Assert.AreEqual(channels, txStream.Channels);
        Assert.AreEqual(streamArgs, txStream.StreamArgs);
        Assert.False(txStream.Active);
        Assert.AreEqual(1024, txStream.MTU);

        byte[][] bufs = new byte[channels.Length][];
        for (var i = 0; i < bufs.Length; ++i) bufs[i] = new byte[numElems * SoapySDR.StreamFormats.FormatToSize(format)];

        fixed(void* ptr0 = &buf[0])
        {
            fixed(void* ptr1 = &buf[1])
            {
                var intPtrs = new IntPtr[] { (IntPtr)ptr0, (IntPtr)ptr1 };
                Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(intPtrs, numElems, timeNs, timeoutUs, out streamResult));
                Assert.AreEqual(0, streamResult.NumSamples);
                Assert.AreEqual(streamFlags, streamResult.Flags);

                var uintPtrs = new UIntPtr[] { (UIntPtr)ptr0, (UIntPtr)ptr1 };
                Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(uintPtrs, numElems, timeNs, timeoutUs, out streamResult));
                Assert.AreEqual(0, streamResult.NumSamples);
                Assert.AreEqual(streamFlags, streamResult.Flags);
            }
        }

        //
        // Test async read status
        //

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.ReadStatus(timeoutUs, out streamResult));
        Assert.AreEqual(0, streamResult.TimeNs);
        Assert.AreEqual(SoapySDR.StreamFlags.None, streamResult.Flags);
        Assert.AreEqual(0, streamResult.ChanMask);

        txStream.Deactivate();
        Assert.False(txStream.Active);
        txStream.Close();
    }

    // TODO: StreamFormats -> StreamFormat
    [Test]
    public void Test_TxStreamNonGeneric()
    {
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.S8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.S16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.S32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.U8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.U16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.U32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.F32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.F64);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CS8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CS12);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CS16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CS32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CU8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CU12);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CU16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CU32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CF32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormats.CF64);
    }


}