// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Linq;

namespace SoapySDR
{
    public class TxStream: Stream
    {
        internal TxStream(
            DeviceInternal device,
            string format,
            uint[] channels,
            Kwargs kwargs
        ):
            base(device, format, channels, kwargs)
        {
            _streamHandle = device.SetupStream(Direction.Tx, format, new SizeList(channels), kwargs);
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
            ErrorCode ret;

            if(_streamHandle != null)
            {
                Utility.ValidateBuffs(_streamHandle, buffs);

                System.Runtime.InteropServices.GCHandle[] handles = null;
                SizeList buffsAsSizes = null;

                Utility.ManagedArraysToSizeList(
                    buffs,
                    out handles,
                    out buffsAsSizes);

                var deviceOutput = _device.WriteStream(
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
                (UIntPtr)(void*)ptr,
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
            return Write(
                ptrs.Select(x => (UIntPtr)(void*)x).ToArray(),
                numElems,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Write(
            UIntPtr ptr,
            uint numElems,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            return Write(
                new UIntPtr[] { ptr },
                numElems,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Write(
            UIntPtr[] ptrs,
            uint numElems,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            ErrorCode ret;

            if(_streamHandle != null)
            {
                var buffsAsSizes = new SizeList();

                foreach (var ptr in ptrs)
#if _64BIT
                    buffsAsSizes.Add((ulong)ptr);
#else
                    buffsAsSizes.Add((uint)ptr);
#endif

                var deviceOutput = _device.WriteStream(
                    _streamHandle,
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

        public ErrorCode ReadStatus(int timeoutUs, out StreamResult result)
        {
            ErrorCode ret;
            result = new StreamResult();

            if (_streamHandle != null)
            {
                var deviceOutput = _device.ReadStreamStatus(_streamHandle, timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new NotSupportedException("Stream is closed");

            return ret;
        }

        //
        // Object overrides
        //

        public override bool Equals(object other) => base.Equals(other);

        public override int GetHashCode() => base.GetHashCode();

        public override string ToString()
        {
            return string.Format("{0}:{1} {2} TX stream (format: {3}, channels: {4})",
                _device.GetDriverKey(),
                _device.GetHardwareKey(),
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }
    }
}