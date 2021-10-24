// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%ignore SoapySDR::CSharp::StreamHandle::stream;
%ignore SoapySDR::CSharp::StreamHandle::channels;
%csmethodmodifiers SoapySDR::CSharp::StreamHandle::GetChannels "internal";
%ignore SoapySDR::CSharp::StreamHandle::format;
%csmethodmodifiers SoapySDR::CSharp::StreamHandle::GetFormat "internal";
%csmethodmodifiers SoapySDR::CSharp::StreamHandle::GetPointer "internal";
%nodefaultctor SoapySDR::CSharp::StreamFormat;

// Allows bitwise operations
%typemap(csimports) SoapySDR::CSharp::StreamFlags "
using System;"
%typemap(csclassmodifiers) SoapySDR::CSharp::StreamFlags "[Flags]
public enum"

%typemap(csimports) SoapySDR::CSharp::StreamHandle "
using System;"
%typemap(cscode) SoapySDR::CSharp::StreamHandle %{
    public override string ToString()
    {
        return string.Format("Opaque SoapySDR stream handle at {0}", GetPointer());
    }

    public override bool Equals(object other)
    {
        var otherAsStreamHandle = other as StreamHandle;
        if(otherAsStreamHandle != null) return (GetHashCode() == other.GetHashCode());
        else                            throw new ArgumentException("Not a StreamHandle");
    }

    public override int GetHashCode()
    {
        return (GetType().GetHashCode() ^ GetPointer().GetHashCode());
    }
%}
