// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace SoapySDR
{
    internal class Utility
    {
        // TODO: compare stream type to buffer type
        public static void ValidateBuffs<T>(
            StreamHandle streamHandle,
            ref T[][] buffs) where T: unmanaged
        {
            var numChannels = streamHandle.GetChannels().Length;
            var format = streamHandle.GetFormat();

            if(buffs == null)
            {
                throw new ArgumentNullException("buffs");
            }
            else if(buffs.Length != numChannels)
            {
                throw new ArgumentException(string.format("Expected {0} channels. Found {1} buffers.", numChannels, buffs.Length));
            }
            else if(!format.Equals(GetFormatString<T>()))
            {
                throw new ArgumentException(string.format("Expected format \"{0}\". Found format \"{1}\"", GetFormatString<T>(), format));
            }

            HashSet<int> uniqueSizes = new HashSet<T>();

            for(int buffIndex = 0; buffIndex < buffs.Length; ++buffIndex)
            {
                if(buffs[buffIndex] == null)
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

        public static unsafe void ManagedArraysToSizeList<T>(
            T[][] buffs,
            out GCHandle[] handles,
            out SizeList sizeList)
        {
            handles = new GCHandle[buffs.Length];
            sizeList = new SizeList();

            for(int buffIndex = 0; buffIndex < buffs.Length; ++buffIndex)
            {
                handles[buffIndex] = GCHandle.Alloc(
                    buffs[buffIndex],
                    System.Runtime.InteropServices.GCHandleType.Pinned);

                var uptr = UIntPtr(((void*)handles[buffIndex].AddrOfPinnedObject()));
                sizeList.Add((uint)uptr);
            }
        }

        // TODO: complex version
        public static string GetFormatString<T>() where T: unmanaged
        {
            var type = typeof(T);

            if(typeof(T).Equals(typeof(sbyte)))       return StreamFormats.S8;
            else if(typeof(T).Equals(typeof(short)))  return StreamFormats.S16;
            else if(typeof(T).Equals(typeof(int)))    return StreamFormats.S32;
            else if(typeof(T).Equals(typeof(long)))   return StreamFormats.S64;
            else if(typeof(T).Equals(typeof(byte)))   return StreamFormats.U8;
            else if(typeof(T).Equals(typeof(ushort))) return StreamFormats.U16;
            else if(typeof(T).Equals(typeof(uint)))   return StreamFormats.U32;
            else if(typeof(T).Equals(typeof(ulong)))  return StreamFormats.U64;
            else if(typeof(T).Equals(typeof(float)))  return StreamFormats.F32;
            else if(typeof(T).Equals(typeof(double))) return StreamFormats.F64;
            else throw new Exception(string.format("Type {0} not covered by GetFormatString", type));
        }
    }
}
