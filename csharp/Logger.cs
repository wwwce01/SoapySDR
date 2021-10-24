// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class Logger
    {
        public delegate void LoggerDelegate(LogLevel logLevel, string message);
        private static LoggerDelegate Delegate = null;

        private class CSharpLogHandler: LogHandlerBase
        {
            public CSharpLogHandler(): base()
            {
            }

            public void Handle(LogLevel logLevel, string message) => Delegate?.Invoke(logLevel, message);
        }

        private static CSharpLogHandler LogHandler = null;

        public static void RegisterLogger(LoggerDelegate del)
        {
            LogHandler = new CSharpLogHandler();
            Delegate = del;
        }

        public static void UnregisterLogger()
        {
            LogHandler = null;
            Delegate = null;
        }

        public static void Log(LogLevel logLevel, string message) => LogHandlerBase.Log(logLevel, message);

        public static void Log(LogLevel logLevel, string format, object arg) =>
            Log(logLevel, string.Format(format, arg));

        public static void Log(LogLevel logLevel, string format, object[] args) =>
            Log(logLevel, string.Format(format, args));

        public static void Log(LogLevel logLevel, IFormatProvider formatProvider, string format, object arg) =>
            Log(logLevel, string.Format(formatProvider, format, arg));

        public static void Log(LogLevel logLevel, IFormatProvider formatProvider, string format, object[] args) =>
            Log(logLevel, string.Format(formatProvider, format, args));

        public static void Log(LogLevel logLevel, string format, object arg0, object arg1) =>
            Log(logLevel, string.Format(format, arg0, arg1));

        public static void Log(LogLevel logLevel, IFormatProvider formatProvider, string format, object arg0, object arg1) =>
            Log(logLevel, string.Format(format, formatProvider, arg0, arg1));

        public static void Log(LogLevel logLevel, string format, object arg0, object arg1, object arg2) =>
            Log(logLevel, string.Format(format, arg0, arg1, arg2));

        public static void Log(LogLevel logLevel, IFormatProvider formatProvider, string format, object arg0, object arg1, object arg2) =>
            Log(logLevel, string.Format(format, formatProvider, arg0, arg1, arg2));

        // TODO: After GetLogLevel implemented, make a property

        public static void SetLogLevel(LogLevel logLevel) => LogHandlerBase.SetLogLevel(logLevel);
    }
}
