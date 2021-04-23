// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

%csmethodmodifiers SoapySDR::CSharp::Device::__ReadStream "private unsafe";
%csmethodmodifiers SoapySDR::CSharp::Device::__WriteStream "private unsafe";

%include <typemaps.i>

%apply double& OUTPUT { double& fullScaleOut };

// TODO: default args where appropriate
%typemap(cscode) SoapySDR::CSharp::Device %{
    public StreamHandle setupStream<T>(Direction direction, string format, SizeList channels, Kwargs kwargs) where T: unmanaged
    {
        return setupStream(direction, Utility.GetFormatString<T>(), channels, kwargs);
    }

    public unsafe StreamResult readStream<T>(StreamHandle streamHandle, ref T[] buff, long timeNs, int timeoutUs) where T: unmanaged
    {
        T[][] buffs2D = new T[][1];
        buffs2D[0] = buff;

        return readStream(streamHandle, buffs2D, timeNs, timeoutUs);
    }

    public unsafe StreamResult readStream<T>(StreamHandle streamHandle, ref T[][] buffs, long timeNs, int timeoutUs) where T: unmanaged
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

    public unsafe StreamResult readStream(StreamHandle streamHandle, IntPtr buff, uint numElems, long timeNs, int timeoutUs)
    {
        return readStream(streamHandle, new IntPtr{buff}, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult readStream(StreamHandle streamHandle, IntPtr[] buffs, uint numElems, long timeNs, int timeoutUs)
    {
        var buffsAsSizes = new SizeList();
        foreach(var buff in buffs) buffsAsSizes.Add((UIntPtr)((void*)buff));

        return __readStream(streamHandle, buffsAsSizes, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult readStream(StreamHandle streamHandle, UIntPtr buff, uint numElems, long timeNs, int timeoutUs)
    {
        return readStream(streamHandle, new UIntPtr{buff}, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult readStream(StreamHandle streamHandle, UIntPtr[] buffs, uint numElems, long timeNs, int timeoutUs)
    {
        var buffsAsSizes = new SizeList();
        foreach(var buff in buffs) buffsAsSizes.Add((uint)buff);

        return __readStream(streamHandle, buffsAsSizes, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult writeStream<T>(StreamHandle streamHandle, T[] buff, long timeNs, int timeoutUs) where T: unmanaged
    {
        T[][] buffs2D = new T[][1];
        buffs2D[0] = buff;

        return writeStream(streamHandle, buffs2D, timeNs, timeoutUs);
    }

    public unsafe StreamResult writeStream<T>(StreamHandle streamHandle, T[][] buffs, uint numElems, long timeNs, int timeoutUs) where T: unmanaged
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

    public unsafe StreamResult writeStream(StreamHandle streamHandle, IntPtr buff, uint numElems, long timeNs, int timeoutUs)
    {
        return writeStream(streamHandle, new IntPtr{buff}, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult writeStream(StreamHandle streamHandle, IntPtr[] buffs, uint numElems, long timeNs, int timeoutUs)
    {
        var buffsAsSizes = new SizeList();
        foreach(var buff in buffs) buffsAsSizes.Add((UIntPtr)((void*)buff));

        return __writeStream(streamHandle, buffsAsSizes, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult writeStream(StreamHandle streamHandle, UIntPtr buff, uint numElems, long timeNs, int timeoutUs)
    {
        return writeStream(streamHandle, new UIntPtr{buff}, numElems, timeNs, timeoutUs);
    }

    public unsafe StreamResult writeStream(StreamHandle streamHandle, UIntPtr[] buffs, uint numElems, long timeNs, int timeoutUs)
    {
        var buffsAsSizes = new SizeList();
        foreach(var buff in buffs) buffsAsSizes.Add((uint)buff);

        return __writeStream(streamHandle, buffsAsSizes, numElems, timeNs, timeoutUs);
    }
%}

%ignore SoapySDR::CSharp::DeviceDeleter;
%nodefaultctor SoapySDR::CSharp::Device;

%{
#include "DeviceWrapper.hpp"
%}

%include "DeviceWrapper.hpp"

%template(DeviceList) std::vector<SoapySDR::CSharp::Device>;
