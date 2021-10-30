// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Linq;

namespace SoapySDR
{
    public class RxStream: Stream
    {
        internal RxStream(
            DeviceInternal device,
            string format,
            uint[] channels,
            Kwargs kwargs
        ):
            base(device, format, channels, kwargs)
        {
            _streamHandle = device.SetupStream(Direction.Rx, format, Utility.ToSizeList(channels), kwargs);
        }

        public unsafe ErrorCode Read<T>(
            ref T[] buff,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T: unmanaged
        {
            T[][] buffs2D = new T[1][];
            buffs2D[0] = buff;

            return Read(ref buffs2D, flags, timeNs, timeoutUs, out result);
        }

        public unsafe ErrorCode Read<T>(
            ref T[][] buffs,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T: unmanaged
        {
            ErrorCode ret;

            if(_streamHandle != null)
            {
                Utility.ValidateBuffs(_streamHandle, buffs);

                Utility.ManagedArraysToSizeList(
                    buffs,
#pragma warning disable IDE0059 // Unnecessary assignment of a value
                    // We don't use this variable anywhere past this, but we need
                    // it in scope for buffsAsSizes to be valid.
                    out System.Runtime.InteropServices.GCHandle[] handles,
#pragma warning restore IDE0059 // Unnecessary assignment of a value
                    out SizeList buffsAsSizes);

                var deviceOutput = _device.ReadStream(
                    _streamHandle,
                    buffsAsSizes,
                    (uint)buffs.Length,
                    flags,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new InvalidOperationException("Stream is closed");

            return ret;
        }

        public unsafe ErrorCode Read(
            IntPtr ptr,
            uint numElems,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            return Read(
                (UIntPtr)(void*)ptr,
                numElems,
                flags,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Read(
            IntPtr[] ptrs,
            uint numElems,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            return Read(
                ptrs.Select(x => (UIntPtr)(void*)x).ToArray(),
                numElems,
                flags,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Read(
            UIntPtr ptr,
            uint numElems,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            return Read(
                new UIntPtr[] { ptr },
                numElems,
                flags,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Read(
            UIntPtr[] ptrs,
            uint numElems,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            ErrorCode ret;

            if(_streamHandle != null)
            {
                var deviceOutput = _device.ReadStream(
                    _streamHandle,
                    Utility.ToSizeList(ptrs),
                    numElems,
                    flags,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new InvalidOperationException("Stream is closed");

            return ret;
        }

        //
        // Object overrides
        //

        public override bool Equals(object other) => base.Equals(other);

        public override int GetHashCode() => base.GetHashCode();

        public override string ToString()
        {
            return string.Format("{0}:{1} {2} RX stream (format: {3}, channels: {4})",
                _device.GetDriverKey(),
                _device.GetHardwareKey(),
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }
    }
}
