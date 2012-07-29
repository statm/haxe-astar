package statm.explore.haxe.astar.heuristics;
import statm.explore.haxe.astar.Node;

/**
 * 估值算法接口。
 * 
 * @author statm
 */

interface IHeuristic 
{
	function getCost(node1:Node, node2:Node):Float;
}