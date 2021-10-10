// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;

namespace SoapySDR
{
    public class Stream
    {
        internal DeviceInternal _device = null;
        protected StreamHandle _streamHandle = null;
        protected bool _active = false;

        public string Format { get; }
        public uint[] Channels { get; }
        public Kwargs StreamArgs { get; }
        public bool Active { get { return _active; } }

        // We already used these parameters to create the stream,
        // this is just for the sake of getters.
        internal Stream(
            DeviceInternal device,
            string format,
            uint[] channels,
            Kwargs kwargs)
        {
            _device = device;

            Format = format;
            Channels = channels;
            StreamArgs = kwargs;
        }

        ~Stream()
        {
            if(_active)               Deactivate();
            if(_streamHandle != null) Close();
        }

        public ulong MTU => _active ? _device.GetStreamMTU(_streamHandle) : 0U;

        public ErrorCode Activate(
            StreamFlags flags,
            long timeNs = 0,
            uint numElems = 0)
        {
            ErrorCode ret = ErrorCode.NONE;
            if(_streamHandle != null)
            {
                if(!_active)
                {
                    ret = _device.ActivateStream(
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
            StreamFlags flags = StreamFlags.NONE,
            long timeNs = 0)
        {
            ErrorCode ret = ErrorCode.NONE;
            if(_streamHandle != null)
            {
                if(!_active)
                {
                    ret = _device.DeactivateStream(
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
            result = new StreamResult();

            if(_streamHandle != null)
            {
                var deviceOutput = _device.ReadStreamStatus(_streamHandle, timeoutUs);

                result = deviceOutput.second;
                ret = deviceOutput.first;
            }

            return ret;
        }

        public void Close()
        {
            if(_streamHandle != null) _device.CloseStream(_streamHandle);
            else throw new NotSupportedException("Stream is already closed");
        }

        //
        // Object overrides
        //

        // For completeness, but a stream is only ever equal to itself
        public override bool Equals(object other)
        {
            // In theory, ReferenceEquals is enough, but throwing for mis-matched type is convention
            if(GetType().Equals(other.GetType())) return object.ReferenceEquals(this, other);
            else throw new ArgumentException("Not a "+GetType().ToString());
        }

        public override int GetHashCode() => GetType().GetHashCode() ^ (int)_streamHandle?.GetHashCode();

        public override string ToString()
        {
            return string.Format("{0}:{1} {2} stream (format: {3}, channels: {4})",
                _device.GetDriverKey(),
                _device.GetHardwareKey(),
                (_active ? "active" : "inactive"),
                Format,
                Channels);
        }
    }
}
