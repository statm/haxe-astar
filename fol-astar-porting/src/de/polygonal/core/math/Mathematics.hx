/*
 *                            _/                                                    _/
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/
 *   _/                            _/        _/
 *  _/                        _/_/      _/_/
 *
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.polygonal.core.math;

typedef M = de.polygonal.core.math.Mathematics;

/**
 * <p>Various math functions and constants.</p>
 */
class Mathematics
{
	/**
	 * IEEE 754 NAN.
	 */
	#if !flash
	public static var NaN = Math.NaN;
	#else
	inline public static var NaN = .0 / .0;
	#end
	/**
	 * IEEE 754 positive infinity.
	 */
	#if !flash
	public static var POSITIVE_INFINITY = Math.POSITIVE_INFINITY;
	#else
	inline public static var POSITIVE_INFINITY = 1. / .0;
	#end
	/**
	 * IEEE 754 negative infinity.
	 */
	#if !flash
	public static var NEGATIVE_INFINITY = Math.NEGATIVE_INFINITY;
	#else
	inline public static var NEGATIVE_INFINITY = -1. / .0;
	#end
	
	/**
	 * Value below <em>ZERO_TOLERANCE</em> is treated as zero.
	 */
	inline public static var ZERO_TOLERANCE = 1e-08;
	
	/**
	 * Multiply value by this constant to convert from radians to degrees (180 / PI).
	 */
	inline public static var RAD_DEG = 57.29577951308232;
	
	/**
	 * Multiply value by this constant to convert from degrees to radians (PI / 180).
	 */
	inline public static var DEG_RAD = 0.017453292519943295;
	
	/**
	 * The natural logarithm of 2.
	 */
	inline public static var LN2 = 0.6931471805599453;
	
	/**
	 * The natural logarithm of 10.
	 */
	inline public static var LN10 = 2.302585092994046;
	
	/**
	 * PI / 2.
	 */
	inline public static var PI_OVER_2 = 1.5707963267948966;
	
	/**
	 * PI / 4.
	 */
	inline public static var PI_OVER_4 = 0.7853981633974483;
	
	/**
	 * PI.
	 */
	inline public static var PI = 3.141592653589793;
	
	/**
	 * 2 * PI.
	 */
	inline public static var PI2 = 6.283185307179586;
	
	/**
	 * Default system epsilon.
	 */
	inline public static var EPS = 1e-6;
	
	/**
	 * The square root of 2.
	 */
	inline public static var SQRT2 = 1.414213562373095;
	
	#if (flash10 && alchemy)
	/**
	 * Returns the 32-bit integer representation of a IEEE 754 single precision floating point.
	 */
	inline public static function floatToInt(x:Float):Int
	{
		flash.Memory.setFloat(0, x);
		return flash.Memory.getI32(0);
	}
	
	/**
	 * Returns the IEEE 754 single precision floating point representation of a 32-bit integer.
	 */
	inline public static function intToFloat(x:Int):Float
	{
		flash.Memory.setI32(0, x);
		return flash.Memory.getFloat(0);
	}
	#end
	
	/**
	 * Converts <code>deg</code> to radians.
	 */
	inline public static function toRad(deg:Float):Float
	{
		return deg * DEG_RAD;
	}
	
	/**
	 * Converts <code>rad</code> to degrees.
	 */
	inline public static function toDeg(rad:Float):Float
	{
		return rad * RAD_DEG;
	}
	
	/**
	 * Returns min(<code>x</code>, <code>y</code>).
	 */
	inline public static function min(x:Int, y:Int):Int
	{
		return x < y ? x : y;
	}
	
	/**
	 * Returns max(<code>x</code>, <code>y</code>).
	 */
	inline public static function max(x:Int, y:Int):Int
	{
		return x > y ? x : y;
	}
	
	/**
	 * Returns the absolute value of <code>x</code>.
	 */
	inline public static function abs(x:Int):Int
	{
		return x < 0 ? -x : x;
	}
	
	/**
	 * Returns the sign of <code>x</code>.<br/>
	 * <em>sgn</em>(0) = 0.
	 */
	inline public static function sgn(x:Int):Int
	{
		return (x > 0) ? 1 : (x < 0 ? -1 : 0);
	}
	
	/**
	 * Clamps <code>x</code> to the interval &#091;<code>min</code>, <code>max</code>&#093; so <code>min</code> <= <code>x</code> <= <code>max</code>.
	 */
	inline public static function clamp(x:Int, min:Int, max:Int):Int
	{
		return (x < min) ? min : (x > max) ? max : x;
	}
	
	/**
	 * Clamps <code>x</code> to the interval &#091;<code>-i</code>, <code>+i</code>&#093; so <code>-i</code> <= <code>x</code> <= <code>i</code>.
	 */
	inline public static function clampSym(x:Int, i:Int):Int
	{
		return (x < -i) ? -i : (x > i) ? i : x;
	}
	
	/**
	 * Wraps <code>x</code> to the interval &#091;<code>min</code>, <code>max</code>&#093; so <code>min</code> <= <code>x</code> <= <code>max</code>.
	 */
	inline public static function wrap(x:Int, min:Int, max:Int):Int
	{
		return x < min ? (x - min) + max + 1: ((x > max) ? (x - max) + min - 1: x);
	}
	
	/**
	 * Fast version of <em>Math.min</em>(<code>x</code>, <code>y</code>).
	 */
	inline public static function fmin(x:Float, y:Float):Float
	{
		return x < y ? x : y;
	}
	
	/**
	 * Fast version of <em>Math.max</em>(<code>x</code>, <code>y</code>).
	 */
	inline public static function fmax(x:Float, y:Float):Float
	{
		return x > y ? x : y;
	}
	
	/**
	 * Fast version of <em>Math.abs</em>(<code>x</code>).
	 */
	inline public static function fabs(x:Float):Float
	{
		return x < 0 ? -x : x;
	}
	
	/**
	 * Extracts the sign of <code>x</code>.<br/>
	 * <em>fsgn</em>(0) = 0.
	 */
	inline public static function fsgn(x:Float):Int
	{
		return (x > 0.) ? 1 : (x < 0. ? -1 : 0);
	}
	
	/**
	 * Clamps <code>x</code> to the interval &#091;<code>min</code>, <code>max</code>&#093; so <code>min</code> <= <code>x</code> <= <code>max</code>.
	 */
	inline public static function fclamp(x:Float, min:Float, max:Float):Float
	{
		return (x < min) ? min : (x > max) ? max : x;
	}
	
	/**
	 * Clamps <code>x</code> to the interval &#091;<code>-i</code>, <code>+i</code>&#093; so -<code>i</code> <= <code>x</code> <= <code>i</code>.
	 */
	inline public static function fclampSym(x:Float, i:Float):Float
	{
		return (x < -i) ? -i : (x > i) ? i : x;
	}
	
	/**
	 * Wraps <code>x</code> to the interval &#091;<code>min</code>, <code>max</code>&#093; so <code>min</code> <= <code>x</code> <= <code>max</code>.
	 */
	inline public static function fwrap(value:Float, lower:Float, upper:Float):Float
	{
		#if js
		return value - (Std.int((value - lower) / (upper - lower)) * (upper - lower));
		#else
		return value - (cast((value - lower) / (upper - lower)) * (upper - lower));
		#end
	}

	/**
	 * Returns true if the sign of <code>x</code> and <code>y</code> is equal.
	 */
	inline public static function eqSgn(x:Int, y:Int):Bool
	{
		return (x ^ y) >= 0;
	}
	
	/**
	 * Returns true if <code>x</code> is even.
	 */
	inline public static function isEven(x:Int):Bool
	{
		return (x & 1) == 0;
	}
	
	/**
	 * Returns true if <code>x</code> is a power of two.
	 */
	inline public static function isPow2(x:Int):Bool
	{
		return x > 0 && (x & (x - 1)) == 0;
	}
	
	/**
	 * Linear interpolation over interval &#091;<code>a</code>, <code>b</code>&#093; with <code>t</code> = &#091;0, 1&#093;.
	 */
	inline public static function lerp(a:Float, b:Float, t:Float):Float
	{
		return a + (b - a) * t;
	}
	
	/**
	 * Spherically interpolates between two angles.<br/>
	 * See <a href="http://www.paradeofrain.com/2009/07/interpolating-2d-rotations/" target="_blank">http://www.paradeofrain.com/2009/07/interpolating-2d-rotations/</a>.
	 */
	inline public static function slerp(a:Float, b:Float, t:Float)
	{
		var m = Math;
		
        var c1 = m.sin(a * .5);
        var r1 = m.cos(a * .5);
		var c2 = m.sin(b * .5);
        var r2 = m.cos(b * .5);

       var c = r1 * r2 + c1 * c2;

        if (c < 0.)
		{
			if ((1. + c) > EPS)
			{
				var o = m.acos(-c);
				var s = m.sin(o);
				var s0 = m.sin((1 - t) * o) / s;
				var s1 = m.sin(t * o) / s;
				return m.atan2(s0 * c1 - s1 * c2, s0 * r1 - s1 * r2) * 2.;
			}
			else
			{
				var s0 = 1 - t;
				var s1 = t;
				return m.atan2(s0 * c1 - s1 * c2, s0 * r1 - s1 * r2) * 2;
			}
		}
		else
		{
			if ((1 - c) > EPS)
			{
				var o = m.acos(c);
				var s = m.sin(o);
				var s0 = m.sin((1 - t) * o) / s;
				var s1 = m.sin(t * o) / s;
				return m.atan2(s0 * c1 + s1 * c2, s0 * r1 + s1 * r2) * 2.;
			}
			else
			{
				var s0 = 1 - t;
				var s1 = t;
				return m.atan2(s0 * c1 + s1 * c2, s0 * r1 + s1 * r2) * 2;
			}
		}
	}
	
	/**
	 * Calculates the next highest power of 2 of <code>x</code>.<br/>
	 * <code>x</code> must be in the range 0...(2^30)<br/>
	 * Returns <code>x</code> if already a power of 2.
	 */
	inline public static function nextPow2(x:Int):Int
	{
		var t = x - 1;
		t |= (t >> 1);
		t |= (t >> 2);
		t |= (t >> 4);
		t |= (t >> 8);
		t |= (t >> 16);
		return t + 1;
	}
	
	/**
	 * Fast integer exponentiation for base <code>a</code> and exponent <code>n</code>.
	 */
	inline public static function exp(a:Int, n:Int):Int
	{
		var t = 1;
		var r = 0;
		while (true)
		{
			if (n & 1 != 0) t = a * t;
			n >>= 1;
			if (n == 0)
			{
				r = t;
				break;
			}
			else
				a *= a;
		}
		return r;
	}
	
	/**
	 * Returns the base-10 logarithm of <code>x</code>.
	 */
	inline public static function log10(x:Float):Float
	{
		return Math.log(x) * 0.4342944819032517;
	}
	
	/**
	 * Rounds <code>x</code> to the iterval <code>y</code>.
	 */
	inline public static function roundTo(x:Float, y:Float):Float
	{
		#if js
		return Math.round(x / y) * y;
		#elseif flash
		var t:Float = untyped __global__['Math'].round((x / y));
		return t * y;
		#else
		var t = x / y;
		if (t < Limits.INT32_MAX && t > Limits.INT32_MIN)
			return round(t) * y;
		else
		{
			t = (t > 0 ? t + .5 : (t < 0 ? t - .5 : t));
			return (t - t % 1) * y;
		}
		#end
	}
	
	/**
	 * Fast version of <em>Math.round</em>(<code>x</code>).<br/>
	 * Half-way cases are rounded away from zero.
	 */
	inline public static function round(x:Float):Int
	{
		return Std.int(x + (0x4000 + .5)) - 0x4000;
	}
	
	/**
	 * Fast version of <em>Math.ceil</em>(<code>x</code>).
	 */
	inline public static function ceil(x:Float):Int
	{
		var f:Int =
		#if js
		Std.int(x);
		#else
		cast x;
		#end
		if (x == f) return f;
		else
		{
			x += 1;
			var f:Int =
			#if js
			Std.int(x);
			#else
			cast x;
			#end
			if (x < 0 && f != x) f--;
			return f;
		}
	}
	
	/**
	 * Fast version of <em>Math.floor</em>(<code>x</code>).
	 */
	inline public static function floor(x:Float):Int
	{
		var f:Int =
		#if js
		Std.int(x);
		#else
		cast x;
		#end
		if (x < 0 && f != x) f--;
		return f;
	}
	
	/**
	 * Computes the 'quake-style' fast square root of <code>x</code>.
	 */
	inline public static function sqrt(x:Float):Float
	{
		#if (flash10 && alchemy)
		var xt = x;
		var half = .5 * xt;
		var i = floatToInt(xt);
		i = 0x5f3759df - (i >> 1);
		var xt = intToFloat(i);
		return 1 / (xt * (1.5 - half * xt * xt));
		#else
		return Math.sqrt(x);
		#end
	}
	
	/**
	 * Computes the 'quake-style' fast inverse square root of <code>x</code>.
	 */
	inline public static function invSqrt(x:Float):Float
	{
		#if (flash10 && alchemy)
		var xt = x;
		var half = .5 * xt;
		var i = floatToInt(xt);
		i = 0x5f3759df - (i >> 1);
		var xt = intToFloat(i);
		return xt * (1.5 - half * xt * xt);
		#else
		return 1 / Math.sqrt(x);
		#end
	}
	
	/**
	 * Compares <code>x</code> and <code>y</code> using an absolute tolerance of <code>eps</code>.
	 */
	inline public static function cmpAbs(x:Float, y:Float, eps:Float):Bool
	{
		var d = x - y;
		return d > 0 ? d < eps : -d < eps;
	}
	
	/**
	 * Compares <code>x</code> to zero using an absolute tolerance of <code>eps</code>.
	 */
	inline public static function cmpZero(x:Float, eps:Float):Bool
	{
		return x > 0 ? x < eps : -x < eps;
	}
	
	/**
	 * Snaps <code>x</code> to the grid <code>y</code>.
	 */
	inline public static function snap(x:Float, y:Float):Float
	{
		return (floor((x + y * .5) / y));
	}
	
	/**
	 * Returns true if <code>min</code> <= <code>x</code> <= <code>max</code>.
	 */
	inline public static function inRange(x:Float, min:Float, max:Float):Bool
	{
		return x >= min && x <= max;
	}
	
	/**
	 * Wraps an angle <code>x</code> to the range -PI...PI.
	 */
	inline public static function wrapToPI(x:Float):Float
	{
		x += PI;
		return (x - PI2 * Math.floor(x / PI2)) - PI;
	}
	
	/**
	 * Wraps an angle <code>x</code> to the range 0...2*PI.
	 */
	inline public static function wrapToPI2(x:Float):Float
	{
		return (x - PI2 * Math.floor(x / PI2));
	}
	
	/**
	 * Computes the greatest common divisor of <code>x</code> and <code>y</code>.<br/>
	 * See <a href="http://www.merriampark.com/gcd.htm" target="_blank">http://www.merriampark.com/gcd.htm</a>.
	 */
	inline public static function gcd(x:Int, y:Int):Int
	{
		var d = 0;
		var r = 0;
		x = abs(x);
		y = abs(y);
		while (true)
		{
			if (y == 0)
			{
				d = x;
				break;
			}
			else
			{
				r = x % y;
				x = y;
				y = r;
			}
		}
		return d;
	}
	
	/**
	 * Removes excess floating point decimal precision from <code>x</code>.
	 */
	inline public static function maxPrecision(x:Float, precision:Int):Float
	{
		return roundTo(x, Math.pow(10, -precision));
	}
	
	/**
	 * Converts the boolean expression <code>x</code> to an integer.
	 * @return 1 if <code>x</code> is true and zero if <code>x</code> is false.
	 */
	inline public static function ofBool(x:Bool):Int
	{
		return (x ? 1 : 0);
	}
}