// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Collections.Generic;
using System.Linq;

using NUnit.Framework;

// For the null device, functions generally don't do anything or return some
// hardcoded value, but we can still make sure functions compile and run as
// expected, especially for the added C# fanciness.

[TestFixture]
public class TestStreamingAPI
{
    //
    // Utility
    //

    private static void TestDeviceKeys(SoapySDR.Device device)
    {
        Assert.AreEqual("null", device.DriverKey);
        Assert.AreEqual("null", device.HardwareKey);
        Assert.AreEqual("null:null", device.ToString());
    }

    private static SoapySDR.Device GetTestDevice()
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

    private static void GetStreamTestParams(
        out uint[] oneChannel,
        out uint[] twoChannels,
        out string streamArgsString,
        out Dictionary<string, string> streamArgsMap,
        out SoapySDR.StreamFlags streamFlags,
        out long timeNs,
        out int timeoutUs,
        out uint numElems)
    {
        oneChannel = new uint[] { 0 };
        twoChannels = new uint[] { 0, 1 };

        streamArgsString = "bufflen=8192,buffers=15";

        streamArgsMap = new Dictionary<string, string>();
        streamArgsMap["bufflen"] = "8192";
        streamArgsMap["buffers"] = "15";

        streamFlags = SoapySDR.StreamFlags.HasTime | SoapySDR.StreamFlags.EndBurst;
        timeNs = 1000;
        timeoutUs = 1000;
        numElems = 1024;
    }

    //
    // Non-generic TX streaming API
    //

    private unsafe void TestTxStreamNonGeneric(string format)
    {
        var device = GetTestDevice();
        var streamResult = new SoapySDR.StreamResult();

        GetStreamTestParams(
            out uint[] channel,
            out uint[] channels,
            out string streamArgsString,
            out Dictionary<string, string> streamArgsMap,
            out SoapySDR.StreamFlags streamFlags,
            out long timeNs,
            out int timeoutUs,
            out uint numElems);

        //
        // Test with single channel
        //

        var txStream = device.SetupTxStream(format, channel, streamArgsMap);
        Assert.AreEqual(format, txStream.Format);
        Assert.AreEqual(channel, txStream.Channels);
        Assert.AreEqual(streamArgsMap, txStream.StreamArgs);
        Assert.False(txStream.Active);

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Activate(streamFlags, timeNs, numElems));
        Assert.AreEqual(1024, txStream.MTU);

        byte[] buf = new byte[numElems * SoapySDR.StreamFormat.FormatToSize(format)];
        fixed (void* ptr = &buf[0])
        {
            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write((IntPtr)ptr, numElems, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            //Assert.AreEqual(streamFlags, streamResult.Flags);
        }

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Deactivate(streamFlags, timeNs));
        Assert.False(txStream.Active);
        txStream.Close();

        //
        // Test with multiple channels
        //

        txStream = device.SetupTxStream(format, channels, streamArgsMap);
        Assert.AreEqual(format, txStream.Format);
        Assert.AreEqual(channels, txStream.Channels);
        Assert.AreEqual(streamArgsMap, txStream.StreamArgs);

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Activate(streamFlags, timeNs, numElems));
        Assert.AreEqual(1024, txStream.MTU);

        byte[][] bufs = new byte[channels.Length][];
        for (var i = 0; i < bufs.Length; ++i) bufs[i] = new byte[numElems * SoapySDR.StreamFormat.FormatToSize(format)];

        fixed (void* ptr0 = &buf[0])
        {
            fixed (void* ptr1 = &buf[1])
            {
                var intPtrs = new IntPtr[] { (IntPtr)ptr0, (IntPtr)ptr1 };
                Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(intPtrs, numElems, timeNs, timeoutUs, out streamResult));
                Assert.AreEqual(0, streamResult.NumSamples);
            }
        }

        //
        // Test async read status
        //

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.ReadStatus(timeoutUs, out streamResult));
        Assert.AreEqual(0, streamResult.TimeNs);
        Assert.AreEqual(SoapySDR.StreamFlags.None, streamResult.Flags);
        Assert.AreEqual(0, streamResult.ChanMask);

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Deactivate(streamFlags, timeNs));
        Assert.False(txStream.Active);
        txStream.Close();

        //
        // Briefly reopen to test with string args
        //

        txStream = device.SetupTxStream(format, channels, streamArgsString);
        Assert.AreEqual(streamArgsMap, txStream.StreamArgs);
        txStream.Close();
    }

    [Test]
    public void Test_TxStreamNonGeneric()
    {
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.S8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.S16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.S32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.U8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.U16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.U32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.F32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.F64);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CS8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CS12);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CS16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CS32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CU8);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CU12);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CU16);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CU32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CF32);
        TestTxStreamNonGeneric(SoapySDR.StreamFormat.CF64);
    }

    //
    // Non-generic RX streaming API
    //

    private unsafe void TestRxStreamNonGeneric(string format)
    {
        var device = GetTestDevice();
        var streamResult = new SoapySDR.StreamResult();

        GetStreamTestParams(
            out uint[] channel,
            out uint[] channels,
            out string streamArgsString,
            out Dictionary<string, string> streamArgsMap,
            out SoapySDR.StreamFlags streamFlags,
            out long timeNs,
            out int timeoutUs,
            out uint numElems);

        //
        // Test with single channel
        //

        var rxStream = device.SetupRxStream(format, channel, streamArgsMap);
        Assert.AreEqual(format, rxStream.Format);
        Assert.AreEqual(channel, rxStream.Channels);
        Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
        Assert.False(rxStream.Active);

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Activate(streamFlags, timeNs, numElems));
        Assert.AreEqual(1024, rxStream.MTU);

        byte[] buf = new byte[numElems * SoapySDR.StreamFormat.FormatToSize(format)];
        fixed (void* ptr = &buf[0])
        {
            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read((IntPtr)ptr, numElems, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);
        }

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Deactivate(streamFlags, timeNs));
        Assert.False(rxStream.Active);
        rxStream.Close();

        //
        // Test with multiple channels
        //

        rxStream = device.SetupRxStream(format, channels, streamArgsMap);
        Assert.AreEqual(format, rxStream.Format);
        Assert.AreEqual(channels, rxStream.Channels);
        Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
        Assert.False(rxStream.Active);

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Activate(streamFlags, timeNs, numElems));
        Assert.AreEqual(1024, rxStream.MTU);

        byte[][] bufs = new byte[channels.Length][];
        for (var i = 0; i < bufs.Length; ++i) bufs[i] = new byte[numElems * SoapySDR.StreamFormat.FormatToSize(format)];

        fixed (void* ptr0 = &buf[0])
        {
            fixed (void* ptr1 = &buf[1])
            {
                var intPtrs = new IntPtr[] { (IntPtr)ptr0, (IntPtr)ptr1 };
                Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(intPtrs, numElems, streamFlags, timeNs, timeoutUs, out streamResult));
                Assert.AreEqual(0, streamResult.NumSamples);
                Assert.AreEqual(streamFlags, streamResult.Flags);
            }
        }

        Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Deactivate(streamFlags, timeNs));
        Assert.False(rxStream.Active);
        rxStream.Close();

        //
        // Briefly reopen to test with string args
        //

        rxStream = device.SetupRxStream(format, channels, streamArgsString);
        Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
        rxStream.Close();
    }

    [Test]
    public void Test_RxStreamNonGeneric()
    {
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.S8);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.S16);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.S32);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.U8);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.U16);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.U32);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.F32);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.F64);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CS8);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CS12);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CS16);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CS32);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CU8);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CU12);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CU16);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CU32);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CF32);
        TestRxStreamNonGeneric(SoapySDR.StreamFormat.CF64);
    }

    //
    // Generic test interface
    //

    public interface IGenericStreamingTestCase
    {
        void TestTxStreaming();

        void TestComplexTxStreaming();

        void TestRxStreaming();

        void TestComplexRxStreaming();
    }

    //
    // Generic test implementation
    //

    public class GenericStreamingTestCase<T>: IGenericStreamingTestCase where T: unmanaged
    {
        public void TestTxStreaming()
        {
            var device = GetTestDevice();
            SoapySDR.StreamResult streamResult;

            var format = SoapySDR.Utility.GetFormatString<T>();

            GetStreamTestParams(
                out uint[] oneChannel,
                out uint[] twoChannels,
                out string streamArgsString,
                out Dictionary<string, string> streamArgsMap,
                out SoapySDR.StreamFlags streamFlags,
                out long timeNs,
                out int timeoutUs,
                out uint numElems);
            
            //
            // Test with single channel
            //

            var txStream = device.SetupTxStream<T>(oneChannel, streamArgsMap);
            Assert.AreEqual(format, txStream.Format);
            Assert.AreEqual(oneChannel, txStream.Channels);
            Assert.AreEqual(streamArgsMap, txStream.StreamArgs);
            Assert.False(txStream.Active);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Activate(streamFlags, timeNs, numElems));
            Assert.AreEqual(1024, txStream.MTU);

            T[] buff = new T[numElems];
            var mem = new ReadOnlyMemory<T>(buff);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buff, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(mem, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Deactivate(streamFlags, timeNs));
            Assert.False(txStream.Active);
            txStream.Close();

            //
            // Test with multiple channels
            //

            txStream = device.SetupTxStream<T>(twoChannels, streamArgsMap);
            Assert.AreEqual(format, txStream.Format);
            Assert.AreEqual(twoChannels, txStream.Channels);
            Assert.AreEqual(streamArgsMap, txStream.StreamArgs);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Activate(streamFlags, timeNs, numElems));
            Assert.AreEqual(1024, txStream.MTU);

            T[][] buffs = new T[2][];
            buffs[0] = new T[numElems];
            buffs[1] = new T[numElems];

            ReadOnlyMemory<T>[] mems = buffs.Select(buff_ => new ReadOnlyMemory<T>(buff_)).ToArray();

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buffs, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(mems, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Deactivate(streamFlags, timeNs));
            Assert.False(txStream.Active);
            txStream.Close();

            //
            // Briefly reopen to test with string args
            //

            txStream = device.SetupTxStream(format, twoChannels, streamArgsString);
            Assert.AreEqual(streamArgsMap, txStream.StreamArgs);
            txStream.Close();
        }

        public void TestComplexTxStreaming()
        {
            var device = GetTestDevice();
            SoapySDR.StreamResult streamResult;

            var format = SoapySDR.Utility.GetComplexFormatString<T>();

            GetStreamTestParams(
                out uint[] oneChannel,
                out uint[] twoChannels,
                out string streamArgsString,
                out Dictionary<string, string> streamArgsMap,
                out SoapySDR.StreamFlags streamFlags,
                out long timeNs,
                out int timeoutUs,
                out uint numElems);

            //
            // Test with single channel
            //

            var txStream = device.SetupComplexTxStream<T>(oneChannel, streamArgsMap);
            Assert.AreEqual(format, txStream.Format);
            Assert.AreEqual(oneChannel, txStream.Channels);
            Assert.AreEqual(streamArgsMap, txStream.StreamArgs);
            Assert.False(txStream.Active);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Activate(streamFlags, timeNs, numElems));
            Assert.AreEqual(1024, txStream.MTU);

            T[] buff = new T[numElems * 2];
            var mem = new ReadOnlyMemory<T>(buff);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buff, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(mem, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Deactivate(streamFlags, timeNs));
            Assert.False(txStream.Active);
            txStream.Close();

            //
            // Test with multiple channels
            //

            txStream = device.SetupComplexTxStream<T>(twoChannels, streamArgsMap);
            Assert.AreEqual(format, txStream.Format);
            Assert.AreEqual(twoChannels, txStream.Channels);
            Assert.AreEqual(streamArgsMap, txStream.StreamArgs);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Activate(streamFlags, timeNs, numElems));
            Assert.AreEqual(1024, txStream.MTU);

            T[][] buffs = new T[2][];
            buffs[0] = new T[numElems * 2];
            buffs[1] = new T[numElems * 2];

            ReadOnlyMemory<T>[] mems = buffs.Select(buff_ => new ReadOnlyMemory<T>(buff_)).ToArray();

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buffs, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(mems, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Deactivate(streamFlags, timeNs));
            Assert.False(txStream.Active);
            txStream.Close();

            //
            // Briefly reopen to test with string args
            //

            txStream = device.SetupTxStream(format, twoChannels, streamArgsString);
            Assert.AreEqual(streamArgsMap, txStream.StreamArgs);
            txStream.Close();
        }

        public void TestRxStreaming()
        {
            var device = GetTestDevice();
            SoapySDR.StreamResult streamResult;

            var format = SoapySDR.Utility.GetFormatString<T>();

            GetStreamTestParams(
                out uint[] oneChannel,
                out uint[] twoChannels,
                out string streamArgsString,
                out Dictionary<string, string> streamArgsMap,
                out SoapySDR.StreamFlags streamFlags,
                out long timeNs,
                out int timeoutUs,
                out uint numElems);

            //
            // Test with single channel
            //

            var rxStream = device.SetupRxStream<T>(oneChannel, streamArgsMap);
            Assert.AreEqual(format, rxStream.Format);
            Assert.AreEqual(oneChannel, rxStream.Channels);
            Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
            Assert.False(rxStream.Active);

            rxStream.Activate(streamFlags, timeNs, numElems);
            Assert.AreEqual(1024, rxStream.MTU);

            T[] buff = new T[numElems];
            var mem = new Memory<T>(buff);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(ref buff, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(mem, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Deactivate(streamFlags, timeNs));
            Assert.False(rxStream.Active);
            rxStream.Close();

            //
            // Test with multiple channels
            //

            rxStream = device.SetupRxStream<T>(twoChannels, streamArgsMap);
            Assert.AreEqual(format, rxStream.Format);
            Assert.AreEqual(twoChannels, rxStream.Channels);
            Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
            Assert.False(rxStream.Active);
            Assert.AreEqual(1024, rxStream.MTU);

            rxStream.Activate(streamFlags, timeNs, numElems);
            Assert.AreEqual(1024, rxStream.MTU);

            T[][] buffs = new T[2][];
            buffs[0] = new T[numElems];
            buffs[1] = new T[numElems];
            Memory<T>[] mems = buffs.Select(buff_ => new Memory<T>(buff_)).ToArray();

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(ref buffs, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(mems, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Deactivate(streamFlags, timeNs));
            Assert.False(rxStream.Active);
            rxStream.Close();

            //
            // Briefly reopen to test with string args
            //

            rxStream = device.SetupRxStream(format, twoChannels, streamArgsString);
            Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
            rxStream.Close();
        }

        public void TestComplexRxStreaming()
        {
            var device = GetTestDevice();
            SoapySDR.StreamResult streamResult;

            var format = SoapySDR.Utility.GetComplexFormatString<T>();

            GetStreamTestParams(
                out uint[] oneChannel,
                out uint[] twoChannels,
                out string streamArgsString,
                out Dictionary<string, string> streamArgsMap,
                out SoapySDR.StreamFlags streamFlags,
                out long timeNs,
                out int timeoutUs,
                out uint numElems);

            //
            // Test with single channel
            //

            var rxStream = device.SetupComplexRxStream<T>(oneChannel, streamArgsMap);
            Assert.AreEqual(format, rxStream.Format);
            Assert.AreEqual(oneChannel, rxStream.Channels);
            Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
            Assert.False(rxStream.Active);

            rxStream.Activate(streamFlags, timeNs, numElems);
            Assert.AreEqual(1024, rxStream.MTU);

            T[] buff = new T[numElems * 2];
            var mem = new Memory<T>(buff);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(ref buff, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(mem, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Deactivate(streamFlags, timeNs));
            Assert.False(rxStream.Active);
            rxStream.Close();

            //
            // Test with multiple channels
            //

            rxStream = device.SetupComplexRxStream<T>(twoChannels, streamArgsMap);
            Assert.AreEqual(format, rxStream.Format);
            Assert.AreEqual(twoChannels, rxStream.Channels);
            Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
            Assert.False(rxStream.Active);
            Assert.AreEqual(1024, rxStream.MTU);

            rxStream.Activate(streamFlags, timeNs, numElems);
            Assert.AreEqual(1024, rxStream.MTU);

            T[][] buffs = new T[2][];
            buffs[0] = new T[numElems * 2];
            buffs[1] = new T[numElems * 2];
            Memory<T>[] mems = buffs.Select(buff_ => new Memory<T>(buff_)).ToArray();

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(ref buffs, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Read(mems, streamFlags, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, rxStream.Deactivate(streamFlags, timeNs));
            Assert.False(rxStream.Active);
            rxStream.Close();

            //
            // Briefly reopen to test with string args
            //

            rxStream = device.SetupRxStream(format, twoChannels, streamArgsString);
            Assert.AreEqual(streamArgsMap, rxStream.StreamArgs);
            rxStream.Close();
        }
    }

    //
    // Generic test factories
    //

    public static IEnumerable<IGenericStreamingTestCase> TestCases()
    {
        yield return new GenericStreamingTestCase<sbyte>();
        yield return new GenericStreamingTestCase<short>();
        yield return new GenericStreamingTestCase<int>();
        yield return new GenericStreamingTestCase<byte>();
        yield return new GenericStreamingTestCase<ushort>();
        yield return new GenericStreamingTestCase<uint>();
        yield return new GenericStreamingTestCase<float>();
        yield return new GenericStreamingTestCase<double>();
    }

    [Test]
    [TestCaseSource("TestCases")]
    public void TestTxStreaming(IGenericStreamingTestCase testCase)
    {
        testCase.TestTxStreaming();
    }

    [Test]
    [TestCaseSource("TestCases")]
    public void TestComplexTxStreaming(IGenericStreamingTestCase testCase)
    {
        testCase.TestComplexTxStreaming();
    }

    [Test]
    [TestCaseSource("TestCases")]
    public void TestRxStreaming(IGenericStreamingTestCase testCase)
    {
        testCase.TestRxStreaming();
    }

    [Test]
    [TestCaseSource("TestCases")]
    public void TestComplexRxStreaming(IGenericStreamingTestCase testCase)
    {
        testCase.TestComplexRxStreaming();
    }

    public static int Main(string[] args) => TestRunner.RunNUnitTest("TestStreamingAPI");
}