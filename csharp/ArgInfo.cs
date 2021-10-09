// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

namespace SoapySDR
{    
    public class ArgInfo
    {
        private ArgInfoInternal argInfo = null;

        public enum ArgType
        {
            BOOL,
            INT,
            FLOAT,
            STRING
        }

        public ArgInfo()
        {
            argInfo = new ArgInfoInternal();
        }

        internal ArgInfo(ArgInfoInternal argInfoInternal)
        {
            argInfo = argInfoInternal;
        }
        
        public string Key
        {
            get => argInfo.key;
            set => argInfo.key = value;
        }

        public object Value
        {
            get => new ArgValue(argInfo.value).ToArgType(Type);
            set => argInfo.value = new ArgValue(value).ToString(null);
        }

        public string ValueString
        {
            get => argInfo.value;
            set => argInfo.value = value;
        }

        public string Name
        {
            get => argInfo.name;
            set => argInfo.name = value;
        }

        public string Description
        {
            get => argInfo.description;
            set => argInfo.description = value;
        }

        public string Units
        {
            get => argInfo.units;
            set => argInfo.units = value;
        }

        public ArgType Type
        {
            get => (ArgType)argInfo.type;
            set => argInfo.type = (ArgInfoInternal.Type)value;
        }

        public Range Range
        {
            get => argInfo.range;
            set => argInfo.range = value;
        }

        public string[] Options
        {
            get => argInfo.options.ToArray();
            set => argInfo.options = new StringList(value);
        }

        public string[] OptionNames
        {
            get => argInfo.optionNames.ToArray();
            set => argInfo.optionNames = new StringList(value);
        }
    }
}