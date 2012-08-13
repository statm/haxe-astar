package statm.explore.haxeAStar;

/**
 * 整数坐标。
 * 
 * @author statm
 */

class IntPoint
{
	public var x:Int;
	public var y:Int;
	
	public function new()
	{
		x = y = 0;
	}
	
	public function equals(pt:IntPoint):Bool
	{
		return (x == pt.x && y == pt.y);
	}
	
	public function toString():String
	{
		return "(" + this.x + "," + this.y + ")";
	}
}