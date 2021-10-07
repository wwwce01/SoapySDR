// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

namespace SoapySDR
{    
    public class ArgInfo
    {
        private ArgInfoInternal argInfo = null;
        
        public string Key => argInfo.key;
    }
}