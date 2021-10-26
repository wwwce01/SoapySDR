// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Collections.Generic;
using System.Dynamic;
using System.Linq;

using NUnit.Framework;

[TestFixture]
public class TestEnumerateDevices
{
    static private bool HasNullDevice(List<Dictionary<string, string>> devices)
        => devices.Select(args => args.ContainsKey("driver") && (args["driver"] == "null")).Any();

    [Test]
    public void Test_EnumerateNoParam()
    {
        // We can't guarantee the number of devices connected to the machine, so just
        // make sure this doesn't error out.
        _ = SoapySDR.Device.Enumerate();
    }

    [Test]
    public void Test_EnumerateStringParam()
    {
        var args = "driver=null";
        Assert.IsTrue(HasNullDevice(SoapySDR.Device.Enumerate(args)));
    }

    [Test]
    public void Test_EnumerateDictParam()
    {
        // Arbitrarily use some non-standard IDictionary subclass to test the
        // interface parameter.
        dynamic args = new ExpandoObject();
        args.driver = "null";

        Assert.IsTrue(HasNullDevice(SoapySDR.Device.Enumerate(args)));
    }

    public static int Main(string[] args) => TestRunner.RunNUnitTest("TestEnumerateDevices");
}