package statm.explore.haxeAStar.heuristics;
import statm.explore.haxeAStar.Node;

/**
 * 估值算法接口。
 * 
 * @author statm
 */

interface IHeuristic 
{
	function getCost(node1:Node, node2:Node):Float;
}