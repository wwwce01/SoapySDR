// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class Logger
    {
        public delegate void LoggerDelegate(LogLevel logLevel, string message);
        private static LoggerDelegate loggerDelegate = null;

        private class CSharpLogHandler: LogHandlerBase
        {
            public CSharpLogHandler(): base()
            {
            }

            public void Handle(LogLevel logLevel, string message) => loggerDelegate?.Invoke(logLevel, message);
        }

        private static CSharpLogHandler LogHandler = new CSharpLogHandler();

        public static void RegisterLogger(LoggerDelegate del) => loggerDelegate = del;
    }
}
