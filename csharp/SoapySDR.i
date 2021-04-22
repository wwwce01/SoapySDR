// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%module(directors="1") SoapySDR

%include <typemaps.i>

////////////////////////////////////////////////////////////////////////
// Include all major headers to compile against
////////////////////////////////////////////////////////////////////////
%{
#include <SoapySDR/Version.hpp>
#include <SoapySDR/Modules.hpp>
#include <SoapySDR/Device.hpp>
#include <SoapySDR/Errors.hpp>
#include <SoapySDR/Formats.hpp>
#include <SoapySDR/Time.hpp>
#include <SoapySDR/Logger.hpp>

#include "CSharpExtensions.hpp"
%}

////////////////////////////////////////////////////////////////////////
// http://www.swig.org/Doc2.0/Library.html#Library_stl_exceptions
////////////////////////////////////////////////////////////////////////
%include <exception.i>

// We only expect to throw DirectorExceptions from within
// SoapySDR_csharpLogHandlerBase calls.  Catching them permits us to
// propagate exceptions thrown in the C# log handler callback back to
// C#. TODO: restore, appears to need to be done differently
%exception
{
    try{$action}
    SWIG_CATCH_STDEXCEPT
    catch (...)
    {SWIG_exception(SWIG_RuntimeError, "unknown");}
}

////////////////////////////////////////////////////////////////////////
// Config header defines API export
////////////////////////////////////////////////////////////////////////
%include <SoapySDR/Config.h>

////////////////////////////////////////////////////////////////////////
// Commonly used data types
////////////////////////////////////////////////////////////////////////
%include <std_complex.i>
%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>
%ignore SoapySDR::Detail::StringToSetting; //ignore SFINAE overloads
%include <SoapySDR/Types.hpp>

//handle arm 32-bit case where size_t and unsigned are the same
#ifdef SIZE_T_IS_UNSIGNED_INT
%typedef unsigned int size_t;
#else
%template(UnsignedList) std::vector<unsigned>;
#endif

%template(Kwargs) std::map<std::string, std::string>;
%template(KwargsList) std::vector<SoapySDR::Kwargs>;
%template(ArgInfoList) std::vector<SoapySDR::ArgInfo>;
%template(StringList) std::vector<std::string>;
%template(RangeList) std::vector<SoapySDR::Range>;
%template(SizeList) std::vector<size_t>;
%template(DoubleList) std::vector<double>;
%template(DeviceList) std::vector<SoapySDR::Device *>;

////////////////////////////////////////////////////////////////////////
// Include extensions before types that will use them
////////////////////////////////////////////////////////////////////////
%nodefaultctor SoapySDR::CSharp::BuildInfo;
%nodefaultctor SoapySDR::CSharp::StreamHandle;
%ignore SoapySDR::CSharp::StreamHandle::stream;
%nodefaultctor SoapySDR::CSharp::StreamFormats;
%nodefaultctor SoapySDR::CSharp::Time;
%include "CSharpExtensions.hpp"
