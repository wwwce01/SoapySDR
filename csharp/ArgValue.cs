// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class ArgValue : System.IConvertible
    {
        private string _value;

        public ArgValue(ArgValue other) => _value = other._value;

        public ArgValue(object value)
        {
            // Hopefully in order of likelihood
            if (value is bool)
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
            throw new NotImplementedException();
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
    }
}