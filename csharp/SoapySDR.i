// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%module(directors="1") SoapySDR

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
%nodefaultctor SoapySDRCSharp::BuildInfo;
%nodefaultctor SoapySDRCSharp::StreamFormats;
%nodefaultctor SoapySDRCSharp::Time;
%include "CSharpExtensions.hpp"

/*

%extend std::map<std::string, std::string>
{
    %insert("python")
    %{
        def __str__(self):
            out = list()
            for k, v in self.iteritems():
                out.append("%s=%s"%(k, v))
            return '{'+(', '.join(out))+'}'
    %}
};

%extend SoapySDR::Range
{
    %insert("python")
    %{
        def __str__(self):
            fields = [self.minimum(), self.maximum()]
            if self.step() != 0.0: fields.append(self.step())
            return ', '.join(['%g'%f for f in fields])
    %}
};

*/

////////////////////////////////////////////////////////////////////////
// Stream result class
// Helps us deal with stream calls that return by reference
////////////////////////////////////////////////////////////////////////
%inline %{
    struct StreamResult
    {
        StreamResult(void):
            ret(0), flags(0), timeNs(0), chanMask(0){}
        int ret;
        int flags;
        long long timeNs;
        size_t chanMask;
    };
%}

/*
%extend StreamResult
{
    %insert("python")
    %{
        def __str__(self):
            return "ret=%s, flags=%s, timeNs=%s"%(self.ret, self.flags, self.timeNs)
    %}
};
*/

////////////////////////////////////////////////////////////////////////
// Constants SOAPY_SDR_*
////////////////////////////////////////////////////////////////////////
//%include <SoapySDR/Constants.h>
//import types.h for the defines
//these ignores are C++ functions that were taken by %template() above
%ignore SoapySDRKwargs;
%ignore SoapySDRKwargs_clear;
%ignore SoapySDRKwargsList_clear;
%ignore SoapySDRArgInfoList_clear;

/*

////////////////////////////////////////////////////////////////////////
// Logging tie-ins for python
////////////////////////////////////////////////////////////////////////
%ignore SoapySDR_logf;
%ignore SoapySDR_vlogf;
%ignore SoapySDR_registerLogHandler;
%ignore SoapySDR::logf;
%ignore SoapySDR::vlogf;
%ignore SoapySDR::registerLogHandler;
%include <SoapySDR/Logger.h>
%include <SoapySDR/Logger.hpp>

%feature("director:except") {
    if ($error != NULL) {
        throw Swig::DirectorMethodException();
    }
}


%feature("director") _SoapySDR_pythonLogHandlerBase;

%inline %{
    class _SoapySDR_pythonLogHandlerBase
    {
    public:
        _SoapySDR_pythonLogHandlerBase(void)
        {
            globalHandle = this;
            SoapySDR::registerLogHandler(&globalHandler);
        }
        virtual ~_SoapySDR_pythonLogHandlerBase(void)
        {
            globalHandle = nullptr;
            // Restore the default, C coded, log handler.
            SoapySDR::registerLogHandler(nullptr);
        }
        virtual void handle(const SoapySDR::LogLevel, const char *) = 0;

    private:
        static void globalHandler(const SoapySDR::LogLevel logLevel, const char *message)
        {
            if (globalHandle != nullptr) globalHandle->handle(logLevel, message);
        }

        static _SoapySDR_pythonLogHandlerBase *globalHandle;
    };
%}

%{
    _SoapySDR_pythonLogHandlerBase *_SoapySDR_pythonLogHandlerBase::globalHandle = nullptr;
%}

%insert("python")
%{
_SoapySDR_globalLogHandlers = [None]

class _SoapySDR_pythonLogHandler(_SoapySDR_pythonLogHandlerBase):
    def __init__(self, handler):
        self.handler = handler
        getattr(_SoapySDR_pythonLogHandlerBase, '__init__')(self)

    def handle(self, *args): self.handler(*args)

def registerLogHandler(handler):
    """Register a new system log handler.

    Platforms should call this to replace the default stdio handler.

    :param handler: is a callback function that's called each time an event is
    to be logged by the SoapySDR module.  It is passed the log level and the
    the log message.  The callback shouldn't return anything, but may throw
    exceptions which can be handled in turn in the Python client code.
    Alternately, setting handler to None restores the default.

    :type handler: Callable[[int, str], None] or None

    :returns: None
    """
    if handler is None:
        _SoapySDR_globalLogHandlers[0] = None
    else:
        _SoapySDR_globalLogHandlers[0] = _SoapySDR_pythonLogHandler(handler)
%}
*/

////////////////////////////////////////////////////////////////////////
// Utility functions
////////////////////////////////////////////////////////////////////////
/*
%include <SoapySDR/Errors.hpp>
%include <SoapySDR/Version.hpp>
%include <SoapySDR/Modules.hpp>
%include <SoapySDR/Formats.hpp>
%include <SoapySDR/Time.hpp>


%ignore SoapySDR::logf;
%ignore SoapySDR::vlogf;
%ignore SoapySDR::registerLogHandler;
%include <SoapySDR/Logger.hpp>
*/

%include "Device.i"
