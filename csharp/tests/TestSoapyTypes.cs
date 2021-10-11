// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Linq;

using NUnit.Framework;

[TestFixture]
public class TestSoapyTypes
{
    [Test]
    public void Test_ArgInfo_TypeAgnosticFields()
    {
        var key = "TestKey";
        var name = "TestName";
        var description = "TestDescription";
        var units = "TestUnits";
        var range = new SoapySDR.Range(0.0, 1.0, 0.1);
        string[] options = { "opt1", "opt2", "opt3" };
        string[] optionNames = { "Option1", "Option2", "Option3" };

        var argInfo = new SoapySDR.ArgInfo
        {
            Key = key,
            Name = name,
            Description = description,
            Units = units,
            Range = range,
            Options = options,
            OptionNames = optionNames
        };

        Assert.AreEqual(key, argInfo.Key);
        Assert.AreEqual(name, argInfo.Name);
        Assert.AreEqual(description, argInfo.Description);
        Assert.AreEqual(units, argInfo.Units);
        Assert.AreEqual(range.Minimum, argInfo.Range.Minimum);
        Assert.AreEqual(range.Maximum, argInfo.Range.Maximum);
        Assert.AreEqual(range.Step, argInfo.Range.Step);
        Assert.AreEqual(options, argInfo.Options);
        Assert.AreEqual(optionNames, argInfo.OptionNames);
    }

    [Test]
    [TestCase(SoapySDR.ArgInfo.ArgType.BOOL, false, "false")]
    [TestCase(SoapySDR.ArgInfo.ArgType.FLOAT, 135.1, "135.1")]
    [TestCase(SoapySDR.ArgInfo.ArgType.INT, (long)418, "418")]
    [TestCase(SoapySDR.ArgInfo.ArgType.STRING, "foobar", "foobar")]
    public void Test_ArgInfo_ValueStringFromValue(SoapySDR.ArgInfo.ArgType argType, object testValue, string testValueString)
    {
        var argInfo = new SoapySDR.ArgInfo
        {
            Type = argType
        };
        Assert.AreEqual(argType, argInfo.Type);

        argInfo.Value = testValue;
        Assert.AreEqual(testValue, argInfo.Value);
        Assert.AreEqual(testValueString, argInfo.ValueString);
    }

    [Test]
    [TestCase(SoapySDR.ArgInfo.ArgType.BOOL, false, "false")]
    [TestCase(SoapySDR.ArgInfo.ArgType.FLOAT, 135.1, "135.1")]
    [TestCase(SoapySDR.ArgInfo.ArgType.INT, (long)418, "418")]
    [TestCase(SoapySDR.ArgInfo.ArgType.STRING, "foobar", "foobar")]
    public void Test_ArgInfo_ValueFromValueString(SoapySDR.ArgInfo.ArgType argType, object testValue, string testValueString)
    {
        var argInfo = new SoapySDR.ArgInfo
        {
            Type = argType
        };
        Assert.AreEqual(argType, argInfo.Type);

        argInfo.ValueString = testValueString;
        Assert.AreEqual(testValue, argInfo.Value);
        Assert.AreEqual(testValueString, argInfo.ValueString);
    }

    [Test]
    public void Test_Range()
    {
        var minimum = 1.0;
        var maximum = 2.0;
        var step = 0.05;

        // No parameters
        var range1 = new SoapySDR.Range();
        Assert.AreEqual(0.0, range1.Minimum);
        Assert.AreEqual(0.0, range1.Maximum);
        Assert.AreEqual(0.0, range1.Step);

        // No step
        var range2 = new SoapySDR.Range(minimum, maximum);
        Assert.AreEqual(minimum, range2.Minimum);
        Assert.AreEqual(maximum, range2.Maximum);
        Assert.AreEqual(0.0, range2.Step);

        // All parameters
        var range3 = new SoapySDR.Range(minimum, maximum, step);
        Assert.AreEqual(minimum, range3.Minimum);
        Assert.AreEqual(maximum, range3.Maximum);
        Assert.AreEqual(step, range3.Step);
    }
}