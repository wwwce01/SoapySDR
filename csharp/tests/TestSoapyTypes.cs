// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Linq;

using NUnit.Framework;

[TestFixture]
public class TestSoapyTypes
{
    // TODO: test range after new class made
    [Test]
    public void Test_ArgInfo_TypeAgnosticFields()
    {
        var key = "TestKey";
        var name = "TestName";
        var description = "TestDescription";
        var units = "TestUnits";
        string[] options = { "opt1", "opt2", "opt3" };
        string[] optionNames = { "Option1", "Option2", "Option3" };

        var argInfo = new SoapySDR.ArgInfo
        {
            Key = key,
            Name = name,
            Description = description,
            Units = units,
            Options = options,
            OptionNames = optionNames
        };

        Assert.AreEqual(key, argInfo.Key);
        Assert.AreEqual(name, argInfo.Name);
        Assert.AreEqual(description, argInfo.Description);
        Assert.AreEqual(units, argInfo.Units);
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

    }
}