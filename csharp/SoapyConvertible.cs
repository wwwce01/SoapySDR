// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class SoapyConvertible : System.IConvertible
    {
        private string _value;

        public SoapyConvertible(SoapyConvertible other) => _value = other._value;

        public SoapyConvertible(object value)
        {
            switch (value)
            {
                case string _:
                    _value = (string)value;
                    break;
                case bool _:
                    _value = TypeConversion.BoolToString((bool)value);
                    break;
                case float _:
                    _value = TypeConversion.FloatToString((float)value);
                    break;
                case double _:
                    _value = TypeConversion.DoubleToString((double)value);
                    break;
                case decimal _:
                    _value = TypeConversion.DoubleToString(Convert.ToDouble(value));
                    break;
                case sbyte _:
                    _value = TypeConversion.SByteToString((sbyte)value);
                    break;
                case short _:
                    _value = TypeConversion.ShortToString((short)value);
                    break;
                case int _:
                    _value = TypeConversion.IntToString((int)value);
                    break;
                case long _:
                    _value = TypeConversion.LongToString((long)value);
                    break;
                case byte _:
                    _value = TypeConversion.ByteToString((byte)value);
                    break;
                case ushort _:
                    _value = TypeConversion.UShortToString((ushort)value);
                    break;
                case uint _:
                    _value = TypeConversion.UIntToString((uint)value);
                    break;
                case ulong _:
                    _value = TypeConversion.ULongToString((ulong)value);
                    break;
                default:
                    _value = value.ToString(); // Good luck
                    break;
            }
        }

        public object ToArgType(ArgInfo.ArgType argType)
        {
            switch (argType)
            {
                case ArgInfo.ArgType.BOOL: return ToType(typeof(bool), null);
                case ArgInfo.ArgType.INT: return ToType(typeof(long), null);
                case ArgInfo.ArgType.FLOAT: return ToType(typeof(double), null);
                default: return _value;
            }
        }

        //
        // IConvertible overrides
        //

        public TypeCode GetTypeCode() => TypeCode.Object;

        public bool ToBoolean(IFormatProvider provider) => TypeConversion.StringToBool(_value);

        public byte ToByte(IFormatProvider provider) => TypeConversion.StringToByte(_value);

        public char ToChar(IFormatProvider provider) => throw new NotImplementedException();

        public DateTime ToDateTime(IFormatProvider provider) => throw new NotImplementedException();

        public decimal ToDecimal(IFormatProvider provider) => (decimal)TypeConversion.StringToDouble(_value);

        public double ToDouble(IFormatProvider provider) => TypeConversion.StringToDouble(_value);

        public short ToInt16(IFormatProvider provider) => TypeConversion.StringToShort(_value);

        public int ToInt32(IFormatProvider provider) => TypeConversion.StringToInt(_value);

        public long ToInt64(IFormatProvider provider) => TypeConversion.StringToLong(_value);

        public sbyte ToSByte(IFormatProvider provider) => TypeConversion.StringToSByte(_value);

        public float ToSingle(IFormatProvider provider) => TypeConversion.StringToFloat(_value);

        public string ToString(IFormatProvider provider) => _value;

        public object ToType(Type conversionType, IFormatProvider provider)
        {
            if (conversionType.Equals(typeof(string))) return ToString(provider);
            if (conversionType.Equals(typeof(bool))) return ToBoolean(provider);
            if (conversionType.Equals(typeof(sbyte))) return ToSByte(provider);
            if (conversionType.Equals(typeof(short))) return ToInt16(provider);
            if (conversionType.Equals(typeof(int))) return ToInt32(provider);
            if (conversionType.Equals(typeof(long))) return ToInt64(provider);
            if (conversionType.Equals(typeof(byte))) return ToByte(provider);
            if (conversionType.Equals(typeof(ushort))) return ToUInt16(provider);
            if (conversionType.Equals(typeof(uint))) return ToUInt32(provider);
            if (conversionType.Equals(typeof(ulong))) return ToUInt64(provider);
            if (conversionType.Equals(typeof(float))) return ToSingle(provider);
            if (conversionType.Equals(typeof(double))) return ToDouble(provider);
            if (conversionType.Equals(typeof(decimal))) return ToDecimal(provider);

            throw new NotImplementedException(conversionType.FullName);
        }

        public ushort ToUInt16(IFormatProvider provider) => TypeConversion.StringToUShort(_value);

        public uint ToUInt32(IFormatProvider provider) => TypeConversion.StringToUInt(_value);

        public ulong ToUInt64(IFormatProvider provider) => TypeConversion.StringToULong(_value);

        //
        // Object overrides
        //

        public override string ToString() => ToString(null);

        public override int GetHashCode() => GetType().GetHashCode() ^ _value.GetHashCode();

        public override bool Equals(object obj) => (obj as SoapyConvertible)?._value.Equals(_value) ?? false;
    }
}