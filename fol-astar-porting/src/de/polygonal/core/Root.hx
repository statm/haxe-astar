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
package de.polygonal.core;

import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.log.Log;
import de.polygonal.core.log.LogHandler;
import de.polygonal.core.macro.Assert;
import haxe.PosInfos;

/**
 * <p>The root of an application.</p>
 */
class Root
{
	/**
	 * The root logger; initialized when calling <em>Root.init()</em>.
	 */
	public static var log(default, null):Log = null;
	
	/**
	 * Short for <em>Root.log.info()</em>.<br/>
	 * Example:<br/>
	 * <pre class="prettyprint">
	 * using de.polygonal.core.Root;
	 * "Hello World!".info();
	 * </pre>
	 */
	public static function info(x:String)
	{
		#if debug
		D.assert(log != null, 'call Root.init() first');
		#end
		log.info(x);
	}
	
	/**
	 * Short for <em>Root.log.warn()</em>.<br/>
	 * Example:<br/>
	 * <pre class="prettyprint">
	 * using de.polygonal.core.Root;
	 * "Hello World!".warn();
	 * </pre>
	 */
	public static function warn(x:String)
	{
		#if debug
		D.assert(log != null, 'call Root.init() first');
		#end
		log.warn(x);
	}
	
	/**
	 * Short for <em>Root.log.error()</em>.<br/>
	 * Example:<br/>
	 * <pre class="prettyprint">
	 * using de.polygonal.core.Root;
	 * "Hello World!".error();
	 * </pre>
	 */
	public static function error(x:String)
	{
		#if debug
		D.assert(log != null, 'call Root.init() first');
		#end
		log.error(x);
	}
	
	#if flash
	/**
	 * Returns true if this swf is a remote-swf.<br/>
	 * <warn>Flash only</warn>
	 */
	public static function isRemote():Bool
	{
		return flash.Lib.current.stage.loaderInfo.url.indexOf('file:///') == -1;
	}
	
	/**
	 * Returns the value of the FlashVar with name <code>key</code> or null if the FlashVar does not exist.<br/>
	 * <warn>Flash only</warn>
	 */
	public static function getFlashVar(key:String):String
	{
		try
		{
			return untyped flash.Lib.current.stage.loaderInfo.parameters[key];
		}
		catch (error:Dynamic) {}
		return null;
	}
	#end
	
	/**
	 * Initializes the root logger object.
	 * @param handlers additional log handler objects that get attached to <em>Root.log</em> upon initialization.
	 * @param keepNativeTrace if true, do not override native trace output. Default is false.
	 */
	public static function init(handlers:Array<LogHandler> = null, keepNativeTrace = false)
	{
		#if !no_traces
		var nativeTrace = function(v:Dynamic, ?infos:PosInfos) {};
		if (keepNativeTrace) nativeTrace = haxe.Log.trace;
		
		Log.globalHandler = [];
		#if flash
		Log.globalHandler.push(new de.polygonal.core.log.handler.TraceHandler());
		#elseif cpp
		Log.globalHandler.push(new de.polygonal.core.log.handler.FileHandler('hxcpp_log.txt'));
		#elseif js
		Log.globalHandler.push(new de.polygonal.core.log.handler.ConsoleHandler());
		#end
		
		if (handlers != null)
		{
			for (handler in handlers)
				Log.globalHandler.push(handler);
		}
		
		log = Log.getLog(Root);
		
		haxe.Log.trace = function(x:Dynamic, ?posInfos:PosInfos)
		{
			var s = Std.string(x);
			if (posInfos.customParams != null)
			{
				if (~/%(([+\- #0])*)?((\d+)|(\*))?(\.(\d?|(\*)))?[hlL]?[bcdieEfgGosuxX]/g.match(s))
					s = Sprintf.format(s, posInfos.customParams);
				else
					s += ',' + posInfos.customParams.join(',');
			}
			
			Root.log.debug(s, posInfos);
			nativeTrace(s, posInfos);
		}
		trace('log initialized.');
		#end
	}
}