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
package de.polygonal.core.macro;

typedef D = de.polygonal.core.macro.Assert;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Assert
{
	@:macro public static function assert(predicate:ExprRequire<Bool>, ?info:ExprRequire<String>):Expr
	{
		if (!Context.defined('debug')) return {expr: EConst(CInt('0')), pos: Context.currentPos()};
		
		if (!_errorClassDefined) _defineErrorClass();
		
		var error = false;
		switch (haxe.macro.Context.typeof(predicate))
		{
			case TEnum(t, _):
				error = t.get().name != 'Bool';
			default:
				error = true;
		}
		if (error) Context.error('predicate should be a boolean', predicate.pos);
		
		switch (haxe.macro.Context.typeof(info))
		{
			case TMono(t):
				error = t.get() != null;
			case TInst(t, _):
				error = t.get().name != 'String';
			default:
				error = true;
		}
		if (error) Context.error('info should be a string', info.pos);	
		
		var p = Context.currentPos();
		var econd = {expr: EBinop(OpNotEq, {expr: EConst(CIdent('true')), pos: p}, predicate), pos: p};
		var eif = {expr: EThrow({expr: ENew({name: 'AssertError', pack: ['de', 'polygonal'], params: []}, [info]), pos: p}), pos: p};
		return {expr: EIf(econd, eif, null), pos: p};
	}
	
	#if macro
	static var _errorClassDefined:Bool = false;
	static function _defineErrorClass():Void
	{
		var p = Context.currentPos();
		
		var info1 = Context.parse('"Assertation \'" + x + "\' failed in file " + info.fileName + "line " + info.lineNumber + ", " + info.className + "::" + info.methodName', Context.currentPos());
		var info2 = Context.parse('"Assertation failed in file " + info.fileName + "line " + info.lineNumber + ", " + info.className + "::" + info.methodName', Context.currentPos());
		var body = {expr: EIf
		(
			{expr: EBinop(OpNotEq, {expr: EConst(CIdent('x')), pos: p}, {expr: EConst(CIdent('null')), pos: p}), pos: p},
			{expr: EBlock([{expr: EBinop(OpAssign, {expr: EConst(CIdent('message')), pos: p}, info1), pos: p}]), pos: p},
			{expr: EBlock([{expr: EBinop(OpAssign, {expr: EConst(CIdent('message')), pos: p}, info2), pos: p}]), pos: p}
		), pos: p};
		
		Context.defineType
		({
			pack: ['de', 'polygonal'],
			name: 'AssertError',
			pos: p,
			meta: [],
			params: [],
			isExtern: false,
			kind: TDClass(),
			fields:
			[
				{
					name: 'new',
					doc: null,
					meta: [],
					access: [APublic],
					kind: FFun({args:
						[
							{name: 'x', opt: false, type: TPath({pack: [], name: 'String', params: [], sub: null}), value: null},
							{name: 'info', opt: true, type: TPath({pack: ['haxe'], name: 'PosInfos', params: [], sub: null}), value: null}
						],
						ret: null, expr: {expr: EBlock([body]), pos: p}, params: []}), pos: p
				},
				{
					name: 'toString',
					doc: null,
					meta: [],
					access: [APublic],
					kind: FFun({args: [], ret: null, expr: {expr: EBlock([{expr: EReturn({expr: EConst(CIdent('message')), pos: p}), pos: p}]), pos: p}, params: []}), pos: p
				},
				{
					name: 'message',
					doc: null,
					meta: [],
					access: [APublic],
					kind: FVar(TPath({pack: [], name: 'String', params: [], sub: null})), pos: p
				}
			]
		});
		
		_errorClassDefined = true;
	}
	#end
}