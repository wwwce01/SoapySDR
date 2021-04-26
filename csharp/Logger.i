// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%typemap(csclassmodifiers) LogHandlerBase "internal"

%ignore SoapySDR_logf;
%ignore SoapySDR_vlogf;
%ignore SoapySDR_registerLogHandler;
%ignore SoapySDR::logf;
%ignore SoapySDR::vlogf;
%ignore SoapySDR::registerLogHandler;

%feature("director:except") {
    if ($error != NULL) {
        throw Swig::DirectorMethodException();
    }
}

%feature("director") LogHandlerBase;

%inline %{
    #include "CSharpExtensions.hpp"

    class LogHandlerBase
    {
    public:
        LogHandlerBase()
        {
            globalHandle = this;
            SoapySDR::registerLogHandler(&globalHandler);
        }
        virtual ~LogHandlerBase()
        {
            globalHandle = nullptr;
            // Restore the default, C coded, log handler.
            SoapySDR::registerLogHandler(nullptr);
        }
        virtual void handle(SoapySDR::CSharp::LogLevel, const char *) = 0;

    private:
        static void globalHandler(const SoapySDR::LogLevel logLevel, const char *message)
        {
            if (globalHandle != nullptr) globalHandle->handle((SoapySDR::CSharp::LogLevel)logLevel, message);
        }

        static LogHandlerBase *globalHandle;
    };

    LogHandlerBase *LogHandlerBase::globalHandle = nullptr;
%}

/*

%insert("csharp")
%{
_SoapySDR_globalLogHandlers = [None]

class _SoapySDR_csharpLogHandler(LogHandlerBase):
    def __init__(self, handler):
        self.handler = handler
        getattr(LogHandlerBase, '__init__')(self)

    def handle(self, *args): self.handler(*args)

def registerLogHandler(handler):
    """Register a new system log handler.

    Platforms should call this to replace the default stdio handler.

    :param handler: is a callback function that's called each time an event is
    to be logged by the SoapySDR module.  It is passed the log level and the
    the log message.  The callback shouldn't return anything, but may throw
    exceptions which can be handled in turn in the csharp client code.
    Alternately, setting handler to None restores the default.

    :type handler: Callable[[int, str], None] or None

    :returns: None
    """
    if handler is None:
        _SoapySDR_globalLogHandlers[0] = None
    else:
        _SoapySDR_globalLogHandlers[0] = _SoapySDR_csharpLogHandler(handler)
%}

*/
