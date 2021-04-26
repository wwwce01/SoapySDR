// Copyright (c) 2020-201 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class Logger
    {
        public delegate LoggerDelegate(LogLevel logLevel, string message);
        private static LoggerDelegate loggerDelegate = null;

        private class CSharpLogHandler: LogHandlerBase
        {
            public CSharpLogHandler(): LogHandlerBase()
            {
            }

            public void handle(LogLevel logLevel, string message)
            {
                if(loggerDelegate != null) loggerDelegate(logLevel, message);
            }
        }

        private static CSharpLogHandler LogHandler = new CSharpLogHandler();

        public static void RegisterLogger(LoggerDelegate del)
        {
            loggerDelegate = del;
        }
    }
}
