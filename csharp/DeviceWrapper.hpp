// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

#pragma once

#include "CSharpExtensions.hpp"

#include <SoapySDR/Device.hpp>

#include <algorithm>
#include <cassert>
#include <cstdio>
#include <memory>

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

            static DeviceVector ParallelMake(const SoapySDR::KwargsList& kwargsList)
            {
                const auto devs = SoapySDR::Device::make(kwargsList);
                DeviceVector csharpDevs;

                std::transform(
                    devs.begin(),
                    devs.end(),
                    std::back_inserter(csharpDevs),
                    [](SoapySDR::Device* pDev){ return Device(pDev); });

                return csharpDevs;
            }

            static DeviceVector ParallelMake(const std::vector<std::string>& argsList)
            {
                // TODO: replace with native SoapySDR::Device function when implemented
                SoapySDR::KwargsList kwargsList;
                std::transform(
                    argsList.begin(),
                    argsList.end(),
                    std::back_inserter(kwargsList),
                    SoapySDR::KwargsFromString);

                return ParallelMake(kwargsList);
            }

            //
            // Identification API
            //

            inline std::string GetDriverKey() const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getDriverKey();
            }

            inline std::string GetHardwareKey() const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getHardwareKey();
            }

            inline SoapySDR::Kwargs GetHardwareInfo() const
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

            inline std::vector<std::string> GetStreamFormats(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getStreamFormats(int(direction), channel);
            }

            inline std::string GetNativeStreamFormat(
                SoapySDR::CSharp::Direction direction,
                const size_t channel,
                double &rFullScale) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getNativeStreamFormat(int(direction), channel, rFullScale);
            }

            inline SoapySDR::ArgInfoList GetStreamArgsInfo(
                SoapySDR::CSharp::Direction direction,
                const size_t channel) const
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getStreamArgsInfo(int(direction), channel);
            }

            SoapySDR::CSharp::StreamHandle SetupStream(
                SoapySDR::CSharp::Direction direction,
                const std::string& format,
                const std::vector<size_t>& channels = std::vector<size_t>(),
                const SoapySDR::Kwargs& kwargs = SoapySDR::Kwargs())
            {
                assert(_deviceSPtr);

                SoapySDR::CSharp::StreamHandle streamHandle;
                streamHandle.stream = _deviceSPtr->setupStream(int(direction), format, channels, kwargs);
                streamHandle.channels = channels;

                return streamHandle;
            }

            inline void CloseStream(const SoapySDR::CSharp::StreamHandle& streamHandle)
            {
                assert(_deviceSPtr);

                _deviceSPtr->closeStream(streamHandle.stream);
            }

            inline size_t GetStreamMTU(const SoapySDR::CSharp::StreamHandle& streamHandle)
            {
                assert(_deviceSPtr);

                return _deviceSPtr->getStreamMTU(streamHandle.stream);
            }

            inline int ActivateStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const int flags = 0,
                const long long timeNs = 0,
                const size_t numElems = 0)
            {
                assert(_deviceSPtr);

                return _deviceSPtr->activateStream(streamHandle.stream, flags, timeNs, numElems);
            }

            inline int DeactivateStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const int flags = 0,
                const long long timeNs = 0)
            {
                assert(_deviceSPtr);

                return _deviceSPtr->deactivateStream(streamHandle.stream, flags, timeNs);
            }

            SoapySDR::CSharp::StreamResult __ReadStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const std::vector<size_t>& buffs,
                const size_t numElems,
                const int flags,
                const long long timeNs,
                const long timeoutUs)
            {
                assert(_deviceSPtr);

                SoapySDR::CSharp::StreamResult result;
                result.flags = flags;
                std::vector<void*> buffPtrs(buffs.size());
                for(size_t i = 0; i < buffs.size(); ++i)
                {
                    buffPtrs[i] = reinterpret_cast<void*>(buffs[i]);
                }
                result.ret = _deviceSPtr->readStream(streamHandle.stream, buffPtrs.data(), numElems, result.flags, result.timeNs, result.timeoutUs);

                return result;
            }

            SoapySDR::CSharp::StreamResult __WriteStream(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const std::vector<size_t>& buffs,
                const size_t numElems,
                const long long timeNs,
                const long timeoutUs)
            {
                assert(_deviceSPtr);

                SoapySDR::CSharp::StreamResult result;
                std::vector<const void*> buffPtrs(buffs.size());
                for(size_t i = 0; i < buffs.size(); ++i)
                {
                    buffPtrs[i] = reinterpret_cast<const void*>(buffs[i]);
                }
                result.ret = _deviceSPtr->writeStream(streamHandle.stream, buffPtrs.data(), numElems, result.flags, timeNs, timeoutUs);

                return result;
            }

            SoapySDR::CSharp::StreamResult ReadStreamStatus(
                const SoapySDR::CSharp::StreamHandle& streamHandle,
                const long timeoutUs)
            {
                assert(_deviceSPtr);

                SoapySDR::CSharp::StreamResult result;
                result.ret = _deviceSPtr->readStreamStatus(streamHandle.stream, result.chanMask, result.flags, result.timeNs, timeoutUs);

                return result;
            }

            //
            // Antenna API
            //

            inline std::vector<std::string> ListAntennas(
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

        private:
            std::shared_ptr<SoapySDR::Device> _deviceSPtr;

            Device(SoapySDR::Device* pDevice): _deviceSPtr(pDevice, DeviceDeleter())
            {}
    };
}}
