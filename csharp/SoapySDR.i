// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%module(directors="1") SoapySDR

#warning Deal with size_t/uintptr_t pain

%include <typemaps.i>
%include <std_vector.i>

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

// We need this extra layer of indirection because we want to hide a vector property
%typemap(csclassmodifiers) SoapySDR::ArgInfo "internal class"
%rename(ArgInfoInternal) SoapySDR::ArgInfo;

%ignore SoapySDR::Detail::StringToSetting; //ignore SFINAE overloads
%include <SoapySDR/Types.hpp>

// TODO: hide, SWIG-generated maps are ugly
%template(Kwargs) std::map<std::string, std::string>;

// NOTE: hide vectors, SWIG-generated C# vectors are ugly

%typemap(csclassmodifiers) std::vector<SoapySDR::Kwargs> "internal class"
%template(KwargsList) std::vector<SoapySDR::Kwargs>;

%typemap(csclassmodifiers) std::vector<SoapySDR::ArgInfo> "internal class"
%template(ArgInfoInternalList) std::vector<SoapySDR::ArgInfo>;

%typemap(csclassmodifiers) std::vector<std::string> "internal class"
%template(StringList) std::vector<std::string>;

%typemap(csclassmodifiers) std::vector<SoapySDR::Range> "internal class"
%template(RangeList) std::vector<SoapySDR::Range>;

%typemap(csclassmodifiers) std::vector<unsigned int> "internal class"
%template(UIntList) std::vector<unsigned int>;

%typemap(csclassmodifiers) std::vector<unsigned long> "internal class"
%template(ULongList) std::vector<unsigned long>;

%typemap(csclassmodifiers) std::vector<unsigned long long> "internal class"
%template(ULongLongList) std::vector<unsigned long long>;

%typemap(csclassmodifiers) std::vector<double> "internal class"
%template(DoubleList) std::vector<double>;

////////////////////////////////////////////////////////////////////////
// Include extensions before types that will use them
////////////////////////////////////////////////////////////////////////
%nodefaultctor SoapySDR::CSharp::BuildInfo;
%nodefaultctor SoapySDR::CSharp::StreamHandle;

%include "Stream.i"

%include "CSharpExtensions.hpp"

%include "Device.i"
%include "Logger.i"
