// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Collections.Generic;

using NUnit.Framework;

// For the null device, functions generally don't do anything or return some
// hardcoded value, but we can still make sure functions compile and run as
// expected, especially for the added C# fanciness.

[TestFixture]
public class TestGenericStreamingAPI
{
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

    private static void GetTxStreamTestParams(
        out uint[] oneChannel,
        out uint[] twoChannels,
        out Dictionary<string, string> streamArgs,
        out SoapySDR.StreamFlags streamFlags,
        out long timeNs,
        out int timeoutUs,
        out uint numElems)
    {
        oneChannel = new uint[] { 0 };
        twoChannels = new uint[] { 0, 1 };

        streamArgs = new Dictionary<string, string>();
        streamArgs["bufflen"] = "8192";
        streamArgs["buffers"] = "15";

        streamFlags = SoapySDR.StreamFlags.HasTime | SoapySDR.StreamFlags.EndBurst;
        timeNs = 1000;
        timeoutUs = 1000;
        numElems = 1024;
    }

    //
    // Generic test interface
    //

    public interface IGenericStreamingTestCase
    {
        void TestTxStreaming();

        void TestComplexTxStreaming();
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

            GetTxStreamTestParams(
                out uint[] oneChannel,
                out uint[] twoChannels,
                out Dictionary<string, string> streamArgs,
                out SoapySDR.StreamFlags streamFlags,
                out long timeNs,
                out int timeoutUs,
                out uint numElems);
            
            //
            // Test with single channel
            //

            var txStream = device.SetupTxStream<T>(oneChannel, streamArgs);
            Assert.AreEqual(SoapySDR.Utility.GetFormatString<T>(), txStream.Format);
            Assert.AreEqual(oneChannel, txStream.Channels);
            Assert.AreEqual(streamArgs, txStream.StreamArgs);
            Assert.False(txStream.Active);
            Assert.AreEqual(1024, txStream.MTU);

            txStream.Activate(streamFlags, timeNs, numElems);
            Assert.True(txStream.Active);

            T[] buff = new T[numElems];
            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buff, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            txStream.Deactivate();
            Assert.False(txStream.Active);
            txStream.Close();

            //
            // Test with multiple channels
            //

            txStream = device.SetupTxStream<T>(twoChannels, streamArgs);
            Assert.AreEqual(SoapySDR.Utility.GetFormatString<T>(), txStream.Format);
            Assert.AreEqual(twoChannels, txStream.Channels);
            Assert.AreEqual(streamArgs, txStream.StreamArgs);
            Assert.False(txStream.Active);
            Assert.AreEqual(1024, txStream.MTU);

            txStream.Activate(streamFlags, timeNs, numElems);
            Assert.True(txStream.Active);

            T[][] buffs = new T[twoChannels.Length][];
            buffs[0] = new T[numElems];
            buffs[1] = new T[numElems];

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buffs, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            txStream.Deactivate();
            Assert.False(txStream.Active);
            txStream.Close();
        }
        public void TestComplexTxStreaming()
        {
            var device = GetTestDevice();
            SoapySDR.StreamResult streamResult;

            GetTxStreamTestParams(
                out uint[] oneChannel,
                out uint[] twoChannels,
                out Dictionary<string, string> streamArgs,
                out SoapySDR.StreamFlags streamFlags,
                out long timeNs,
                out int timeoutUs,
                out uint numElems);

            //
            // Test with single channel
            //

            var txStream = device.SetupComplexTxStream<T>(oneChannel, streamArgs);
            Assert.AreEqual(SoapySDR.Utility.GetComplexFormatString<T>(), txStream.Format);
            Assert.AreEqual(oneChannel, txStream.Channels);
            Assert.AreEqual(streamArgs, txStream.StreamArgs);
            Assert.False(txStream.Active);
            Assert.AreEqual(1024, txStream.MTU);

            txStream.Activate(streamFlags, timeNs, numElems);
            Assert.True(txStream.Active);

            T[] buff = new T[numElems];
            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buff, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            txStream.Deactivate();
            Assert.False(txStream.Active);
            txStream.Close();

            //
            // Test with multiple channels
            //

            txStream = device.SetupComplexTxStream<T>(twoChannels, streamArgs);
            Assert.AreEqual(SoapySDR.Utility.GetComplexFormatString<T>(), txStream.Format);
            Assert.AreEqual(twoChannels, txStream.Channels);
            Assert.AreEqual(streamArgs, txStream.StreamArgs);
            Assert.False(txStream.Active);
            Assert.AreEqual(1024, txStream.MTU);

            txStream.Activate(streamFlags, timeNs, numElems);
            Assert.True(txStream.Active);

            T[][] buffs = new T[twoChannels.Length][];
            buffs[0] = new T[numElems];
            buffs[1] = new T[numElems];

            Assert.AreEqual(SoapySDR.ErrorCode.NotSupported, txStream.Write(buffs, timeNs, timeoutUs, out streamResult));
            Assert.AreEqual(0, streamResult.NumSamples);
            Assert.AreEqual(streamFlags, streamResult.Flags);

            txStream.Deactivate();
            Assert.False(txStream.Active);
            txStream.Close();
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
}