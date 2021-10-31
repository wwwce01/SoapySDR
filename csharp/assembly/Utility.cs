// Copyright (c) 2020-2021 Nicholas Corgan
// SPDX-License-Identifier: BSL-1.0

using System;
using System.Buffers;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;

namespace SoapySDR
{
    public class Utility
    {
        internal static void ValidateMemory<T>(
            StreamHandle streamHandle,
            ReadOnlyMemory<T>[] mems) where T : unmanaged
        {
            var numChannels = streamHandle.GetChannels().Count;
            var format = streamHandle.GetFormat();

            var scalarFormatString = GetFormatString<T>();
            var complexFormatString = GetComplexFormatString<T>();

            if (mems == null)
            {
                throw new ArgumentNullException("buffs");
            }
            else if (mems.Length != numChannels)
            {
                throw new ArgumentException(string.Format("Expected {0} channels. Found {1} buffers.", numChannels, mems.Length));
            }
            else if (!format.Equals(scalarFormatString) && !format.Equals(complexFormatString))
            {
                throw new ArgumentException(string.Format("Expected format \"{0}\" or \"{1}\". Found format \"{2}\"",
                    scalarFormatString,
                    complexFormatString,
                    format));
            }

            HashSet<int> uniqueSizes = new HashSet<int>(mems.Select(buff => buff.Length));
            if ((uniqueSizes.Count > 1) || (uniqueSizes.First() == 0))
                throw new ArgumentException("All buffers must be non-null and of the same length");

            if (format.Equals(complexFormatString))
            {
                if ((uniqueSizes.First() % 2) != 0)
                    throw new ArgumentException("For complex interleaved streams, the input buffer must be of an even size");
            }
        }

        internal static void ValidateMemory<T>(
            StreamHandle streamHandle,
            Memory<T>[] mems) where T : unmanaged => ValidateMemory<T>(streamHandle, mems.Select(mem => (ReadOnlyMemory<T>)mem).ToArray());

        internal static void ValidateBuffs<T>(
            StreamHandle streamHandle,
            T[][] buffs) where T: unmanaged
        {
            var numChannels = streamHandle.GetChannels().Count;
            var format = streamHandle.GetFormat();

            var scalarFormatString = GetFormatString<T>();
            var complexFormatString = GetComplexFormatString<T>();

            if(buffs == null)
            {
                throw new ArgumentNullException("buffs");
            }
            else if(buffs.Length != numChannels)
            {
                throw new ArgumentException(string.Format("Expected {0} channels. Found {1} buffers.", numChannels, buffs.Length));
            }
            else if(!format.Equals(scalarFormatString) && !format.Equals(complexFormatString))
            {
                throw new ArgumentException(string.Format("Expected format \"{0}\" or \"{1}\". Found format \"{2}\"",
                    scalarFormatString,
                    complexFormatString,
                    format));
            }

            HashSet<int> uniqueSizes = new HashSet<int>(buffs.Select(buff => buff?.Length ?? 0));
            if ((uniqueSizes.Count > 1) || (uniqueSizes.First() == 0))
                throw new ArgumentException("All buffers must be non-null and of the same length");

            if (format.Equals(complexFormatString))
            {
                if ((uniqueSizes.First() % 2) != 0)
                    throw new ArgumentException("For complex interleaved streams, the input buffer must be of an even size");
            }
        }

        internal static unsafe void ManagedArraysToSizeList<T>(
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

                var uptr = (UIntPtr)(void*)handles[buffIndex].AddrOfPinnedObject();
#if _64BIT
                sizeList.Add((ulong)uptr);
#else
                sizeList.Add((uint)uptr);
#endif
            }
        }

        public static string GetFormatString<T>() where T: unmanaged
        {
            var type = typeof(T);

            if(typeof(T).Equals(typeof(sbyte)))       return StreamFormat.S8;
            else if(typeof(T).Equals(typeof(short)))  return StreamFormat.S16;
            else if(typeof(T).Equals(typeof(int)))    return StreamFormat.S32;
            else if(typeof(T).Equals(typeof(byte)))   return StreamFormat.U8;
            else if(typeof(T).Equals(typeof(ushort))) return StreamFormat.U16;
            else if(typeof(T).Equals(typeof(uint)))   return StreamFormat.U32;
            else if(typeof(T).Equals(typeof(float)))  return StreamFormat.F32;
            else if(typeof(T).Equals(typeof(double))) return StreamFormat.F64;
            else throw new Exception(string.Format("Type {0} not covered by GetFormatString", type));
        }

        public static string GetComplexFormatString<T>() where T : unmanaged
        {
            var type = typeof(T);

            if (typeof(T).Equals(typeof(sbyte))) return StreamFormat.CS8;
            else if (typeof(T).Equals(typeof(short))) return StreamFormat.CS16;
            else if (typeof(T).Equals(typeof(int))) return StreamFormat.CS32;
            else if (typeof(T).Equals(typeof(byte))) return StreamFormat.CU8;
            else if (typeof(T).Equals(typeof(ushort))) return StreamFormat.CU16;
            else if (typeof(T).Equals(typeof(uint))) return StreamFormat.CU32;
            else if (typeof(T).Equals(typeof(float))) return StreamFormat.CF32;
            else if (typeof(T).Equals(typeof(double))) return StreamFormat.CF64;
            else throw new Exception(string.Format("Type {0} not covered by GetComplexFormatString", type));
        }

        internal static Kwargs ToKwargs(IDictionary<string, string> input)
        {
            if (input is Kwargs) return (Kwargs)input;

            Kwargs kwargs;

            var output = new Kwargs();
            foreach(var pair in input)
            {
                output.Add(pair.Key, pair.Value);
            }

            return output;
        }

        internal unsafe static SizeList ToSizeList<T>(
            Memory<T>[] memory,
            out MemoryHandle[] memoryHandles)
        {
            memoryHandles = memory.Select(mem => mem.Pin()).ToArray();
            return ToSizeList(memoryHandles.Select(handle => (UIntPtr)handle.Pointer).ToArray());
        }

        internal unsafe static SizeList ToSizeList<T>(
            ReadOnlyMemory<T>[] memory,
            out MemoryHandle[] memoryHandles)
        {
            memoryHandles = memory.Select(mem => mem.Pin()).ToArray();
            return ToSizeList(memoryHandles.Select(handle => (UIntPtr)handle.Pointer).ToArray());
        }

#if _64BIT
        internal static SizeList ToSizeList(uint[] arr) => new SizeList(arr.Select(x => (ulong)x));

        internal static SizeList ToSizeList(UIntPtr[] arr) => new SizeList(arr.Select(x => (ulong)x));

        internal unsafe static SizeList ToSizeList(IntPtr[] arr) => new SizeList(arr.Select(x => (ulong)(UIntPtr)(void*)x));
#else
        internal static SizeList ToSizeList(uint[] arr) => new SizeList(arr);

        internal static SizeList ToSizeList(UIntPtr[] arr) => new SizeList(arr.Select(x => (uint)x));

        internal unsafe static SizeList ToSizeList(IntPtr[] arr) => new SizeList(arr.Select(x => (uint)(UIntPtr)(void*)x));
#endif

        // TODO: how many copies are made below?

        internal static Dictionary<string, string> ToDictionary(Kwargs kwargs) => kwargs.ToDictionary(entry => entry.Key, entry => entry.Value);

        internal static List<Dictionary<string, string>> ToDictionaryList(KwargsList kwargsList) => new List<Dictionary<string, string>>(kwargsList.Select(arg => ToDictionary(arg)));

        internal static List<ArgInfo> ToArgInfoList(ArgInfoInternalList argInfoInternalList) => new List<ArgInfo>(argInfoInternalList.Select(x => new ArgInfo(x)));

        internal static List<Range> ToRangeList(RangeInternalList rangeInternalList) => new List<Range>(rangeInternalList.Select(x => new Range(x)));
    }
}
