package statm.explore.haxe.astar;

import flash.utils.TypedDictionary;
import flash.Vector;
import statm.explore.haxe.astar.heuristics.IHeuristic;
import statm.explore.haxe.astar.heuristics.Manhattan;

/**
 * A* 寻路。
 * 
 * @author statm
 */

class AStar 
{
	private var _map:IAStarClient;
	private var _width:UInt;
	private var _height:UInt;
	
	private var _nodeArray:Array<Array<Node>>;
	
	private function new(map:IAStarClient)
	{
		this._map = map;
		updateMap();
	}
	
	public function updateMap() 
	{
		_width = _map.colTotal;
		_height = _map.rowTotal;
		_nodeArray = new Array<Array<Node>>();
		
		for (j in 0..._width)
		{
			var line = _nodeArray[j] = new Array<Node>();
			for (i in 0..._height)
			{
				var node = line[i] = new Node();
				node.x = j;
				node.y = i;
				node.walkable = _map.isWalkable(j, i);
			}
		}
	}
	
	// 寻路实现
	private var _startNode:Node;
	private var _destNode:Node;
	
	private var _openList:List<Node>;
	private var _endList:List<Node>;
	
	private var _heuristic:Manhattan;
	
	public function findPath(start:IntPoint, dest:IntPoint):Vector<IntPoint>
	{
		if (!_map.isWalkable(start.x, start.y)
			|| !_map.isWalkable(dest.x, dest.y)
			|| start.equals(dest))
		{
			return null;
		}
		
		_openList = new List<Node>();
		_endList = new List<Node>();
		
		_startNode = _nodeArray[start.x][start.y];
		_destNode = _nodeArray[dest.x][dest.y];
		
		_startNode.g = 0;
		_startNode.f = _heuristic.getCost(_startNode, _destNode);
		
		_openList.add(_startNode);
		
		_heuristic = new Manhattan();
		
		return searchPath();
	}
	
	private function searchPath():Vector<IntPoint>
	{
		// TODO
		return null;
	}
	
	
	// 实例字典
	private static var _instances:TypedDictionary<IAStarClient, AStar> = new TypedDictionary<IAStarClient, AStar>();
	
	public static function getAStarInstance(map:IAStarClient):AStar
	{
		var result:AStar = _instances.get(map);
		
		if (result == null)
		{
			result = new AStar(map);
			_instances.set(map, result);
		}
		
		return result;
	}
}
