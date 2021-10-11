// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

namespace SoapySDR
{    
    public class ArgInfo
    {
        private ArgInfoInternal _argInfo = null;

        public enum ArgType
        {
            BOOL,
            INT,
            FLOAT,
            STRING
        }

        public ArgInfo() => _argInfo = new ArgInfoInternal();

        internal ArgInfo(ArgInfoInternal argInfoInternal) => _argInfo = argInfoInternal;

        public string Key
        {
            get => _argInfo.key;
            set => _argInfo.key = value;
        }

        public object Value
        {
            get => new SoapyConvertible(_argInfo.value).ToArgType(Type);
            set => _argInfo.value = new SoapyConvertible(value).ToString(null);
        }

        public string ValueString
        {
            get => _argInfo.value;
            set => _argInfo.value = value;
        }

        public string Name
        {
            get => _argInfo.name;
            set => _argInfo.name = value;
        }

        public string Description
        {
            get => _argInfo.description;
            set => _argInfo.description = value;
        }

        public string Units
        {
            get => _argInfo.units;
            set => _argInfo.units = value;
        }

        public ArgType Type
        {
            get => (ArgType)_argInfo.type;
            set => _argInfo.type = (ArgInfoInternal.Type)value;
        }

        public Range Range
        {
            get => new Range(_argInfo.range);
            set => _argInfo.range = value._range;
        }

        public string[] Options
        {
            get => _argInfo.options.ToArray();
            set => _argInfo.options = new StringList(value);
        }

        public string[] OptionNames
        {
            get => _argInfo.optionNames.ToArray();
            set => _argInfo.optionNames = new StringList(value);
        }

        // TODO: object overrides
    }
}