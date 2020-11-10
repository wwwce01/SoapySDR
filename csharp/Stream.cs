// Copyright (c) 2020 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Collections.Generic;

namespace SoapySDR
{
    public class Stream
    {
        //
        // Variables
        //

        internal Device _device = null;
        internal StreamHandle _streamHandle = null;
        internal Direction _direction = null;
        internal string _format = null;
        internal StringList _channels = null;
        internal Kwargs _kwargs = null;

        //
        // Utility code
        //

        private void validateBuffs<T>(ref T[][] buffs)
        {
            if(buffs == null)
            {
                throw new ArgumentNullException("buffs");
            }
            if(buffs.Length != _channels.Length)
            {
                throw new ArgumentException(string.format("Expected {0} channels. Found {1} buffers.", _channels.Length, buffs.Length));
            }

            HashSet<int> uniqueSizes = new HashSet<T>();

            for(int buffIndex = 0; buffIndex < buffs.Length; ++buffIndex)
            {
                if(buffs[buffIndex] = null)
                {
                    throw new ArgumentNullException(string.format("buffs[{0}]", buffIndex));
                }

                uniqueSizes.Add(buffs[buffIndex].Length);
            }

            if(uniqueSizes.Count > 1)
            {
                throw new ArgumentException("All buffers must be of the same length.");
            }
        }

        //
        // Methods
        //

        internal Stream(
            Device device,
            StreamHandle streamHandle,
            Direction direction,
            string format,
            StringList channels,
            Kwargs kwargs)
        {
            _device = device;
            _streamHandle = streamHandle;
            _direction = direction;
            _format = format;
            _channels = channels;
            _kwargs = kwargs;
        }

        public Direction Direction {get {return _direction;}}

        public string Format {get {return _format;}}

        public StringList Channels {get {return _channels;}}

        public Kwargs Kwargs {get {return _kwargs;}}

        public ulong MTU {get {return _device.getStreamMTU(_streamHandle);}}

        // TODO: throw?
        public int activate(
            int flags = 0,
            long timeNs = 0,
            ulong numElems = 0)
        {
            return _device.activateStream(_streamHandle, flags, timeNs, numElems);
        }

        // TODO: throw?
        public int deactivate(
            int flags = 0,
            long timeNs = 0)
        {
            return _device.deactivateStream(_streamHandle, flags, timeNs);
        }

        public StreamResult read(
            ref byte[][] buffs,
            int flags,
            ulong timeoutUs)
        {
            validateBuffs<byte>(ref buffs);
        }
    }
}
