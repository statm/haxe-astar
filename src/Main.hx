package ;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.Lib;
import flash.Vector;
import statm.explore.haxe.astar.AStar;
import statm.explore.haxe.astar.IAStarClient;
import statm.explore.haxe.astar.IntPoint;

/**
 * ...
 * @author statm
 */

class Main 
{
	
	static function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		
		init();
	}
	
	private static function init():Void
	{
		var map = new MapDisplay(10, 10);
		map.x = map.y = 10;
		Lib.current.addChild(map);
		map.drawMap();
	}
}

class MapDisplay extends Sprite, implements IAStarClient
{
	private inline static var THRESHOLD:Float = 0.2;
	
	public var rowTotal(default, null):Int;
	public var colTotal(default, null):Int;
	
	public function isWalkable(x:Int, y:Int):Bool
	{
		return mapData[y * colTotal + x];
	}
	
	private var mapData:Array<Bool>;
	
	public function new(row:Int, col:Int)
	{
		super();
		
		rowTotal = row;
		colTotal = col;
		shuffle();
		
		this.addEventListener(MouseEvent.CLICK, clickHandler);
	}
	
	public function shuffle():Void
	{
		mapData = new Array<Bool>();
		var t:Int = rowTotal * colTotal;
		for (i in 0...t)
		{
			mapData.push((Math.random() > THRESHOLD));
		}
		AStar.getAStarInstance(this).updateMap();
	}
	
	private var startPoint:IntPoint;
	private var startPointSet:Bool = false;
	
	private function clickHandler(event:MouseEvent):Void
	{
		var START:UInt = 0xFF0000;
		var END:UInt = 0x00FF00;
		var pt:IntPoint = getGridCoord(mouseX, mouseY);
		
		if (!isWalkable(pt.x, pt.y))
		{
			return;
		}
		
		var g = graphics;
		
		if (startPointSet)
		{
			drawGrid(pt.x, pt.y, END);
			
			var path = AStar.getAStarInstance(this).findPath(startPoint, pt);
			if (path == null)
			{
				trace("Path not found.");
				return;
			}
			drawPath(path);
		}
		else
		{
			drawMap();
			
			drawGrid(pt.x, pt.y, START);
			
			startPoint = pt;
		}
		
		startPointSet = !startPointSet;
	}
	
	private function getGridCoord(x:Float, y:Float):IntPoint
	{
		var result:IntPoint = new IntPoint();
		result.x = Std.int(x / 10);
		result.y = Std.int(y / 10);
		
		return result;
	}
	
	public function drawMap():Void
	{
		var BACKGROUND:UInt = 0xEEEEEE;
		var LINE:UInt = 0xBBBBBB;
		var BLOCK:UInt = 0x999999;
		
		var g = graphics;
		
		g.clear();
		
		g.beginFill(BACKGROUND);
		g.drawRect(0, 0, colTotal * 10, rowTotal * 10);
		g.endFill();
		
		var t:Int = rowTotal * colTotal;
		for (i in 0...t)
		{
			var r:Int = Math.floor(i / colTotal);
			var c:Int = i % rowTotal;
			if (!mapData[i])
			{
				drawGrid(c, r, BLOCK);
			}
		}
		
		g.lineStyle(1, LINE);
		g.moveTo(0, 0);
		g.lineTo(0, rowTotal * 10);
		g.lineTo(colTotal * 10, rowTotal * 10);
		g.lineTo(colTotal * 10, 0);
		g.lineTo(0, 0);
		
		g.lineStyle(1, LINE);
		for (i in 1...rowTotal)
		{
			g.moveTo(0, i * 10);
			g.lineTo(colTotal * 10, i * 10);
		}
		for (i in 1...colTotal)
		{
			g.moveTo(i * 10, 0);
			g.lineTo(i * 10, rowTotal * 10);
		}
	}
	
	private function drawGrid(x:Int, y:Int, color:UInt):Void
	{
		var g = graphics;
		g.beginFill(color);
		g.drawRect(x * 10, y * 10, 10, 10);
		g.endFill();
	}
	
	private function drawPath(path:Vector<IntPoint>):Void
	{
		var PATH:UInt = 0xBCD8D0;
		for (i in 1...path.length - 1)
		{
			var grid:IntPoint = path[i];
			drawGrid(grid.x, grid.y, PATH);
		}
	}
}