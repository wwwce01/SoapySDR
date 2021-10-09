// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    internal class SoapyConvertible : System.IConvertible
    {
        private string _value;

        public SoapyConvertible(SoapyConvertible other) => _value = other._value;

        public SoapyConvertible(object value)
        {
            // Hopefully in order of likelihood
            if(value is string)
            {
                _value = (string)value;
            }
            else if (value is bool)
            {
                _value = SettingConversion.BoolToString((bool)value);
            }
            else if ((value is float) || (value is double) || (value is decimal))
            {
                _value = SettingConversion.DoubleToString(System.Convert.ToDouble(value));
            }
            else if ((value is sbyte) || (value is short) || (value is int) || (value is long))
            {
                _value = SettingConversion.LongToString(System.Convert.ToInt64(value));
            }
            else if ((value is byte) || (value is ushort) || (value is uint) || (value is ulong))
            {
                _value = SettingConversion.ULongToString(System.Convert.ToUInt64(value));
            }
            else _value = value.ToString(); // Good luck
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

        public TypeCode GetTypeCode()
        {
            return TypeCode.Object;
        }

        public bool ToBoolean(IFormatProvider provider)
        {
            return SettingConversion.StringToBool(_value);
        }

        public byte ToByte(IFormatProvider provider)
        {
            return (byte)SettingConversion.StringToULong(_value);
        }

        public char ToChar(IFormatProvider provider)
        {
            throw new NotImplementedException();
        }

        public DateTime ToDateTime(IFormatProvider provider)
        {
            throw new NotImplementedException();
        }

        public decimal ToDecimal(IFormatProvider provider)
        {
            return (decimal)SettingConversion.StringToDouble(_value);
        }

        public double ToDouble(IFormatProvider provider)
        {
            return SettingConversion.StringToDouble(_value);
        }

        public short ToInt16(IFormatProvider provider)
        {
            return (short)SettingConversion.StringToLong(_value);
        }

        public int ToInt32(IFormatProvider provider)
        {
            return (int)SettingConversion.StringToLong(_value);
        }

        public long ToInt64(IFormatProvider provider)
        {
            return SettingConversion.StringToLong(_value);
        }

        public sbyte ToSByte(IFormatProvider provider)
        {
            return (sbyte)SettingConversion.StringToLong(_value);
        }

        public float ToSingle(IFormatProvider provider)
        {
            return (float)SettingConversion.StringToDouble(_value);
        }

        public string ToString(IFormatProvider provider)
        {
            return _value;
        }

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

        public ushort ToUInt16(IFormatProvider provider)
        {
            return (ushort)SettingConversion.StringToULong(_value);
        }

        public uint ToUInt32(IFormatProvider provider)
        {
            return (uint)SettingConversion.StringToULong(_value);
        }

        public ulong ToUInt64(IFormatProvider provider)
        {
            return SettingConversion.StringToULong(_value);
        }

        //
        // Object overrides
        //

        public override string ToString() => ToString(null);

        public override int GetHashCode() => (GetType().GetHashCode() ^ _value.GetHashCode());

        public override bool Equals(object obj) => (obj is SoapyConvertible) && ((SoapyConvertible)obj)._value.Equals(_value);
    }
}