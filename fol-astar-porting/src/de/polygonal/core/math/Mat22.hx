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
import de.polygonal.core.math.Vec2;
import de.polygonal.ds.Cloneable;
import de.polygonal.core.math.Mathematics;

/**
 * |cos(O) -sin(O)| |1 0| |0 -1|
 * |sin(O)  cos(O)| |0 1| |1  0|
 * 
 * I + (sin(O)S + (1 - cos(O))S^2
 * 
 * For positive angle, RV rotates the 2x1 vector V CCW about the origin
 */
class Mat22 implements Cloneable<Mat22>
{
	inline public static function concat(A:Mat22, B:Mat22, out:Mat22):Mat22
	{
		var t1 = A.m11;
		var t2 = A.m12;
		var t3 = A.m21;
		var t4 = A.m22;
		var t5 = B.m11;
		var t6 = B.m12;
		var t7 = B.m21;
		var t8 = B.m22;
		out.m11 = t1 * t5 + t2 * t7; out.m12 = t1 * t6 + t2 * t8;
		out.m21 = t3 * t5 + t4 * t7; out.m22 = t3 * t6 + t4 * t8;
		return out;
	}
	
	public var m11:Float; public var m12:Float;
	public var m21:Float; public var m22:Float;
	
	public function new(?col1:Vec2, ?col2:Vec2) 
	{
		if (col1 == null)
		{
			m11 = 1;
			m21 = 0;
		}
		else
		{
			m11 = col1.x;
			m21 = col1.y;
		}
			
		if (col2 == null)
		{
			m12 = 0;
			m22 = 1;
		}
		else
		{
			m12 = col2.x;
			m22 = col2.y;
		}
	}
	
	inline public function mul(v:Vec2, out:Vec2):Void
	{
		var x = v.x;
		var y = v.y;
		out.x = x * m11 + y * m12;
		out.y = x * m21 + y * m22;
	}
	
	inline public function mulx(x:Float, y:Float):Float
	{
		return x * m11 + y * m12;
	}
	
	inline public function muly(x:Float, y:Float):Float
	{
		return x * m21 + y * m22;
	}
	
	inline public function setAngle(angle:Float)
	{
		var c = Math.cos(angle), s = Math.sin(angle);
		m11 = c; m12 =-s;
		m21 = s; m22 = c;
	}
	
	inline public function transpose():Void
	{
		var tmp = m21; m21 = m12; m12 = tmp;
	}
	
	inline public function setCol1(x:Float, y:Float):Void
	{
		m11 = x;
		m21 = y;
	}
	
	inline public function setCol2(x:Float, y:Float):Void
	{
		m12 = x;
		m22 = y;
	}
	
	inline public function identity():Void
	{
		m11 = 1; m12 = 0;
		m21 = 0; m22 = 1;
	}
	
	/**
	 * Computes the matrix inverse and stores the result in <code>output</code>.<br/>
	 * This matrix is left unchanged.
	 * @return a reference to <code>output</code>.
	 */
	public function inverseConst(output:Mat22):Mat22
	{
		var det = m11 * m22 - m12 * m21;
		
		if (M.fabs(det) > M.ZERO_TOLERANCE)
		{
			var invDet = 1 / det;
			output.m11 =  m22 * invDet;
			output.m12 = -m12 * invDet;
			output.m21 = -m21 * invDet;
			output.m22 =  m11 * invDet;
		}
		else
		{
			output.m11 = 0; output.m12 = 0;
			output.m21 = 0; output.m22 = 0;
		}

		return output;
	}
	
	/**
	 * Applies Gram-Schmidt orthogonalization to this matrix.<br/>
	 * Restores the matrix to a rotation to fight the accumulation of round-off errors due to frequent concatenation with other matrices.
	 * <warn>The matrix must be a rotation matrix</warn>.
	 */
	public function orthonormalize():Void
	{
		var t = Math.sqrt(m11 * m11 + m21 * m21);
		m11 /= t;
		m21 /= t;
		t = m11 * m12 + m21 * m22;
		m12 -= t * m11;
		m22 -= t * m21;
		t = Math.sqrt(m12 * m12 + m22 * m22);
		m12 /= t;
		m22 /= t;
	}
	
	/**
	 * Extracts the angle of rotation from this matrix.<br/>
	 * The angle is computed as atan2(sin(alpha), cos(alpha)) = atan2(<em>m21</em>, <em>m11</em>).<br/>
	 * <warn>The matrix must be a rotation matrix</warn>.
	 */
	inline public function getAngle():Float
	{
		return Math.atan2(m21, m11);
	}
	
	/** Returns the string form of the value that the object represents. */
	public function toString():String
	{
		return Sprintf.format('Mat22\n%6.3f %6.3f\n%6.3f %6.3f', [m11, m21, m12, m22]);
	}
	
	/** Creates and returns a copy of this object. */
	public function clone():Mat22
	{
		var c = new Mat22();
		c.m11 = m11; c.m12 = m12;
		c.m21 = m21; c.m22 = m22;
		return c;
	}
}