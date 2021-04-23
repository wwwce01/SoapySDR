// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%include <arrays_csharp.i>
CSHARP_ARRAYS_FIXED(void*, void*)

%apply void* FIXED[] { void** buffs }
%csmethodmodifiers SoapySDR::Device::__readStream "private unsafe";
%csmethodmodifiers SoapySDR::Device::__writeStream "private unsafe";

%include <typemaps.i>

%apply double& OUTPUT { double& fullScale };

////////////////////////////////////////////////////////////////////////
// Device object (TODO: other ignores)
////////////////////////////////////////////////////////////////////////
%nodefaultctor SoapySDR::Device;
%ignore SoapySDR::Stream;
%ignore SoapySDR::Device::setFrontendMapping(const int, const std::string&);
%ignore SoapySDR::Device::getFrontendMapping(const int) const;
%ignore SoapySDR::Device::getNumChannels(const int);
%ignore SoapySDR::Device::getChannelInfo(const int, const size_t) const;
%ignore SoapySDR::Device::getFullDuplex(const int, const size_t) const;
%ignore SoapySDR::Device::getStreamFormats(const int, const size_t) const;
%ignore SoapySDR::Device::getNativeStreamFormat(const int, const size_t, double&) const;
%ignore SoapySDR::Device::getStreamArgsInfo(const int, const size_t) const;
%ignore SoapySDR::Device::setupStream(const int, const std::string &);
%ignore SoapySDR::Device::setupStream(const int, const std::string &, const std::vector<size_t> &);
%ignore SoapySDR::Device::setupStream(const int, const std::string &, const std::vector<size_t> &, const Kwargs &);
%ignore SoapySDR::Device::closeStream(Stream*);
%ignore SoapySDR::Device::getStreamMTU(Stream*) const;
%ignore SoapySDR::Device::activateStream(Stream *);
%ignore SoapySDR::Device::activateStream(Stream *, const int);
%ignore SoapySDR::Device::activateStream(Stream *, const int, const long long);
%ignore SoapySDR::Device::activateStream(Stream *, const int, const long long, const size_t);
%ignore SoapySDR::Device::deactivateStream(Stream*);
%ignore SoapySDR::Device::deactivateStream(Stream*, const int);
%ignore SoapySDR::Device::deactivateStream(Stream*, const int, const long long);
%ignore SoapySDR::Device::readStream;
%ignore SoapySDR::Device::writeStream;
%ignore SoapySDR::Device::readStreamStatus;
%ignore SoapySDR::Device::getNumDirectAccessBuffers;
%ignore SoapySDR::Device::getDirectAccessBufferAddrs;
%ignore SoapySDR::Device::acquireReadBuffer;
%ignore SoapySDR::Device::releaseReadBuffer;
%ignore SoapySDR::Device::acquireWriteBuffer;
%ignore SoapySDR::Device::releaseWriteBuffer;
%ignore SoapySDR::Device::getNativeDeviceHandle;

// TODO: default args where appropriate
%typemap(cscode) SoapySDR::Device %{
    public StreamHandle setupStream<T>(Direction direction, string format, SizeList channels, Kwargs kwargs) where T: unmanaged
    {
        return setupStream(direction, Utility.GetFormatString<T>(), channels, kwargs);
    }

    public unsafe readStream<T>(StreamHandle streamHandle, ref T[][] buffs, long timeNs, int timeoutUs) where T: unmanaged
    {
        Utility.ValidateBuffs(streamHandle, buffs);

        System.Runtime.InteropServices.GCHandle[] handles = null;
        SizeList buffsAsSizes = null;

        Utility.ManagedArraysToSizeList(
            buffs,
            handles,
            buffsAsSizes);

        return __readStream(streamHandle, buffsAsSizes, (uint)buffs.Length, timeNs, timeoutUs);
    }

    public unsafe readStream<T>(StreamHandle streamHandle, ref T[] buff, long timeNs, int timeoutUs) where T: unmanaged
    {
        T[][] buffs2D = new T[][1];
        buffs2D[0] = buff;

        return readStream(streamHandle, buffs2D, timeNs, timeoutUs);
    }

    public unsafe writeStream<T>(StreamHandle streamHandle, T[][] buffs, uint numElems, long timeNs, int timeoutUs) where T: unmanaged
    {
        Utility.ValidateBuffs(streamHandle, buffs);

        System.Runtime.InteropServices.GCHandle[] handles = null;
        SizeList buffsAsSizes = null;

        Utility.ManagedArraysToSizeList(
            buffs,
            handles,
            buffsAsSizes);

        return __writeStream(streamHandle, buffsAsSizes, (uint)buffs.Length, timeNs, timeoutUs);
    }

    public unsafe writeStream<T>(StreamHandle streamHandle, T[] buff, long timeNs, int timeoutUs) where T: unmanaged
    {
        T[][] buffs2D = new T[][1];
        buffs2D[0] = buff;

        return writeStream(streamHandle, buffs2D, timeNs, timeoutUs);
    }
%}

%include <SoapySDR/Device.hpp>

%{
    #include "CSharpExtensions.hpp"
%}

%extend SoapySDR::Device
{
    // additional overloads for writeSetting for basic types
    %template(writeSetting) SoapySDR::Device::writeSetting<bool>;
    %template(writeSetting) SoapySDR::Device::writeSetting<double>;
    %template(writeSetting) SoapySDR::Device::writeSetting<long long>;
    %template(readSensorBool) SoapySDR::Device::readSensor<bool>;
    %template(readSensorInt) SoapySDR::Device::readSensor<long long>;
    %template(readSensorFloat) SoapySDR::Device::readSensor<double>;
    %template(readSettingBool) SoapySDR::Device::readSetting<bool>;
    %template(readSettingInt) SoapySDR::Device::readSetting<long long>;
    %template(readSettingFloat) SoapySDR::Device::readSetting<double>;

    void setFrontendMapping(SoapySDR::CSharp::Direction direction, const std::string& mapping)
    {
        return self->setFrontendMapping(int(direction), mapping);
    }

    std::string getFrontendMapping(SoapySDR::CSharp::Direction direction)
    {
        return self->getFrontendMapping(int(direction));
    }

    size_t getNumChannels(SoapySDR::CSharp::Direction direction)
    {
        return self->getNumChannels(int(direction));
    }

    SoapySDR::Kwargs getChannelInfo(SoapySDR::CSharp::Direction direction, size_t channel)
    {
        return self->getChannelInfo(int(direction), channel);
    }

    bool getFullDuplex(SoapySDR::CSharp::Direction direction, size_t channel)
    {
        return self->getFullDuplex(int(direction), channel);
    }

    std::vector<std::string> getStreamFormats(SoapySDR::CSharp::Direction direction, size_t channel)
    {
        return self->getStreamFormats(int(direction), channel);
    }

    std::string getNativeStreamFormat(SoapySDR::CSharp::Direction direction, size_t channel, double& fullScale)
    {
        return self->getNativeStreamFormat(int(direction), channel, fullScale);
    }

    SoapySDR::ArgInfoList getStreamArgsInfo(SoapySDR::CSharp::Direction direction, size_t channel)
    {
        return self->getStreamArgsInfo(int(direction), channel);
    }

    SoapySDR::CSharp::StreamHandle setupStream(
        SoapySDR::CSharp::Direction direction,
        const std::string& format,
        const std::vector<size_t>& channels = std::vector<size_t>(),
        const SoapySDR::Kwargs& kwargs = SoapySDR::Kwargs())
    {
        SoapySDR::CSharp::StreamHandle streamHandle;
        streamHandle.stream = self->setupStream(int(direction), format, channels, kwargs);
        streamHandle.channels = channels;

        return streamHandle;
    }

    void closeStream(const SoapySDR::CSharp::StreamHandle& streamHandle)
    {
        self->closeStream(streamHandle.stream);
    }

    size_t getStreamMTU(const SoapySDR::CSharp::StreamHandle& streamHandle)
    {
        return self->getStreamMTU(streamHandle.stream);
    }

    int activateStream(
        const SoapySDR::CSharp::StreamHandle& streamHandle,
        int flags = 0,
        long long timeNs = 0,
        size_t numElems = 0)
    {
        return self->activateStream(streamHandle.stream, flags, timeNs, numElems);
    }

    int deactivateStream(
        const SoapySDR::CSharp::StreamHandle& streamHandle,
        int flags = 0,
        long long timeNs = 0)
    {
        return self->deactivateStream(streamHandle.stream, flags, timeNs);
    }

    SoapySDR::CSharp::StreamResult __readStream(
        const SoapySDR::CSharp::StreamHandle& streamHandle,
        const std::vector<size_t>& buffs,
        const size_t numElems,
        const int flags,
        const long long timeNs,
        const long timeoutUs)
    {
        SoapySDR::CSharp::StreamResult result;
        result.flags = flags;
        std::vector<void*> buffPtrs(buffs.size());
        for(size_t i = 0; i < buffs.size(); ++i)
        {
            buffPtrs[i] = reinterpret_cast<void*>(buffs[i]);
        }
        result.ret = self->readStream(streamHandle.stream, buffPtrs.data(), numElems, result.flags, result.timeNs, result.timeoutUs);

        return result;
    }

    SoapySDR::CSharp::StreamResult __writeStream(
        const SoapySDR::CSharp::StreamHandle& streamHandle,
        const std::vector<size_t>& buffs,
        const size_t numElems,
        const long long timeNs,
        const long timeoutUs)
    {
        SoapySDR::CSharp::StreamResult result;
        std::vector<const void*> buffPtrs(buffs.size());
        for(size_t i = 0; i < buffs.size(); ++i)
        {
            buffPtrs[i] = reinterpret_cast<const void*>(buffs[i]);
        }
        result.ret = self->writeStream(streamHandle.stream, buffPtrs.data(), numElems, result.flags, timeNs, timeoutUs);

        return result;
    }

    SoapySDR::CSharp::StreamResult readStreamStatus(
        const SoapySDR::CSharp::StreamHandle& streamHandle,
        const long timeoutUs)
    {
        SoapySDR::CSharp::StreamResult result;
        result.ret = self->readStreamStatus(streamHandle.stream, result.chanMask, result.flags, result.timeNs, timeoutUs);

        return result;
    }
};
