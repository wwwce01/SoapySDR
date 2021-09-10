// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class Stream
    {
        protected Device _device = null;
        protected StreamHandle _streamHandle = null;
        protected bool _active = false;

        public string Format { get; }
        public uint[] Channels = { get; }
        public Kwargs[] StreamArgs { get; }
        public bool Active { get { return _active; } }

        // We already used these parameters to create the stream,
        // this is just for the sake of getters.
        internal Stream(
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

        ~Stream()
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
            if(_streamHandle)
            {
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
            }
            else throw new NotSupportedException("Stream is closed");

            return ret;
        }

        public ErrorCode Deactivate(
            StreamFlags flags = StreamFlags(0),
            long timeNs = 0)
        {
            ErrorCode ret = ErrorCode.NONE;
            if(_streamHandle)
            {
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
            else throw new NotSupportedException("Stream is closed");

            return ret;
        }

        public ErrorCode ReadStatus(int timeoutUs, out StreamResult result)
        {
            ErrorCode ret = ErrorCode.NONE;

            if(_streamHandle)
            {
                var deviceOutput = _device.__ReadStatus(_streamHandle, timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }

            return ret;
        }

        public void Close()
        {
            if(_streamHandle) _device.__CloseStream(_streamHandle);
            else throw new NotSupportedException("Stream is already closed");
        }

        // For completeness, but a stream is only ever equal to itself
        public override bool Equals(object other)
        {
            // In theory, ReferenceEquals is enough, but throwing for mis-matched type is convention
            if(GetClass().Equals(other.GetClass())) return object.ReferenceEquals(this, other);
            else throw new ArgumentException("Not a "+GetClass().ToString());
        }

        public override int GetHashCode()
        {
            return (GetClass().GetHashCode() ^ _streamHandle?.GetHashCode());
        }

        public override string ToString()
        {
            return string.Format("{0}:{1} {2} stream (format: {3}, channels: {4})",
                _device.DriverKey,
                _device.HardwareKey,
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }
    }
}
