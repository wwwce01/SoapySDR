// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%module(directors="1") SoapySDR

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
// C#.
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
%include <stdint.i>
%include <std_complex.i>
%include <std_string.i>
%include <std_vector.i>
%include <std_map.i>

%typemap(csclassmodifiers) SoapySDR::ArgInfo "internal class"
%rename(ArgInfoInternal) SoapySDR::ArgInfo;

%ignore SoapySDR::KwargsFromString;
%ignore SoapySDR::KwargsToString;
%ignore SoapySDR::SettingToString;
%ignore SoapySDR::StringToSetting;
%ignore SoapySDR::Detail::SettingToString;
%ignore SoapySDR::Detail::StringToSetting;
%include <SoapySDR/Types.hpp>

#ifdef SIZE_T_IS_UNSIGNED_INT
%typemap(csclassmodifiers) std::vector<uint32_t> "internal class"
%template(SizeList) std::vector<uint32_t>;
#else
%typemap(csclassmodifiers) std::vector<uint64_t> "internal class"
%template(SizeList) std::vector<uint64_t>;
#endif

// Hide SWIG-generated STL types, they're ugly and half-done

%typemap(csclassmodifiers) SoapySDR::Kwargs "internal class"
%template(Kwargs) std::map<std::string, std::string>;

%typemap(csclassmodifiers) std::vector<SoapySDR::Kwargs> "internal class"
%template(KwargsList) std::vector<SoapySDR::Kwargs>;

%typemap(csclassmodifiers) std::vector<SoapySDR::ArgInfo> "internal class"
%template(ArgInfoInternalList) std::vector<SoapySDR::ArgInfo>;

%typemap(csclassmodifiers) std::vector<std::string> "internal class"
%template(StringList) std::vector<std::string>;

%typemap(csclassmodifiers) std::vector<SoapySDR::Range> "internal class"
%template(RangeList) std::vector<SoapySDR::Range>;

%typemap(csclassmodifiers) std::vector<double> "internal class"
%template(DoubleList) std::vector<double>;

////////////////////////////////////////////////////////////////////////
// Include extensions before types that will use them
////////////////////////////////////////////////////////////////////////
%nodefaultctor SoapySDR::CSharp::BuildInfo;
%nodefaultctor SoapySDR::CSharp::StreamHandle;

%include "Stream.i"

%ignore copyVector;
%ignore toSizeTVector;
%ignore reinterpretCastVector;
%ignore detail::copyVector;
%include "CSharpExtensions.hpp"

%typemap(csclassmodifiers) SoapySDR::CSharp::SettingConversion "internal class"

%template(LongToString) SoapySDR::CSharp::SettingConversion::SettingToString<int64_t>;
%template(ULongToString) SoapySDR::CSharp::SettingConversion::SettingToString<uint64_t>;
%template(BoolToString) SoapySDR::CSharp::SettingConversion::SettingToString<bool>;
%template(DoubleToString) SoapySDR::CSharp::SettingConversion::SettingToString<double>;

%template(StringToLong) SoapySDR::CSharp::SettingConversion::StringToSetting<int64_t>;
%template(StringToULong) SoapySDR::CSharp::SettingConversion::StringToSetting<uint64_t>;
%template(StringToBool) SoapySDR::CSharp::SettingConversion::StringToSetting<bool>;
%template(StringToDouble) SoapySDR::CSharp::SettingConversion::StringToSetting<double>;

%include "Device.i"
%include "Logger.i"
