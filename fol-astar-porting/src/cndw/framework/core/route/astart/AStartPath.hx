package cndw.framework.core.route.astart;
import cndw.framework.core.route.astart.AStartNode;
import cndw.framework.core.route.PathNode;
import cndw.framework.core.route.SimplePath;

/**
 * ...
 * @author statm
 */

class AStartPath extends SimplePath 
{
	public function new(goal:AStartNode = null) 
	{
		super();
		if (goal != null && goal.getParent() != null) 
		{
			var pathNode:PathNode = new PathNode(goal.getParent(), goal);
			pathNodeList.push(pathNode);
			var node:AStartNode = goal.getParent();
			while (node.getParent() != null) 
			{
				pathNode = new PathNode(node.getParent(), node);
				pathNodeList.unshift(pathNode);
				node = node.getParent();
			}
		}
	}
}