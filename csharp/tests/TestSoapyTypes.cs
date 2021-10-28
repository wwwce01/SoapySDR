// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System.Collections.Generic;
using System.Linq;

using NUnit.Framework;

[TestFixture]
public class TestSoapyTypes
{
    //
    // SoapyConvertible
    //

    public interface IGenericConvertibleTestCase
    {
        void Test();
    }

    public class GenericIntConvertibleTestCase<T>: IGenericConvertibleTestCase where T: unmanaged
    {
        public void Test()
        {
            var inputString = "-123";

            var intermediate = new SoapySDR.SoapyConvertible(inputString).ToType(typeof(T), null);
            Assert.AreEqual(typeof(T), intermediate.GetType());

            var outputString = new SoapySDR.SoapyConvertible(intermediate).ToString();
            Assert.AreEqual(inputString, outputString);
        }
    }

    public class GenericUIntConvertibleTestCase<T> : IGenericConvertibleTestCase where T : unmanaged
    {
        public void Test()
        {
            var inputString = "123";

            var intermediate = new SoapySDR.SoapyConvertible(inputString).ToType(typeof(T), null);
            Assert.AreEqual(typeof(T), intermediate.GetType());

            var outputString = new SoapySDR.SoapyConvertible(intermediate).ToString();
            Assert.AreEqual(inputString, outputString);
        }
    }

    public class GenericFloatConvertibleTestCase<T> : IGenericConvertibleTestCase where T : unmanaged
    {
        public void Test()
        {
            var inputString = "418.4063";

            var intermediateNum = new SoapySDR.SoapyConvertible(inputString).ToType(typeof(T), null);
            Assert.AreEqual(typeof(T), intermediateNum.GetType());

            var intermediateString = new SoapySDR.SoapyConvertible(intermediateNum).ToString();
            var outputNum = new SoapySDR.SoapyConvertible(intermediateString).ToType(typeof(T), null);
            Assert.AreEqual(intermediateNum, outputNum);
        }
    }
    public static IEnumerable<IGenericConvertibleTestCase> ConvertibleTestCases()
    {
        yield return new GenericIntConvertibleTestCase<sbyte>();
        yield return new GenericIntConvertibleTestCase<short>();
        yield return new GenericIntConvertibleTestCase<int>();
        yield return new GenericIntConvertibleTestCase<long>();
        yield return new GenericUIntConvertibleTestCase<byte>();
        yield return new GenericUIntConvertibleTestCase<ushort>();
        yield return new GenericUIntConvertibleTestCase<uint>();
        yield return new GenericUIntConvertibleTestCase<ulong>();
        yield return new GenericFloatConvertibleTestCase<float>();
        yield return new GenericFloatConvertibleTestCase<double>();
        yield return new GenericFloatConvertibleTestCase<decimal>();
    }

    [Test]
    [TestCaseSource("ConvertibleTestCases")]
    public void TestConvertible(IGenericConvertibleTestCase testCase)
    {
        testCase.Test();
    }

    static void testNumericConvertible(
        SoapySDR.SoapyConvertible convertible,
        int expectedNum,
        string expectedStr)
    {
        Assert.AreEqual((sbyte)expectedNum, convertible.ToSByte(null));
        Assert.AreEqual((short)expectedNum, convertible.ToInt16(null));
        Assert.AreEqual(expectedNum, convertible.ToInt32(null));
        Assert.AreEqual((long)expectedNum, convertible.ToInt64(null));
        Assert.AreEqual((byte)expectedNum, convertible.ToByte(null));
        Assert.AreEqual((ushort)expectedNum, convertible.ToUInt16(null));
        Assert.AreEqual((uint)expectedNum, convertible.ToUInt32(null));
        Assert.AreEqual((ulong)expectedNum, convertible.ToUInt64(null));
        Assert.AreEqual((float)expectedNum, convertible.ToSingle(null));
        Assert.AreEqual((double)expectedNum, convertible.ToDouble(null));
        Assert.AreEqual((decimal)expectedNum, convertible.ToDecimal(null));
        Assert.AreEqual(expectedStr, convertible.ToString(null)); // IConvertible
        Assert.AreEqual(expectedStr, convertible.ToString()); // object
    }

    [Test]
    public void TestConvertible()
    {
        const int num = 123;
        const string str = "123";

        testNumericConvertible(new SoapySDR.SoapyConvertible(num), num, str);
        testNumericConvertible(new SoapySDR.SoapyConvertible(str), num, str);

        Assert.IsTrue(new SoapySDR.SoapyConvertible("true").ToBoolean(null));
        Assert.IsFalse(new SoapySDR.SoapyConvertible("false").ToBoolean(null));

        Assert.Throws<System.NotImplementedException>(delegate { new SoapySDR.SoapyConvertible(num).ToChar(null); });
        Assert.Throws<System.NotImplementedException>(delegate { new SoapySDR.SoapyConvertible(num).ToDateTime(null); });
    }

    //
    // ArgInfo
    //

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
    [TestCase(SoapySDR.ArgInfo.ArgType.FLOAT, 135.1, "135.100000")]
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
    [TestCase(SoapySDR.ArgInfo.ArgType.FLOAT, 135.1, "135.100000")]
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

    //
    // Range
    //

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

    public static int Main(string[] args) => TestRunner.RunNUnitTest("TestSoapyTypes");
}