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
package de.polygonal.core.sys;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.fmt.Sprintf;
import de.polygonal.core.time.StopWatch;
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.core.time.Timeline;

import de.polygonal.core.event.Observable.ObserverNode;

class MainLoop extends Entity
{
	var _timebase:Timebase;
	var _timeline:Timeline;
	
	#if profile
	public static var stopWatchSlotAdvance:Int;
	public static var stopWatchSlotRender:Int;
	#end
	
	var _paused:Bool;
	
	public function new()
	{
		super();
		
		_timebase = Timebase.get();
		_timebase.attach(this);
		_timeline = Timeline.get();
		
		#if debug
		de.polygonal.ui.UI.get().attach(this, de.polygonal.ui.UIEvent.KEY_DOWN);
		#end
		
		#if profile
		stopWatchSlotAdvance = StopWatch.getFreeSlot();
		stopWatchSlotRender = StopWatch.getFreeSlot();
		#end
	}
	
	public function pause():Void
	{
		_timebase.halt();
		_paused = true;
	}
	
	public function resume():Void
	{
		_timebase.resume();
		_paused = false;
	}
	
	override public function update(type:Int, source:IObservable, userData:Dynamic):Void
	{
		switch (type)
		{
			case TimebaseEvent.TICK:
				_timeline.advance();
				
				#if (!no_traces)
				//identify update step
				for (handler in de.polygonal.core.Root.log.getLogHandler())
					handler.setPrefix(de.polygonal.core.fmt.Sprintf.format('t%03d', [_timebase.getProcessedTicks() % 1000]));
				#end
				
				commit();
				
				#if debug
				var s = Entity.printTopologyStats();
				if (s != null) trace(s);
				#end
				
				#if profile
				StopWatch.clock(stopWatchSlotAdvance);
				#end
				
				advance(userData);
				
				#if profile
				StopWatch.clock(stopWatchSlotAdvance);
				#end
				
			case TimebaseEvent.RENDER:
				#if (!no_traces)
				//identify rendering step
				for (handler in de.polygonal.core.Root.log.getLogHandler())
					handler.setPrefix(de.polygonal.core.fmt.Sprintf.format('r%03d', [_timebase.getProcessedFrames() % 1000]));
				#end
				
				#if profile
				StopWatch.clock(stopWatchSlotRender);
				#end
				
				render(userData);
				
				#if profile
				StopWatch.clock(stopWatchSlotRender);
				#end
				
			#if debug
			//pause game graph traversal; perform manual updates when pressing '`'
			case de.polygonal.ui.UIEvent.KEY_DOWN:
				#if flash
				if (de.polygonal.ui.UI.get().currCharCode == de.polygonal.core.fmt.ASCII.TILDE)
				{
					if (_paused)
						_timebase.manualStep();
				}
				if (de.polygonal.ui.UI.get().currCharCode == de.polygonal.core.fmt.ASCII.GRAVE)
				{
					_paused ? resume() : pause();
				}
				#end
			#end
		}
	}
}