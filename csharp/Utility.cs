// Copyright (c) 2020-201 Nicholas Corgan
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
            SizeList channels,
            ref T[][] buffs) where T: unmanaged
        {
            if(buffs == null)
            {
                throw new ArgumentNullException("buffs");
            }
            if(buffs.Length != channels.Length)
            {
                throw new ArgumentException(string.format("Expected {0} channels. Found {1} buffers.", channels.Length, buffs.Length));
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
    }
}
