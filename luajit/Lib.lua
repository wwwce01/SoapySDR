-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

__internal = {}

local ffi = require("ffi")

-- The variable is global, but not the scope
__internal.SoapySDR = nil

if not __internal.SoapySDR
then
    ffi.cdef[[
        /* SoapySDR/Types.h */

        typedef struct
        {
            double minimum;
            double maximum;
            double step;
        } SoapySDRRange;

        typedef struct
        {
            size_t size;
            char **keys;
            char **vals;
        } SoapySDRKwargs;

        SoapySDRKwargs SoapySDRKwargs_fromString(const char *markup);

        char *SoapySDRKwargs_toString(const SoapySDRKwargs *args);

        typedef enum
        {
            SOAPY_SDR_ARG_INFO_BOOL,
            SOAPY_SDR_ARG_INFO_INT,
            SOAPY_SDR_ARG_INFO_FLOAT,
            SOAPY_SDR_ARG_INFO_STRING
        } SoapySDRArgInfoType;

        typedef struct
        {
            char *key;
            char *value;
            char *name;
            char *description;
            char *units;
            SoapySDRArgInfoType type;
            SoapySDRRange range;
            size_t numOptions;
            char **options;
            char **optionNames;
        } SoapySDRArgInfo;

        void SoapySDR_free(void *ptr);

        void SoapySDRStrings_clear(char ***elems, const size_t length);

        int SoapySDRKwargs_set(SoapySDRKwargs *args, const char *key, const char *val);

        const char *SoapySDRKwargs_get(const SoapySDRKwargs *args, const char *key);

        void SoapySDRKwargs_clear(SoapySDRKwargs *args);

        void SoapySDRKwargsList_clear(SoapySDRKwargs *args, const size_t length);

        void SoapySDRArgInfo_clear(SoapySDRArgInfo *info);

        void SoapySDRArgInfoList_clear(SoapySDRArgInfo *info, const size_t length);

        /* SoapySDR/Time.h */

        long long SoapySDR_ticksToTimeNs(const long long ticks, const double rate);

        long long SoapySDR_timeNsToTicks(const long long timeNs, const double rate);

        /* SoapySDR/Errors.h */

        const char *SoapySDR_errToStr(const int errorCode);

        /* SoapySDR/Formats.h */

        size_t SoapySDR_formatToSize(const char *format);

        /* SoapySDR/Logger.h */

        typedef enum
        {
            SOAPY_SDR_FATAL    = 1,
            SOAPY_SDR_CRITICAL = 2,
            SOAPY_SDR_ERROR    = 3,
            SOAPY_SDR_WARNING  = 4,
            SOAPY_SDR_NOTICE   = 5,
            SOAPY_SDR_INFO     = 6,
            SOAPY_SDR_DEBUG    = 7,
            SOAPY_SDR_TRACE    = 8,
            SOAPY_SDR_SSI      = 9
        } SoapySDRLogLevel;

        typedef void (*SoapySDRLogHandler)(const SoapySDRLogLevel logLevel, const char *message);

        void SoapySDR_registerLogHandler(const SoapySDRLogHandler handler);

        void SoapySDR_setLogLevel(const SoapySDRLogLevel logLevel);

        /* SoapySDR/Version.h */

        const char *SoapySDR_getAPIVersion(void);

        const char *SoapySDR_getABIVersion(void);

        const char *SoapySDR_getLibVersion(void);
    ]]

    __internal.SoapySDR = ffi.load("libSoapySDR", true)
end

return __internal.SoapySDR
