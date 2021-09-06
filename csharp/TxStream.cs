// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class TxStream
    {
        private Device _device = null;
        private StreamHandle _streamHandle = null;

        public string Format { get; }
        public uint[] Channels = { get; }
        public Kwargs[] StreamArgs { get; }

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

        public uint MTU
        {
            get { return _device.getStreamMTU(_streamHandle); }
        }

        public unsafe StreamResult Write<T>(T[] buff, long timeNs, int timeoutUs) where T: unmanaged
        {
            T[][] buffs2D = new T[1][];
            buffs2D[0] = buff;

            return WriteStream(_streamHandle, buffs2D, timeNs, timeoutUs);
        }

        public unsafe StreamResult Write<T>(T[][] buffs, uint numElems, long timeNs, int timeoutUs) where T: unmanaged
        {
            Utility.ValidateBuffs(streamHandle, buffs);

            System.Runtime.InteropServices.GCHandle[] handles = null;
            SizeList buffsAsSizes = null;

            Utility.ManagedArraysToSizeList(
                buffs,
                handles,
                buffsAsSizes);

            return _device.__WriteStream(_streamHandle, buffsAsSizes, (uint)buffs.Length, timeNs, timeoutUs);
        }

        public unsafe StreamResult Write(IntPtr buff, uint numElems, long timeNs, int timeoutUs)
        {
            return Write(new IntPtr{buff}, numElems, timeNs, timeoutUs);
        }

        public unsafe StreamResult Write(IntPtr[] buffs, uint numElems, long timeNs, int timeoutUs)
        {
            var buffsAsSizes = new SizeList();
            foreach(var buff in buffs) buffsAsSizes.Add((UIntPtr)((void*)buff));

            return _device.__WriteStream(_streamHandle, buffsAsSizes, numElems, timeNs, timeoutUs);
        }

        public StreamResult ReadStatus(int timeoutUs)
        {
            return _device.__ReadStreamStats(_streamHandle, timeoutUs);
        }
    }
}
