package cndw.framework.core.route;

/**
 * ...
 * @author statm
 */

class PathNode 
{
	
	private var to:Node;
	private var from:Node;

	public function new(from:Node, to:Node) 
	{
		this.from = from;
		this.to = to;
	}
	
	public function getTo():Node
	{
		return to;
	}
	
	public function getFrom():Node
	{
		return from;
	}
	
	public function getDistance():Float
	{
		return from.getPosition().distanceTo(to.getPosition());
	}
	
	public function toString():String
	{
		return "PathNode(from:" + getFrom() + ",to:" + getTo() + ")";
	}
}