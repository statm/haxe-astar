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

import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.macro.Assert;
import de.polygonal.core.math.Mathematics;

/**
 * <p>Fast and accurate sine/cosine approximations.</p>
 * <p>See <a href="http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/" target="_blank">http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/</a></p>
 * <p>Example:</p>
 * <pre class="prettyprint">
 * var sin = TrigApprox.hqSin(angle);
 * var cos = TrigApprox.hqCos(angle);</pre>
 */
class TrigApprox
{
	/**
	 * Computes a low-precision sine approximation from an angle <code>x</code> measured in radians.<br/>
	 * The input angle has to be in the range &#091;-PI, PI&#093;.
	 * @throws de.polygonal.AssertError <code>x</code> out of range (debug only).
	 */
	inline public static function lqSin(x:Float):Float
	{
		D.assert(x >= -Math.PI && x <= Math.PI, Sprintf.format('x out of range (%.3f)', [x]));
		
		if (x < 0)
			return 1.27323954 * x + .405284735 * x * x;
		else
			return 1.27323954 * x - .405284735 * x * x;
	}
	
	/**
	 * Computes a low-precision cosine approximation from an angle <code>x</code> measured in radians.<br/>
	 * The input angle has to be in the range &#091;-PI, PI&#093;.
	 * @throws de.polygonal.AssertError <code>x</code> out of range (debug only).
	 */
	inline public static function lqCos(x:Float):Float
	{
		#if debug
		de.polygonal.core.macro.Assert.assert(x >= -Math.PI && x <= Math.PI, Sprintf.format('x out of range (%.3f)', [x]));
		#end
		
		x += M.PI_OVER_2; if (x > M.PI) x -= M.PI2;
		
		if (x < 0)
			return 1.27323954 * x + .405284735 * x * x
		else
			return 1.27323954 * x - .405284735 * x * x;
	}
	
	/**
	 * Computes a high-precision sine approximation from an angle <code>x</code> measured in radians.<br/>
	 * The input angle has to be in the range &#091;-PI, PI&#093;.
	 * @throws de.polygonal.AssertError <code>x</code> out of range (debug only).
	 */
	inline public static function hqSin(x:Float):Float
	{
		#if debug
		de.polygonal.core.macro.Assert.assert(x >= -Math.PI && x <= Math.PI, Sprintf.format('x out of range (%.3f)', [x]));
		#end
		
		if (x <= 0)
		{
			var s = 1.27323954 * x + .405284735 * x * x;
			if (s < 0)
				return .225 * (s *-s - s) + s;
			else
				return .225 * (s * s - s) + s;
		}
		else
		{
			var s = 1.27323954 * x - .405284735 * x * x;
			if (s < 0)
				return .225 * (s *-s - s) + s;
			else
				return .225 * (s * s - s) + s;
		}
	}
	
	/**
	 * Computes a high-precision cosine approximation from an angle <code>x</code> in radians.<br/>
	 * The input angle has to be in the range &#091;-PI, PI&#093;.
	 * @throws de.polygonal.AssertError <code>x</code> out of range (debug only).
	 */
	inline public static function hqCos(x:Float):Float
	{
		#if debug
		de.polygonal.core.macro.Assert.assert(x >= -Math.PI && x <= Math.PI, Sprintf.format('x out of range (%.3f)', [x]));
		#end
		
		x += M.PI_OVER_2; if (x > M.PI) x -= M.PI2;
		
		if (x < 0)
		{
			var c = 1.27323954 * x + .405284735 * x * x;
			if (c < 0)
				return .225 * (c *-c - c) + c;
			else
				return .225 * (c * c - c) + c;
		}
		else
		{
			var c = 1.27323954 * x - .405284735 * x * x;
			if (c < 0)
				return .225 * (c *-c - c) + c;
			else
				return .225 * (c * c - c) + c;
		}
	}	
	
	/**
	 * Fast arctan2 approximation.<br/>
	 * See <a href="http://www.dspguru.com/dsp/tricks/fixed-point-atan2-with-self-normalization" target="_blank">http://www.dspguru.com/dsp/tricks/fixed-point-atan2-with-self-normalization</a>.
	 */
	inline public static function arctan2(y:Float, x:Float):Float
	{
		#if debug
		de.polygonal.core.macro.Assert.assert(!(M.cmpZero(x, 1e-6) && M.cmpZero(y, 1e-6)), 'M.compareZero(x, 1e-6) && M.compareZero(y, 1e-6);');
		#end
		
		var t = M.fabs(y);
		if (x >= .0)
		{
			if (y < .0)
				return-(M.PI_OVER_4 - M.PI_OVER_4 * ((x - t) / (x + t)));
			else
				return (M.PI_OVER_4 - M.PI_OVER_4 * ((x - t) / (x + t)));
		}
		else
		{
			if (y < .0)
				return-((3. * M.PI_OVER_4) - M.PI_OVER_4 * ((x + t) / (t - x)));
			else
				return ((3. * M.PI_OVER_4) - M.PI_OVER_4 * ((x + t) / (t - x)));
		}
	}
	
	/**
	 * Returns the floating-point sine and cosine of the argument <code>a</code>.<br/>
	 * This method uses a polynomial approximation.<br/>
	 * Borrowed from the book ESSENTIAL MATHEMATICS FOR GAMES & INTERACTIVE APPLICATIONS
	 * Copyright (C) 2008 by Elsevier, Inc. All rights reserved.
	 * @param out a vector storing the result, where <code>out</code>.x equals sine and <code>out</code>.y equals cosine.
	 */
	inline static var INV_PIHALF = 0.6366197723675814;
	inline static var CONST_A = 1.5703125; //201 / 128
	inline public static function sinCos(a:Float, out:Vec2):Vec2
	{
		var negate = false;
		if (a < 0.)
		{
			a = -a;
			negate = true;
		}
		
		var fa = INV_PIHALF * a;
		var ia = Std.int(fa);
		fa = (a - CONST_A * ia) - 4.8382679e-4 * ia;
		
		switch (ia & 3)
		{
			case 0:
				out.x = IvPolynomialSinQuadrant(fa);
				out.y = IvPolynomialSinQuadrant(-((fa - CONST_A) - 4.8382679e-4));
			
			case 1:
				out.x = IvPolynomialSinQuadrant(-((fa - CONST_A) - 4.8382679e-4));
				out.y = IvPolynomialSinQuadrant(-fa);
			
			case 2:
				out.x = IvPolynomialSinQuadrant(-fa);
				out.y = IvPolynomialSinQuadrant(((fa - CONST_A) - 4.8382679e-4));
			
			case 3:
				out.x = IvPolynomialSinQuadrant(((fa - CONST_A) - 4.8382679e-4));
				out.y = IvPolynomialSinQuadrant(fa);
		}
		
		if (negate) out.x = -out.x;
		
		return out;
	}
	
	inline static function IvPolynomialSinQuadrant(a:Float)
	{
		return a * (1. + a * a * (-.16666 + a * a * (.0083143 - a * a * .00018542)));
	}
}