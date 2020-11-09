// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%include <arrays_csharp.i>
CSHARP_ARRAYS_FIXED(void*, void*)

%apply void* FIXED[] { void** buffs }
%csmethodmodifiers SoapySDR::Device::__readStream "private unsafe";

%include <typemaps.i>

%apply double& OUTPUT { double& fullScale };

%typemap(cscode) SoapySDR::Device
%{
    private StreamResult __readStreamCS(
        StreamHandle streamHandle,
        global::System.IntPtr[] intPtrs,
        uint numElems,
        int flags,
        int timeoutUs = 100000)
    {
        return new StreamResult();
    }
%}

////////////////////////////////////////////////////////////////////////
// Device object (TODO: other ignores)
////////////////////////////////////////////////////////////////////////
%nodefaultctor SoapySDR::Device;
%ignore SoapySDR::Device::setFrontendMapping(const int, const std::string&);
%ignore SoapySDR::Device::getFrontendMapping(const int);
%ignore SoapySDR::Device::getNumChannels(const int);
%ignore SoapySDR::Device::getChannelInfo(const int, const size_t);
%ignore SoapySDR::Device::getFullDuplex(const int, const size_t);
%ignore SoapySDR::Device::getStreamFormats(const int, const size_t);
%ignore SoapySDR::Device::getNativeStreamFormat(const int, const size_t, double&);
%ignore SoapySDR::Device::getStreamArgsInfo(const int, const size_t);
%ignore SoapySDR::Device::setupStream(const int, const std::string&, const std::vector<size_t>&, const SoapySDR::Kwargs&);
%ignore SoapySDR::Device::closeStream(SoapySDR::Stream*);
%ignore SoapySDR::Device::getStreamMTU(SoapySDR::Stream*);
%ignore SoapySDR::Device::activateStream(SoapySDR::Stream*, const int, const long long, const size_t);
%ignore SoapySDR::Device::deactivateStream(SoapySDR::Stream*, const int, const long long);
%ignore SoapySDR::Device::getNativeDeviceHandle;
%include <SoapySDR/Device.hpp>

%{
    #include "CSharpExtensions.hpp"
%}


/*
%extend StreamResult
{
    %insert("python")
    %{
        def __str__(self):
            return "ret=%s, flags=%s, timeNs=%s"%(self.ret, self.flags, self.timeNs)
    %}
};
*/

// TODO: automate generation
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

    // We get void* from IntPtr
    SoapySDR::CSharp::StreamResult __readStream(
        const SoapySDR::CSharp::StreamHandle& streamHandle,
        void** buffs,
        size_t numElems,
        int flags,
        long timeoutUs)
    {
        //std::vector<void*> buffsCpp;
        //for(size_t i = 0; i < buffs.size(); ++i) buffsCpp.emplace_back((void*)buffs[i]);

        SoapySDR::CSharp::StreamResult streamResult;
        //streamResult.flags = flags;
        //streamResult.ret = self->readStream(streamHandle.stream, buffsCpp.data(), numElems, streamResult.flags, streamResult.timeNs, timeoutUs);

        return streamResult;
    }

/*
    StreamResult readStream__(SoapySDR::Stream *stream, const std::vector<size_t> &buffs, const size_t numElems, const int flags, const long timeoutUs)
    {
        StreamResult sr;
        sr.flags = flags;
        std::vector<void *> ptrs(buffs.size());
        for (size_t i = 0; i < buffs.size(); i++) ptrs[i] = (void *)buffs[i];
        sr.ret = self->readStream(stream, (&ptrs[0]), numElems, sr.flags, sr.timeNs, timeoutUs);
        return sr;
    }

    StreamResult writeStream__(SoapySDR::Stream *stream, const std::vector<size_t> &buffs, const size_t numElems, const int flags, const long long timeNs, const long timeoutUs)
    {
        StreamResult sr;
        sr.flags = flags;
        std::vector<const void *> ptrs(buffs.size());
        for (size_t i = 0; i < buffs.size(); i++) ptrs[i] = (const void *)buffs[i];
        sr.ret = self->writeStream(stream, (&ptrs[0]), numElems, sr.flags, timeNs, timeoutUs);
        return sr;
    }

    StreamResult readStreamStatus__(SoapySDR::Stream *stream, const long timeoutUs)
    {
        StreamResult sr;
        sr.ret = self->readStreamStatus(stream, sr.chanMask, sr.flags, sr.timeNs, timeoutUs);
        return sr;
    }

    %insert("python")
    %{
        #manually unmake and flag for future calls and the deleter
        def close(self):
            try: getattr(self, '__closed__')
            except AttributeError: Device.unmake(self)
            setattr(self, '__closed__', True)

        def __del__(self): self.close()

        def __str__(self):
            return "%s:%s"%(self.getDriverKey(), self.getHardwareKey())

        def readStream(self, stream, buffs, numElems, flags = 0, timeoutUs = 100000):
            ptrs = [extractBuffPointer(b) for b in buffs]
            return self.readStream__(stream, ptrs, numElems, flags, timeoutUs)

        def writeStream(self, stream, buffs, numElems, flags = 0, timeNs = 0, timeoutUs = 100000):
            ptrs = [extractBuffPointer(b) for b in buffs]
            return self.writeStream__(stream, ptrs, numElems, flags, timeNs, timeoutUs)

        def readStreamStatus(self, stream, timeoutUs = 100000):
            return self.readStreamStatus__(stream, timeoutUs)
    %}
*/
};
