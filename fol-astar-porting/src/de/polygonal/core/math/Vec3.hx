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

import de.polygonal.ds.Cloneable;
import de.polygonal.core.math.Mathematics;

/**
 * <p>A 3D vector.</p>
 * <p>A geometric object that has both a magnitude (or length) and direction.</p>
 */
class Vec3 implements Cloneable<Vec3>
{
	/**
	 * Creates a new <code>Vec3</code> object from the values of <code>src</code>.
	 */
	inline public static function of(src:Vec3):Vec3
	{
		return new Vec3(src.x, src.y, src.z, src.w);
	}
	
	inline public static function add(a:Vec3, b:Vec3, output:Vec3):Vec3
	{
		output.x = a.x + b.x;
		output.y = a.y + b.y;
		output.z = a.z + b.z;
		return output;
	}
	
	inline public static function sub(a:Vec3, b:Vec3, output:Vec3):Vec3
	{
		output.x = a.x - b.x;
		output.y = a.y - b.y;
		output.z = a.z - b.z;
		return output;
	}
	
	inline public static function cross(a:Vec3, b:Vec3, output:Vec3):Vec3
	{
		output.x = a.y * b.z - a.z * b.y;
		output.y = a.z * b.x - a.x * b.z;
		output.z = a.x * b.y - a.y * b.x;
		return output;
	}
	
	/**
	 * The x-component.
	 */
	public var x:Float;

	/**
	 * The y-component.
	 */
	public var y:Float;
	
	/**
	 * The z-component.
	 */
	public var z:Float;
	
	/**
	 * Homogeneous coordinate. Default is 1.
	 */
	public var w:Float;
	
	public function new(x = .0, y = .0, z = .0, w = 1.)
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	inline public function zero():Vec3
	{
		x = y = z = 0;
		return this;
	}
	
	inline public function flip():Vec3
	{
		x = -x; y = -y; z = -z;
		return this;
	}
	
	inline public function scale(v:Float):Vec3
	{
		x *= v; y *= v; z *= v;
		return this;
	}
	
	public function normalize():Vec3
	{
		var k = length();
		if (k < M.EPS) k = 0 else k = 1. / k;
		x *= k;
		y *= k;
		z *= k;
		return this;
	}
	
	inline public function length():Float
	{
		return Math.sqrt(lengthSq());
	}
	
	inline public function lengthSq():Float
	{
		return x * x + y * y + z * z;
	}
	
	inline public function multiplyMatrix(rhs:Mat44):Vec3
	{
		var tx = x;
		var ty = y;
		var tz = z;
		var tw = w;
		x = tx * rhs.m11 + ty * rhs.m21 + tz * rhs.m31 + tw * rhs.m41;
		y = tx * rhs.m12 + ty * rhs.m22 + tz * rhs.m32 + tw * rhs.m42;
		z = tx * rhs.m13 + ty * rhs.m23 + tz * rhs.m33 + tw * rhs.m43;
		w = tx * rhs.m14 + ty * rhs.m24 + tz * rhs.m34 + tw * rhs.m44;
		return this;
	}
	
	/** Assigns the values of <code>other</code> to this. */
	inline public function set(other:Vec3):Vec3
	{
		x = other.x;
		y = other.y;
		z = other.z;
		w = other.w;
		return this;
	}
	
	public function clone():Vec3
	{
		return new Vec3(x, y, z, w);
	}
	
	public function toString():String
	{
		var format = '{%-+10.4f %-+10.4f %-+10.4f %-+10.4f}';
		return de.polygonal.core.fmt.Sprintf.format(format, [x, y, z, w]);
	}
}