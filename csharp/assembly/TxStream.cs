// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Buffers;
using System.Linq;
using System.Runtime.InteropServices;

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
            _streamHandle = device.SetupStream(Direction.Tx, format, Utility.ToSizeList(channels), kwargs);
        }

        public unsafe ErrorCode Write<T>(
            ReadOnlyMemory<T> memory,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            return Write(
                memory.Span,
                timeNs,
                timeoutUs,
                out result);
        }

        public unsafe ErrorCode Write<T>(
            ReadOnlyMemory<T>[] memory,
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

                var deviceOutput = _device.WriteStream(
                    _streamHandle,
                    memsAsSizes,
                    (uint)memory[0].Length,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new InvalidOperationException("Stream is closed");

            return ret;
        }

        public unsafe ErrorCode Write<T>(
            ReadOnlySpan<T> span,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            fixed(T* data = &MemoryMarshal.GetReference(span))
            {
                return Write((IntPtr)data, (uint)span.Length, timeNs, timeoutUs, out result);
            }
        }

        public unsafe ErrorCode Write<T>(
            T[] buff,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            return Write(new ReadOnlySpan<T>(buff), timeNs, timeoutUs, out result);
        }

        public unsafe ErrorCode Write<T>(
            T[][] buffs,
            long timeNs,
            int timeoutUs,
            out StreamResult result) where T : unmanaged
        {
            return Write(buffs.Select(buff => new ReadOnlyMemory<T>(buff)).ToArray(), timeNs, timeoutUs, out result);
        }

        public unsafe ErrorCode Write(
            IntPtr ptr,
            uint numElems,
            long timeNs,
            int timeoutUs,
            out StreamResult result)
        {
            return Write(
                new IntPtr[] { ptr },
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
            ErrorCode ret;

            if (_streamHandle != null)
            {
                var deviceOutput = _device.WriteStream(
                    _streamHandle,
                    Utility.ToSizeList(ptrs),
                    numElems,
                    timeNs,
                    timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }
            else throw new InvalidOperationException("Stream is closed");

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
            return string.Format("{0}:{1} {2} TX stream (format: {3}, channels: {4})",
                _device.GetDriverKey(),
                _device.GetHardwareKey(),
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }
    }
}
