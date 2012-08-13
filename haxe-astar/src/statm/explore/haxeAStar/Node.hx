package statm.explore.haxeAStar;

/**
 * A* 节点。
 * 
 * @author statm
 */

class Node extends IntPoint
{
	public var parent:Node;
	
	public var walkable:Bool;
	
	public var f:Float;
	public var g:Float;
	
	override public function toString():String
	{
		var result:String;
		result = "[Node(" + this.x + "," + this.y + ")";
		if (parent != null)
		{
			result += ", parent=(" + parent.x + "," + parent.y + ")";
		}
		result += (walkable ? ", W" : ", X");
		result += ", f=" + f;
		result += "]";
		
		return result;
	}
	
	public function toIntPoint():IntPoint
	{
		var pt:IntPoint = new IntPoint();
		pt.x = this.x; 
		pt.y = this.y;
		return pt;
	}
}
