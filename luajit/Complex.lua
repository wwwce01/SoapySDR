-- Copyright (c) 2021 Nicholas Corgan
-- SPDX-License-Identifier: BSL-1.0

local ffi = require("ffi")

-- Based on: https://github.com/krakow10/Complex-Number-Library/blob/master/LuaJIT/Complex.lua
local function Complex(re,im)
    return ffi.new("complex",re,im)
end

local function re(n)
	return ffi.istype("complex",n) and n.re or type(n)=="number" and n or 0
end

local function im(n)
	return ffi.istype("complex",n) and n.im or 0
end

-- Useful stuff for FFI's complex struct instead of
-- just allowing field access.
local complexMetaTable =
{
    __add = function(c1,c2)
		return Complex(re(c1)+re(c2), im(c1)+im(c2))
	end,

	__sub = function(c1,c2)
		return Complex(re(c1)-re(c2), im(c1)-im(c2))
	end,

	__mul = function(c1,c2)
		local r1,i1,r2,i2=re(c1),im(c1),re(c2),im(c2)
		return Complex(r1*r2-i1*i2, r1*i2+r2*i1)
	end,

	__div = function(c1,c2)
		local r1,i1,r2,i2=re(c1),im(c1),re(c2),im(c2)
		local rsq=r2^2+i2^2
		return Complex((r1*r2+i1*i2)/rsq,(r2*i1-r1*i2)/rsq)
	end
}
ffi.metatype(ffi.typeof'complex',complexMetaTable)

return Complex
