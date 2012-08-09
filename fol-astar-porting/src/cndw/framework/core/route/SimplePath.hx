package cndw.framework.core.route;
import cndw.framework.core.route.Path;
import flash.Vector;

/**
 * ...
 * @author statm
 */

class SimplePath implements Path
{
	public var pathNodeList:Vector<PathNode>;
	
	public function new()
	{
		pathNodeList = new Vector<PathNode>();
	}
	
	public inline function getPathNodeList():Vector<PathNode>
	{
		return pathNodeList;
	}
	
	public inline function getNodeNum():Int 
	{
		return pathNodeList.length;
	}
	
	public function append(path:Path):Void 
	{
		if (path.isEmpth())
		{
			return;
		}
		if (!isEmpth())
		{
			appendPathNode(new PathNode(getLastPathNode().getTo(), path.getPathNodeList()[0].getFrom()));
		}
		for (node in path.getPathNodeList())
		{
			appendPathNode(node);
		}
	}
	
	public inline function isEmpth():Bool
	{
		return pathNodeList.length == 0;
	}

	public inline function appendPathNode(pathNode:PathNode):Void
	{
		pathNodeList.push(pathNode);
	}

	private inline function getLastPathNode():PathNode
	{
		return pathNodeList[pathNodeList.length - 1];
	}
}