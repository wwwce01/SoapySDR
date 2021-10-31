// Copyright (c) 2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Buffers;
using System.Linq;
using System.Runtime.InteropServices;

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
            Memory<T> memory,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            return Read(
                new Memory<T>[] { memory },
                flags,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Read<T>(
            Memory<T>[] memory,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            ErrorCode ret;

            if (_streamHandle != null)
            {
                Utility.ValidateMemory(_streamHandle, memory);

                var memsAsSizes = Utility.ToSizeList(
                    memory,
#pragma warning disable IDE0059 // Unnecessary assignment of a value
                    out MemoryHandle[] memoryHandles);
#pragma warning restore IDE0059 // Unnecessary assignment of a value

                var deviceOutput = _device.ReadStream(
                    _streamHandle,
                    memsAsSizes,
                    (uint)memory[0].Length,
                    flags,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new InvalidOperationException("Stream is closed");

            return ret;
        }

        public unsafe ErrorCode Read<T>(
            Span<T> span,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            fixed(T* data = &MemoryMarshal.GetReference(span))
            {
                return Read((IntPtr)data, (uint)span.Length, flags, timeNs, timeoutUs, out result);
            }
        }

        public unsafe ErrorCode Read<T>(
            ref T[] buff,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T: unmanaged
        {
            return Read(new Memory<T>(buff), flags, timeNs, timeoutUs, out result);
        }

        public unsafe ErrorCode Read<T>(
            ref T[][] buffs,
            StreamFlags flags,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T: unmanaged
        {
            return Read(buffs.Select(buff => new Memory<T>(buff)).ToArray(), flags, timeNs, timeoutUs, out result);
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
                new IntPtr[] { ptr },
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
            ErrorCode ret;

            if (_streamHandle != null)
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
