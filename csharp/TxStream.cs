// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class TxStream
    {
        private Device _device = null;
        private StreamHandle _streamHandle = null;
        private bool _active = false;
        private bool _disposed = false;

        public string Format { get; }
        public uint[] Channels = { get; }
        public Kwargs[] StreamArgs { get; }
        public bool Active { get { return _active; } }

        // We already used these parameters to create the stream,
        // this is just for the sake of getters.
        internal TxStream(
            Device device,
            string format,
            uint[] channels,
            Kwargs kwargs,
            StreamHandle streamHandle)
        {
            _device = device;
            _streamHandle = streamHandle;

            Format = format;
            Channels = channels;
            StreamArgs = kwargs;
        }

        ~TxStream()
        {
            if(_active)       Deactivate();
            if(_streamHandle) Close();
        }

        public uint MTU
        {
            // By convention, don't throw from property getters
            get { return _active ? _device.getStreamMTU(_streamHandle) : 0; }
        }

        public ErrorCode Activate(
            StreamFlags flags,
            long timeNs = 0,
            ulong numElems = 0)
        {
            ErrorCode ret = ErrorCode.NONE;
            if(!_active)
            {
                ret = _device.__ActivateStream(
                    _streamHandle,
                    flags,
                    timeNs,
                    numElems);

                if(ret == ErrorCode.NONE) _active = true;
            }
            else throw new NotSupportedException("Stream is already active");

            return ret;
        }

        public ErrorCode Deactivate(
            StreamFlags flags = StreamFlags(0),
            long timeNs = 0)
        {
            ErrorCode ret = ErrorCode.NONE;
            if(!_active)
            {
                ret = _device.__DeactivateStream(
                    _streamHandle,
                    flags,
                    timeNs);

                if(ret == ErrorCode.NONE) _active = true;
            }
            else throw new NotSupportedException("Stream is already inactive");
        }

        public void Close()
        {
            _device.__CloseStream(_streamHandle);
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
            return deviceOutput.first;
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
            var buffsAsSizes = new SizeList();
            foreach(var buff in buffs) buffsAsSizes.Add((UIntPtr)((void*)buff));

            var deviceOutput = _device.__WriteStream(
                streamHandle,
                buffsAsSizes,
                numElems,
                timeNs,
                timeoutUs);

            result = deviceOutput.second;
            return deviceOutput.first;
        }

        public ErrorCode ReadStatus(int timeoutUs, out StreamResult result)
        {
            var deviceOutput = _device.__ReadStatus(_streamHandle, timeoutUs);

            result = deviceOutput.second;
            return deviceOutput.first;
        }

        public override string ToString()
        {
            return string.Format("{0}:{1} {2} TX stream (format: {3}, channels: {4})",
                _device.DriverKey,
                _device.HardwareKey,
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }

        // For completeness, but a stream is only ever equal to itself
        public override bool Equals(object other)
        {
            var otherAsTxStream = (TxStream)other;
            if(otherAsTxStream) return ReferenceEquals(this, other);
            else throw new ArgumentException("Not a TxStream");
        }

        public override int GetHashCode()
        {
            return (GetClass().GetHashCode() ^ _streamHandle.GetHashCode());
        }
    }
}
