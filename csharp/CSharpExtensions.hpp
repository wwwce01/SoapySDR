// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

#pragma once

#include <SoapySDR/Constants.h>
#include <SoapySDR/Device.hpp>
#include <SoapySDR/Formats.hpp>
#include <SoapySDR/Time.hpp>
#include <SoapySDR/Version.hpp>

#include <string>

namespace SoapySDR { namespace CSharp {

    struct BuildInfo
    {
        static const std::string APIVersion;
        static const std::string ABIVersion;
        static const std::string LibVersion;
    };

    const std::string BuildInfo::APIVersion = SoapySDR::getAPIVersion();
    const std::string BuildInfo::ABIVersion = SoapySDR::getABIVersion();
    const std::string BuildInfo::LibVersion = SoapySDR::getLibVersion();

    enum class Direction
    {
        TX = 0,
        RX = 1
    };

    enum class StreamFlags
    {
        END_BURST    = (1 << 1),
        HAS_TIME     = (1 << 2),
        END_ABRUPT   = (1 << 3),
        ONE_PACKET   = (1 << 4),
        MORE_FRAGMENTS = (1 << 5),
        WAIT_TRIGGER = (1 << 6)
    };

    struct StreamFormats
    {
        static const std::string CF64;
        static const std::string CF32;
        static const std::string CS32;
        static const std::string CU32;
        static const std::string CS16;
        static const std::string CU16;
        static const std::string CS12;
        static const std::string CU12;
        static const std::string CS8;
        static const std::string CU8;
        static const std::string CS4;
        static const std::string CU4;
        static const std::string F64;
        static const std::string F32;
        static const std::string S32;
        static const std::string U32;
        static const std::string S16;
        static const std::string U16;
        static const std::string S8;
        static const std::string U8;

        static inline size_t FormatToSize(const std::string& format)
        {
            return SoapySDR::formatToSize(format);
        }
    };

    const std::string StreamFormats::CF64 = SOAPY_SDR_CF64;
    const std::string StreamFormats::CF32 = SOAPY_SDR_CF32;
    const std::string StreamFormats::CS32 = SOAPY_SDR_CS32;
    const std::string StreamFormats::CU32 = SOAPY_SDR_CU32;
    const std::string StreamFormats::CS16 = SOAPY_SDR_CS16;
    const std::string StreamFormats::CU16 = SOAPY_SDR_CU16;
    const std::string StreamFormats::CS12 = SOAPY_SDR_CS12;
    const std::string StreamFormats::CU12 = SOAPY_SDR_CU12;
    const std::string StreamFormats::CS8  = SOAPY_SDR_CS8;
    const std::string StreamFormats::CU8  = SOAPY_SDR_CU8;
    const std::string StreamFormats::CS4  = SOAPY_SDR_CS4;
    const std::string StreamFormats::CU4  = SOAPY_SDR_CU4;
    const std::string StreamFormats::F64  = SOAPY_SDR_F64;
    const std::string StreamFormats::F32  = SOAPY_SDR_F32;
    const std::string StreamFormats::S32  = SOAPY_SDR_S32;
    const std::string StreamFormats::U32  = SOAPY_SDR_U32;
    const std::string StreamFormats::S16  = SOAPY_SDR_S16;
    const std::string StreamFormats::U16  = SOAPY_SDR_U16;
    const std::string StreamFormats::S8   = SOAPY_SDR_S8;
    const std::string StreamFormats::U8   = SOAPY_SDR_U8;

    struct StreamHandle
    {
        SoapySDR::Stream* stream;

        // Ignored
        std::vector<size_t> channels;
        std::vector<size_t> GetChannels(){return channels;}

        // Ignored
        std::string format;
        std::string GetFormat(){return format;}
    };

    struct StreamResult
    {
        StreamResult(): ret(0), flags(0), timeNs(0), timeoutUs(0), chanMask(0){}

        int ret;
        int flags;
        long long timeNs;
        long timeoutUs;
        size_t chanMask;
    };

    struct Time
    {
        static inline long long TicksToTimeNs(const long long ticks, const double rate)
        {
            return SoapySDR::ticksToTimeNs(ticks, rate);
        }

        static inline long long TimeNsToTicks(const long long timeNs, const double rate)
        {
            return SoapySDR::timeNsToTicks(timeNs, rate);
        }
    };
}}

// Note: we can't set these enums to the equivalent #define
// because SWIG will copy the #define directly, so we'll
// enforce equality with these static_asserts.
#define ENUM_CHECK(_enum,_define) \
    static_assert(int(_enum) == _define, #_define)

ENUM_CHECK(SoapySDR::CSharp::Direction::TX, SOAPY_SDR_TX);
ENUM_CHECK(SoapySDR::CSharp::Direction::RX, SOAPY_SDR_RX);
ENUM_CHECK(SoapySDR::CSharp::StreamFlags::END_BURST, SOAPY_SDR_END_BURST);
ENUM_CHECK(SoapySDR::CSharp::StreamFlags::HAS_TIME, SOAPY_SDR_HAS_TIME);
ENUM_CHECK(SoapySDR::CSharp::StreamFlags::END_ABRUPT, SOAPY_SDR_END_ABRUPT);
ENUM_CHECK(SoapySDR::CSharp::StreamFlags::ONE_PACKET, SOAPY_SDR_ONE_PACKET);
ENUM_CHECK(SoapySDR::CSharp::StreamFlags::MORE_FRAGMENTS, SOAPY_SDR_MORE_FRAGMENTS);
ENUM_CHECK(SoapySDR::CSharp::StreamFlags::WAIT_TRIGGER, SOAPY_SDR_WAIT_TRIGGER);
