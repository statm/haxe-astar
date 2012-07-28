package ;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import statm.explore.haxe.astar.AStar;
import statm.explore.haxe.astar.IAStarClient;

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
		var map = new MapDisplay();
		map.rowTotal = 10;
		map.colTotal = 5;
		Lib.current.addChild(map);
		map.drawMap();
		
		AStar.getAStarInstance(map);
	}
}

class MapDisplay extends Sprite, implements IAStarClient
{
	public var rowTotal(default, default):Int;
	public var colTotal(default, default):Int;
	
	public function isWalkable(x:Int, y:Int):Bool
	{
		return true;
	}
	
	public function drawMap():Void
	{
		var g = graphics;
		g.beginFill(0x0066CC);
		g.drawRect(0, 0, colTotal * 30, rowTotal * 30);
		g.endFill();
	}
}