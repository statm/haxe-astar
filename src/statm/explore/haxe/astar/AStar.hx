package statm.explore.haxe.astar;

import flash.utils.TypedDictionary;
import flash.Vector;
import flash.Vector;
import flash.Vector;
import flash.Vector;
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
	
	public var _nodeArray:Array<Array<Node>>;
	
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
	
	public var _openList:Array<Node>;
	public var _closedList:Array<Node>;
	
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
		
		return searchPath();
	}
	
	inline private function getPath():Vector<IntPoint>
	{
		var path:Vector<IntPoint> = new Vector<IntPoint>();
		
		var node:Node = _destNode;
		path[0] = node.toIntPoint();
		
		var completed:Bool = false;
		while (!completed)
		{
			node = node.parent;
			path.unshift(node.toIntPoint());
			
			if (node == _startNode)
			{
				completed = true;
			}
		}
		
		return path;
	}
	
	// 寻路迭代
	public var completed:Bool = false;
	
	private function sortFunc(x:Node, y:Node):Int
	{
		return Std.int(x.f - y.f);
	}
	
	private function searchPath():Vector<IntPoint>
	{
		var minX:Int, maxX:Int, minY:Int, maxY:Int;
		var g:Float, f:Float, cost:Float;
		
		var nextNode:Node = null;
		var currentNode:Node = _startNode;
		
		// 开格子
		completed = false;
		while (!completed)
		{
			minX = currentNode.x - 1 < 0 ? 0 : currentNode.x - 1;
			maxX = currentNode.x + 1 >= _width ? _width - 1 : currentNode.x + 1;
			minY = currentNode.y - 1 < 0 ? 0 : currentNode.y - 1;
			maxY = currentNode.y + 1 >= _height ? _height - 1 : currentNode.y + 1;
			
			for (y in minY...maxY + 1)
			{
				for (x in minX...maxX + 1)
				{
					nextNode = _nodeArray[x][y];
					
					if (nextNode == currentNode
						|| !nextNode.walkable)
					{
						continue;
					}
					
					cost = ADJ_COST;
					if (!(currentNode.x == nextNode.x || currentNode.y == nextNode.y))
					{
						cost = DIAG_COST;
					}
					
					g = currentNode.g + cost;
					f = g + _heuristic.getCost(nextNode, _destNode);
					
					if (Lambda.indexOf(_openList, nextNode) != -1
						|| Lambda.indexOf(_closedList, nextNode) != -1)
					{
						if (nextNode.f > f)
						{
							nextNode.f = f;
							nextNode.g = g;
							nextNode.parent = currentNode;
						}
					}
					else
					{
						nextNode.f = f;
						nextNode.g = g;
						nextNode.parent = currentNode;
						
						_openList.push(nextNode);
					}
				}
			}
			
			_closedList.push(currentNode);
			
			if (_openList.length == 0)
			{
				return null;
			}
			
			_openList.sort(sortFunc);
			currentNode = _openList.shift();
			
			if (currentNode == _destNode)
			{
				completed = true;
			}
		}
		
		return getPath();
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
