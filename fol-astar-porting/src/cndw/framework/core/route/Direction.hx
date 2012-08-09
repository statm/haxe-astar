package cndw.framework.core.route;
import cndw.framework.common.util.Position;
import flash.errors.ArgumentError;

/**
 * ...
 * @author statm
 */

class Direction 
{
	public static var LEFT:Direction = new Direction("LEFT", -1, 0,
		function(angel:Int):Bool {
			return (angel >= 157) || (angel <= -157);
		});
	public static var TOP:Direction = new Direction("TOP", 0, -1,
		function(angel:Int):Bool {
			return angel >= 67 && angel < 112;
		});
	public static var RIGHT:Direction = new Direction("RIGHT", 1, 0,
		function(angel:Int):Bool {
			return (angel < 0 && angel >= -22) || (angel >= 0 && angel < 22);
		});
	public static var BOTTOM:Direction = new Direction("BOTTOM", 0, 1,
		function(angel:Int):Bool {
			return angel < -67 && angel >= -112;
		});
	public static var TOP_LEFT:Direction = new Direction("TOP_LEFT", -1, -1,
		function(angel:Int):Bool {
			return angel >= 112 && angel < 157;
		});
	public static var TOP_RIGHT:Direction = new Direction("TOP_RIGHT", 1, -1,
		function(angel:Int):Bool {
			return angel >= 22 && angel < 67;
		});
	public static var BOTTOM_RIGHT:Direction = new Direction("BOTTOM_RIGHT", 1, 1,
		function(angel:Int):Bool {
			return angel >= -67 && angel < -22;
		});
	public static var BOTTOM_LEFT:Direction = new Direction("BOTTOM_LEFT", -1, 1,
		function(angel:Int):Bool {
			return angel >= -157 && angel < -112;
		});
	
	public var name:String;
	private var colOffset:Int;
	private var rowOffset:Int;
	private var judgeFunction:Int->Bool;
	public static var directionList:Array<Direction>= Lambda.array([LEFT, RIGHT, TOP, BOTTOM, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT]);

	public function new(name:String, colOffset:Int, rowOffset:Int, judgeFunction:Int->Bool) 
	{
		this.name = name;
		this.colOffset = colOffset;
		this.rowOffset = rowOffset;
		this.judgeFunction = judgeFunction;
	}
	
	public static function forName(name:String):Direction
	{
		for (dir in directionList)
		{
			if (dir.name == name)
			{
				return dir;
			}
		}
		
		throw new ArgumentError("无效name:" + name);
	}
	
	public static function forPosition(from:Position, to:Position):Direction
	{
		var angel:Int = getAngel(from, to);
		for (dir in directionList)
		{
			if (dir.judgeFunction(angel))
			{
				return dir;
			}
		}
		throw new ArgumentError("异常Position!");
	}
	
	public function getOffset(source:Position, offset:UInt):Position
	{
		return source.addRC(rowOffset * offset, colOffset * offset);
	}
	
	private static function getAngel(from:Position, to:Position):Int
	{
		return Math.round(Math.atan2(-(to.getRow() - from.getRow()), to.getCol() - from.getCol()) * 180 / Math.PI);
	}
}