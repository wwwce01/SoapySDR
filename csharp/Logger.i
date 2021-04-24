// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%insert(runtime) %{

#include "CSharpExtensions.hpp"

#include <SoapySDR/Logger.hpp>

typedef void(SWIGSTDCALL* SoapySDRCSharpLogHandler)(SoapySDR::CSharp::LogLevel logLevel, const std::string& message);

static SoapySDRCSharpLogHandler CSharpLogHandler = nullptr;

%}

%pragma(csharp) imclasscode=%{
    internal class SoapySDRLogHelper
    {
        public delegate SoapySDRLogDelegate(LogLevel logLevel, string message);
        static SoapySDRLogDelegate logDelegate = new SoapySDRLogDelegate(DefaultLog);

        [global::System.Runtime.InteropServices.DllImport("$dllimport", EntryPoint="RegisterSoapySDRCSharpLogHandler")]
        private public static extern void RegisterSoapySDRCSharpLogHandler(SoapySDRLogDelegate logDelegate);

        private static void DefaultLog(LogLevel logLevel, string message)
        {
            System.Console.Error(logLevel.ToString() + ": " + message);
        }

        public static void RegisterLogHandler(SoapySDRLogDelegate logDelegate)
        {
            logDelegate = del;
        }

        static SoapySDRLogHelper()
        {
            RegisterSoapySDRCSharpLogHandler(logDelegate);
        }
    };
%}

%{

extern "C"
{
    SWIGEXPORT void SWIGSTDCALL RegisterSoapySDRCSharpLogHandler(SoapySDRCSharpLogHandler logHandler)
    {
        CSharpLogHandler = logHandler;
    }
}

%}
