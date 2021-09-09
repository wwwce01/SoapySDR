// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

#pragma once

#include "CSharpExtensions.hpp"

#include <SoapySDR/Device.hpp>

#include <algorithm>
#include <cassert>
#include <cstdio>
#include <memory>
#include <utility>

using StreamResultPair = std::pair<SoapySDR::CSharp::ErrorCode, SoapySDR::CSharp::StreamResult>;

// We're separately using a separate thin wrapper for two reasons:
// * To abstract away the make() and unmake() calls, which SWIG won't
//   deal with well.
// * To avoid exposing a function without converting its naming convention
//   to that of C#.
namespace SoapySDR { namespace CSharp {

    struct DeviceDeleter
    {
        void operator()(SoapySDR::Device* pDevice)
        {
            // unmake can throw, which is bad in destructors.
            try { SoapySDR::Device::unmake(pDevice); }
            catch(const std::exception& ex) { fputs(ex.what(), stderr); }
            catch(...) { fputs("Unknown error.", stderr); }
        }
    };

    class Device
    {
        public:
            using DeviceVector = std::vector<SoapySDR::CSharp::Device>;

            Device(const Kwargs& kwargs): _deviceSPtr(SoapySDR::Device::make(kwargs), DeviceDeleter())
            {}

            Device(const std::string& args): _deviceSPtr(SoapySDR::Device::make(args), DeviceDeleter())
            {}

            //
            // Parallel support
            //

            static DeviceVector __ParallelMake(const SoapySDR::KwargsList& kwargsList)
            {
                const auto devs = SoapySDR::Device::make(kwargsList);
                DeviceVector csharpDevs;

                // Note: transfers ownership to C# class
                std::transform(
                    devs.begin(),
                    devs.end(),
                    std::back_inserter(csharpDevs),
                    [](SoapySDR::Device* pDev){ return Device(pDev); });

                return csharpDevs;
            }

            static DeviceVector __ParallelMake(const std::vector<std::string>& argsList)
            {
                const auto devs = SoapySDR::Device::make(argsList);
                DeviceVector csharpDevs;

                // Note: transfers ownership to C# class
                std::transform(
                    devs.begin(),
                    devs.end(),
                    std::back_inserter(csharpDevs),
                    [](SoapySDR::Device* pDev){ return Device(pDev); });

                return csharpDevs;
            }

            //
            // Identification API (all private, to be used as properties)
            //

            inline std::string __GetDriverKey() const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getDriverKey();
            }

            inline std::string __GetHardwareKey() const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getHardwareKey();
            }

            // TODO: expose Kwargs?
            inline SoapySDR::Kwargs __GetHardwareInfo() const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getHardwareInfo();
            }

            //
            // Channels API
            //

            inline void SetFrontendMapping(
                SoapySDR::CSharp::Direction direction,
                const std::string& mapping)
            {
                assert(_deviceSPtr);

                return _deviceSPtr->setFrontendMapping(int(direction), mapping);
            }

            inline std::string GetFrontendMapping(SoapySDR::CSharp::Direction direction) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getFrontendMapping(int(direction));
            }

            inline size_t GetNumChannels(SoapySDR::CSharp::Direction direction) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getNumChannels(int(direction));
            }

            inline SoapySDR::Kwargs GetChannelInfo(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getChannelInfo(int(direction), channel);
            }

            inline bool GetFullDuplex(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getFullDuplex(int(direction), channel);
            }

            //
            // Stream API
            //

            inline std::vector<std::string> __GetStreamFormats(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getStreamFormats(int(direction), channel);
            }

            inline std::string GetNativeStreamFormat(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                double &fullScaleOut) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getNativeStreamFormat(int(direction), channel, fullScaleOut);
            }

            inline SoapySDR::ArgInfoList __GetStreamArgsInfo(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getStreamArgsInfo(int(direction), channel);
            }

            SoapySDR::CSharp::StreamHandle __SetupStream(
                SoapySDR::CSharp::Direction direction,
                const std::string& format,
                const std::vector<size_t>& channels,
                const SoapySDR::Kwargs& kwargs)
            {
                assert(_deviceSPtr);

                SoapySDR::CSharp::StreamHandle streamHandle;
                streamHandle.stream = _deviceSPtr->setupStream(int(direction), format, channels, kwargs);
                streamHandle.channels = channels;

                return streamHandle;
            }

            inline void __CloseStream(const SoapySDR::CSharp::StreamHandle& streamHandle)
            {
                assert(_deviceSPtr);

                _deviceSPtr->closeStream(streamHandle.stream);
            }

            inline size_t __GetStreamMTU(const SoapySDR::CSharp::StreamHandle& streamHandle)
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getStreamMTU(streamHandle.stream);
            }

            inline SoapySDR::CSharp::ErrorCode __ActivateStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const SoapySDR::CSharp::StreamFlags flags,
                const long long timeNs,
                const size_t numElems)
            {
                assert(_deviceSPtr);

                return SoapySDR::CSharp::ErrorCode(_deviceSPtr->activateStream(
                    streamHandle.stream,
                    int(flags),
                    timeNs,
                    numElems));
            }

            inline SoapySDR::CSharp::ErrorCode __DeactivateStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const SoapySDR::CSharp::StreamFlags flags,
                const long long timeNs)
            {
                assert(_deviceSPtr);

                return SoapySDR::CSharp::ErrorCode(_deviceSPtr->deactivateStream(
                    streamHandle.stream,
                    int(flags),
                    timeNs));
            }

            //
            // TODO: SWIG typemap hackery can get us the "out StreamResult" we want
            //

            StreamResultPair __ReadStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const std::vector<size_t>& buffs,
                const size_t numElems,
                const SoapySDR::CSharp::StreamFlags flags,
                const long long timeNs,
                const long timeoutUs)
            {
                assert(_deviceSPtr);

                StreamResultPair resultPair;
                auto& errorCode = resultPair.first;
                auto& result = resultPair.second;

                std::vector<void*> buffPtrs(buffs.size());
                std::transform(
                    buffs.begin(),
                    buffs.end(),
                    std::back_inserter(buffPtrs),
                    [](const size_t buffNum)
                    { return reinterpret_cast<void*>(buffNum); });

                auto intFlags = int(flags);
                auto cppRet = _deviceSPtr->readStream(streamHandle.stream, buffPtrs.data(), numElems, intFlags, result.TimeNs, result.TimeoutUs);
                result.Flags = SoapySDR::CSharp::StreamFlags(intFlags);

                if(cppRet >= 0) result.NumSamples = static_cast<size_t>(cppRet);
                else            errorCode = static_cast<SoapySDR::CSharp::ErrorCode>(cppRet);

                return resultPair;
            }

            StreamResultPair __WriteStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const std::vector<size_t>& buffs,
                const size_t numElems,
                const long long timeNs,
                const long timeoutUs)
            {
                assert(_deviceSPtr);

                StreamResultPair resultPair;
                auto& errorCode = resultPair.first;
                auto& result = resultPair.second;

                std::vector<const void*> buffPtrs;
                std::transform(
                    buffs.begin(),
                    buffs.end(),
                    std::back_inserter(buffPtrs),
                    [](const size_t buffNum)
                    { return reinterpret_cast<const void*>(buffNum); });

                int intFlags = 0;
                auto cppRet = _deviceSPtr->writeStream(streamHandle.stream, buffPtrs.data(), numElems, intFlags, timeNs, timeoutUs);
                result.Flags = SoapySDR::CSharp::StreamFlags(intFlags);

                if(cppRet >= 0) result.NumSamples = static_cast<size_t>(cppRet);
                else            errorCode = static_cast<SoapySDR::CSharp::ErrorCode>(cppRet);

                return resultPair;
            }

            StreamResultPair __ReadStreamStatus(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const long timeoutUs)
            {
                assert(_deviceSPtr);

                StreamResultPair resultPair;
                auto& errorCode = resultPair.first;
                auto& result = resultPair.second;

                int intFlags = 0;
                errorCode = SoapySDR::CSharp::ErrorCode(_deviceSPtr->readStreamStatus(
                    streamHandle.stream,
                    result.ChanMask,
                    intFlags,
                    result.TimeNs,
                    result.TimeoutUs));
                result.Flags = SoapySDR::CSharp::StreamFlags(intFlags);

                return resultPair;
            }

            //
            // Antenna API
            //

            inline std::vector<std::string> __ListAntennas(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->listAntennas(int(direction), channel);
            }

            inline void SetAntenna(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                const std::string& name)
            {
                assert(_deviceSPtr);

                _deviceSPtr->setAntenna(int(direction), channel, name);
            }

            inline std::string GetAntenna(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getAntenna(int(direction), channel);
            }

            //
            // Frontend corrections API
            //

            inline bool HasDCOffsetMode(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->hasDCOffsetMode(int(direction), channel);
            }

            inline void SetDCOffsetMode(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                const bool automatic)
            {
                assert(_deviceSPtr);

                return _deviceSPtr->setDCOffsetMode(int(direction), channel, automatic);
            }

            inline bool HasDCOffset(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->hasDCOffset(int(direction), channel);
            }

            inline void SetDCOffset(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                const std::complex<double>& offset)
            {
                assert(_deviceSPtr);

                _deviceSPtr->setDCOffset(int(direction), channel, offset);
            }

            inline std::complex<double> GetDCOffset(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getDCOffset(int(direction), channel);
            }

            inline bool HasIQBalance(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->hasIQBalance(int(direction), channel);
            }

            inline void SetIQBalance(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                const std::complex<double>& balance)
            {
                assert(_deviceSPtr);

                _deviceSPtr->setIQBalance(int(direction), channel, balance);
            }

            inline std::complex<double> GetIQBalance(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getIQBalance(int(direction), channel);
            }

            inline bool HasIQBalanceMode(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->hasIQBalanceMode(int(direction), channel);
            }

            inline void SetIQBalanceMode(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                const bool automatic)
            {
                assert(_deviceSPtr);

                _deviceSPtr->setIQBalanceMode(int(direction), channel, automatic);
            }

            inline bool GetIQBalanceMode(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getIQBalanceMode(int(direction), channel);
            }

            inline bool HasFrequencyCorrection(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->hasFrequencyCorrection(int(direction), channel);
            }

            inline void SetFrequencyCorrection(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                const double value)
            {
                assert(_deviceSPtr);

                _deviceSPtr->setFrequencyCorrection(int(direction), channel, value);
            }

            inline double GetFrequencyCorrection(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getFrequencyCorrection(int(direction), channel);
            }

            //
            // Used for CSharp internals
            //

            inline std::string __ToString() const
            {
                return (_deviceSPtr->getDriverKey() + ":" + _deviceSPtr->getHardwareKey());
            }

            inline bool __Equals(const SoapySDR::CSharp::Device& other) const
            {
                return (__ToString() == other.__ToString());
            }

            inline uintptr_t __GetPointer() const
            {
                return reinterpret_cast<uintptr_t>(_deviceSPtr.get());
            }

        private:
            std::shared_ptr<SoapySDR::Device> _deviceSPtr;

            // C# class takes ownership, will unmake
            Device(SoapySDR::Device* pDevice): _deviceSPtr(pDevice, DeviceDeleter())
            {}
    };
}}
