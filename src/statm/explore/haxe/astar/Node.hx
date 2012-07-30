package statm.explore.haxe.astar;

/**
 * A* 节点。
 * 
 * @author statm
 */

class Node extends IntPoint
{
	public var parent:Node;
	
	public var walkable:Bool;
	
	public var f:Float = 0.;
	public var g:Float = 0.;
	
	override public function toString():String
	{
		var result:String;
		result = "[Node(" + this.x + "," + this.y + ")";
		if (parent != null)
		{
			result += ", parent=(" + parent.x + "," + parent.y + ")";
		}
		//result += (walkable ? ", W" : ", X");
		result += ", f=" + f;
		result += "]";
		
		return result;
	}
	
	public function extractPoint():IntPoint
	{
		var pt:IntPoint = new IntPoint();
		pt.x = this.x; 
		pt.y = this.y;
		return pt;
	}
}
