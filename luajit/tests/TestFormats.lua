-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

SoapySDR = require("SoapySDR")

luaunit = require("luaunit")

function test_FormatSizes()
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.U8), 1)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.S8), 1)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.U16), 2)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.S16), 2)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.U32), 4)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.S32), 4)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.F32), 4)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.F64), 8)

    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CU4), 1)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CS4), 1)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CU8), 2)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CS8), 2)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CU12), 3)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CS12), 3)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CU16), 4)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CS16), 4)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CU32), 8)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CS32), 8)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CF32), 8)
    luaunit.assertEquals(SoapySDR.Format.FormatToSize(SoapySDR.Format.CF64), 16)
end

local runner = luaunit.LuaUnit.new()
os.exit(runner:runSuite())
