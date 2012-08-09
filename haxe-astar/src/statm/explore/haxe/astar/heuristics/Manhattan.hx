package statm.explore.haxe.astar.heuristics;
import statm.explore.haxe.astar.Node;

/**
 * Manhattan 估值算法。
 * 
 * @author statm
 */

class Manhattan implements IHeuristic
{
	public function new()
	{
	}
	
	public function getCost(node1:Node, node2:Node):Float
	{
		var dx:Int = node1.x - node2.x;
		var dy:Int = node1.y - node2.y;
		
		return (dx > 0 ? dx : -dx) + (dy > 0 ? dy : -dy);
	}
}