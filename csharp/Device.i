// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%include <typemaps.i>

%apply double& OUTPUT { double& fullScale };

////////////////////////////////////////////////////////////////////////
// Device object
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
%ignore SoapySDR::Device::getNativeDeviceHandle;
%include <SoapySDR/Device.hpp>

%{
    #include "CSharpExtensions.hpp"
%}

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
