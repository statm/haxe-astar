package statm.explore.haxe.astar;

import flash.utils.TypedDictionary;
import flash.Vector;
import flash.Vector;
import flash.Vector;
import statm.explore.haxe.astar.heuristics.Diagonal;
import statm.explore.haxe.astar.heuristics.IHeuristic;
import statm.explore.haxe.astar.heuristics.Manhattan;

/**
 * A* 寻路。
 * 
 * @author statm
 */

class AStar 
{
	// 开销
	public inline static var ADJ_COST:Int = 10;
	public inline static var DIAG_COST:Int = 14;
	
	private var _map:IAStarClient;
	private var _width:Int;
	private var _height:Int;
	
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
	
	private var _openList:Array<Node>;
	private var _closedList:Array<Node>;
	
	private var _heuristic:IHeuristic;
	
	public function findPath(start:IntPoint, dest:IntPoint):Vector<IntPoint>
	{
		if (!_map.isWalkable(start.x, start.y)
			|| !_map.isWalkable(dest.x, dest.y)
			|| start.equals(dest))
		{
			return null;
		}
		
		_heuristic = new Manhattan();
		
		_openList = new Array<Node>();
		_closedList = new Array<Node>();
		
		_startNode = _nodeArray[start.x][start.y];
		_destNode = _nodeArray[dest.x][dest.y];
		
		_startNode.g = 0;
		_startNode.f = _heuristic.getCost(_startNode, _destNode);
		
		_openList.push(_startNode);
		
		trace("Start Path Searching: " + _startNode + "-->" + _destNode);
		
		return searchPath();
	}
	
	private function searchPath():Vector<IntPoint>
	{
		var nextNode:Node = null;
		var node:Node = _startNode;
		
		var minX:Int, maxX:Int, minY:Int, maxY:Int;
		var g:Float, f:Float, cost:Float;
		
		var completed:Bool = false;
		
		var sortFunc = function(x:Node, y:Node):Int
		{
			return Std.int(x.f - y.f);
		};
		
		while (!completed)
		{
			minX = node.x - 1 < 0 ? 0 : node.x - 1;
			maxX = node.x + 1 >= _width ? _width - 1 : node.x + 1;
			minY = node.y - 1 < 0 ? 0 : node.y - 1;
			maxY = node.y + 1 >= _height ? _height - 1 : node.y + 1;
			
			for (y in minY...maxY + 1)
			{
				for (x in minX...maxX + 1)
				{
					nextNode = _nodeArray[x][y];
					
					if (nextNode == node
						|| !nextNode.walkable
						|| !_nodeArray[y][node.x].walkable
						|| !_nodeArray[node.y][x].walkable)
					{
						continue;
					}
					
					cost = ADJ_COST;
					if (!(node.x == nextNode.x || node.y == nextNode.y))
					{
						cost = DIAG_COST;
					}
					
					g = node.g + cost;
					f = g + _heuristic.getCost(nextNode, _destNode);
					
					if (Lambda.indexOf(_openList, nextNode) != -1
						|| Lambda.indexOf(_closedList, nextNode) != -1)
					{
						if (nextNode.f > f)
						{
							nextNode.f = f;
							nextNode.g = g;
							nextNode.parent = node;
						}
					}
					else
					{
						nextNode.f = f;
						nextNode.g = g;
						nextNode.parent = node;
						
						_openList.push(nextNode);
					}
					
					_closedList.push(nextNode);
				}
			}
			
			if (_openList.length == 0)
			{
				return null;
			}
			
			_openList.sort(sortFunc);
			node = _openList.shift();
			
			if (node == _destNode)
			{
				completed = true;
			}
		}
		
		return getPath();
	}
	
	private function getPath():Vector<IntPoint>
	{
		var result:Vector<IntPoint> = new Vector<IntPoint>();
		
		var node:Node = _destNode;
		result[0] = node.extractPoint();
		
		var completed:Bool = false;
		while (!completed)
		{
			node = node.parent;
			result.unshift(node.extractPoint());
			
			if (node == _startNode)
			{
				completed = true;
			}
		}
		
		trace("Path: " + result.join("->"));
		
		return result;
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
