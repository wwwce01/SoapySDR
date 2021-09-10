// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class TxStream: Stream
    {
        // We already used these parameters to create the stream,
        // this is just for the sake of getters.
        internal TxStream(
            Device device,
            string format,
            uint[] channels,
            Kwargs kwargs,
            StreamHandle streamHandle
        ):
            base(device, format, channels, kwargs, streamHandle)
        {
        }

        public unsafe ErrorCode Write<T>(
            T[] buff,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T: unmanaged
        {
            T[][] buffs2D = new T[1][];
            buffs2D[0] = buff;

            return Write(buffs2D, timeNs, timeoutUs, out result);
        }

        public unsafe ErrorCode Write<T>(
            T[][] buffs,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T: unmanaged
        {
            ErrorCode ret = ErrorCode.NONE;

            if(_streamHandle)
            {
                Utility.ValidateBuffs(_streamHandle, buffs);

                System.Runtime.InteropServices.GCHandle[] handles = null;
                SizeList buffsAsSizes = null;

                Utility.ManagedArraysToSizeList(
                    buffs,
                    handles,
                    buffsAsSizes);

                var deviceOutput = _device.__WriteStream(
                    _streamHandle,
                    buffsAsSizes,
                    (uint)buffs.Length,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new NotSupportedException("Stream is closed");

            return ret;
        }

        public unsafe ErrorCode Write(
            IntPtr ptr,
            uint numElems,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            return Write(
                new IntPtr{buff},
                numElems,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Write(
            IntPtr[] ptrs,
            uint numElems,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            ErrorCode ret = ErrorCode.NONE;

            if(_streamHandle)
            {
                var buffsAsSizes = new SizeList();
                foreach(var buff in buffs) buffsAsSizes.Add((UIntPtr)((void*)buff));

                var deviceOutput = _device.__WriteStream(
                    streamHandle,
                    buffsAsSizes,
                    numElems,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new NotSupportedException("Stream is closed");

            return ret;
        }

        // Note: Stream's Equals() and GetHashCode() work here too

        public override string ToString()
        {
            return string.Format("{0}:{1} {2} TX stream (format: {3}, channels: {4})",
                _device.DriverKey,
                _device.HardwareKey,
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }
    }
}
