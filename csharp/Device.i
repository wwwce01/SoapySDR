// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%include <std_pair.i>
%include <stdint.i>
%include <typemaps.i>

#ifdef SIZE_T_IS_UNSIGNED_INT
%apply uint32_t { size_t };
%apply uint32_t { uintptr_t };
#else
%apply uint64_t { size_t };
%apply uint64_t { uintptr_t };
#endif

//
// Wrapper class
//

%typemap(csimports) SoapySDR::CSharp::Device "
using System;"

%csmethodmodifiers SoapySDR::CSharp::Device::__ParallelMake "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__ToString "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__Equals "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetDriverKey "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetHardwareKey "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetHardwareInfo "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetStreamFormats "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetStreamArgsInfo "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__SetupStream "internal";
%csmethodmodifiers SoapySDR::CSharp::Device::__CloseStream "internal";
%csmethodmodifiers SoapySDR::CSharp::Device::__ActivateStream "internal";
%csmethodmodifiers SoapySDR::CSharp::Device::__DeactivateStream "internal";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetStreamMTU "internal";
%csmethodmodifiers SoapySDR::CSharp::Device::__ReadStream "internal unsafe";
%csmethodmodifiers SoapySDR::CSharp::Device::__WriteStream "internal unsafe";
%csmethodmodifiers SoapySDR::CSharp::Device::__ReadStreamStatus "internal";
%csmethodmodifiers SoapySDR::CSharp::Device::__ListAntennas "private";
%csmethodmodifiers SoapySDR::CSharp::Device::__GetPointer "private";

%apply double& OUTPUT { double& fullScaleOut };

%typemap(cscode) SoapySDR::CSharp::Device %{
    public override string ToString()
    {
        return __ToString();
    }

    public override bool Equals(object other)
    {
        var otherAsDevice = other as Device;
        if(otherAsDevice) return __Equals(otherAsDevice);
        else throw new ArgumentException("Not a Device");
    }

    public override int GetHashCode()
    {
        return (GetClass().GetHashCode() ^ __GetPointer().GetHashCode());
    }

    public static Device[] ParallelMake(Kwargs[] kwargs)
    {
        var swigArgs = new KwargsList();
        foreach(var arg in args) swigArgs.Add(arg);

        return __ParallelMake(swigArgs).ToArray();
    }

    public static Device[] ParallelMake(string[] args)
    {
        var swigArgs = new StringList();
        foreach(var arg in args) swigArgs.Add(arg);

        return __ParallelMake(swigArgs).ToArray();
    }

    public string DriverKey
    {
        get { return __GetDriverKey(); }
    }

    public string HardwareKey
    {
        get { return __GetHardwareKey(); }
    }

    public Kwargs HardwareInfo
    {
        get { return __GetHardwareInfo(); }
    }

    public string[] GetStreamFormats(Direction direction, uint channel)
    {
        return __GetStreamFormats(direction, channel).ToArray();
    }

    public ArgInfo[] GetStreamArgsInfo(Direction direction, uint channel)
    {
        return __GetStreamArgsInfo(direction, channel).ToArray();
    }

    public string[] ListAntennas(Direction direction, uint channel)
    {
        return __ListAntennas(direction, channel).ToArray();
    }
%}

%ignore SoapySDR::CSharp::DeviceDeleter;
%nodefaultctor SoapySDR::CSharp::Device;

%typemap(csclassmodifiers) std::pair<SoapySDR::CSharp::ErrorCode, SoapySDR::CSharp::StreamResult> "internal class";
%template(StreamResultPair) std::pair<SoapySDR::CSharp::ErrorCode, SoapySDR::CSharp::StreamResult>;

%{
#include "DeviceWrapper.hpp"
%}

%include "DeviceWrapper.hpp"

%typemap(csclassmodifiers) std::vector<SoapySDR::CSharp::Device> "internal class"
%template(DeviceList) std::vector<SoapySDR::CSharp::Device>;
