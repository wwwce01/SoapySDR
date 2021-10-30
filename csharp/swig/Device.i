// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%include <std_pair.i>
%include <stdint.i>
%include <typemaps.i>

//
// Wrapper class
//

%typemap(csimports) SoapySDR::CSharp::Device "
using System;"

%apply double& OUTPUT { double& fullScaleOut };

%ignore SoapySDR::CSharp::DeviceDeleter;
%nodefaultctor SoapySDR::CSharp::Device;

%typemap(csclassmodifiers) std::pair<SoapySDR::CSharp::ErrorCode, SoapySDR::CSharp::StreamResult> "internal class";
%template(StreamResultPair) std::pair<SoapySDR::CSharp::ErrorCode, SoapySDR::CSharp::StreamResult>;

%{
#include "DeviceWrapper.hpp"
%}

%rename(DeviceInternal) SoapySDR::CSharp::Device;
%typemap(csclassmodifiers) SoapySDR::CSharp::Device "internal class"
%include "DeviceWrapper.hpp"

%typemap(csclassmodifiers) std::vector<SoapySDR::CSharp::Device> "internal class"
%template(DeviceInternalList) std::vector<SoapySDR::CSharp::Device>;
