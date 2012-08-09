package cndw.framework.core.route.astart;
import cndw.framework.common.util.Position;
import cndw.framework.core.route.Direction;
import cndw.framework.core.route.RouteTimeoutError;
import de.polygonal.ds.HashMap;
import de.polygonal.ds.HashSet;
import de.polygonal.ds.Heap;
import flash.geom.Point;
import flash.Lib;
import flash.Vector;

/**
 * ...
 * @author statm
 */

class AStartRouter implements Router 
{
	private static inline var TIMEOUT_ENABLE:Bool = true;

	private static inline var TIMEOUT:Int = 800;

	public function route(prober:Prober, nodeGroup:NodeGroup, target:Target, smooth:Bool = true):Path 
	{
		var t1:Float = Lib.getTimer();
		var beginTime:Float = Lib.getTimer();
		var openList:Heap<AStartNode> = new Heap<AStartNode>();
		var openArray:Array<AStartNode> = [];
		
		if (target.checkArrived(prober.getPosition())) 
		{
			return new AStartPath();
		}
		
		var start:Node = nodeGroup.getNode(prober.getPosition());
		var goal:Node = nodeGroup.getNode(target.getPosition());
		var startNode:AStartNode = AStartNode.forGoal(start, goal);
		var goalNode:AStartNode = null;
		openList.add(startNode);
		openArray[startNode.getPosition().key] = startNode;
		
		var currNode:AStartNode = null;
		while (openList.size() > 0) 
		{
			checkTimeout(beginTime);
			currNode = openList.pop();
			
			// 判断是否到达终点
			if (target.checkArrived(currNode.getPosition())) 
			{
				goalNode = currNode;
				break;
			}
			// 迭代所有邻居
			for (neighbor in currNode.getValidNeighborList(prober)) 
			{
				if (openArray[neighbor.getPosition().key] == null)
				{
					var newNode:AStartNode = AStartNode.forFrom(neighbor, currNode);
					openArray[newNode.getPosition().key] = newNode;
					openList.add(newNode);
				} 
				else 
				{
					var openedNode:AStartNode = openArray[neighbor.getPosition().key];
					if (openedNode.getParent() != currNode && openedNode.cheaperFrom(currNode))
					{ // 成本更低
						// 设置父节点
						openedNode.setParent(currNode);
					}
				}
			}
		}

		Lib.trace("寻路:" + (Lib.getTimer() - t1));

		t1 = Lib.getTimer();

		// 平滑处理
		if (goalNode != null && smooth) 
		{
			this.smooth(prober, goalNode, openArray);
		}

		Lib.trace("平滑:" + (Lib.getTimer() - t1));

		// 生成路径返回
		return new AStartPath(goalNode);
	}

	private function compareFunction(a:AStartNode, b:AStartNode):Int
	{
		return b.getCost() - a.getCost();
	}

	private inline function smooth(prober:Prober, goal:AStartNode, openArray:Array<AStartNode>):Void {
		var curr:AStartNode = goal; // 当前位置
		var cursor:AStartNode = goal; // 光标位置
		while (true) 
		{
			if (cursor.getParent() != null) 
			{
				if (isStraight(prober, cursor.getParent(), curr, openArray)) 
				{
					cursor = cursor.getParent();
				} 
				else 
				{
					curr.setParent(cursor);
					curr = cursor;
				}
			} 
			else 
			{
				curr.setParent(cursor);
				break;
			}
		}
		curr = null;
		cursor = null;
	}

	private function isStraight(prober:Prober, from:Node, to:Node, openArray:Array<AStartNode>):Bool 
	{
		var p1x:Float = from.getPosition().getCol();
		var p1y:Float = from.getPosition().getRow() * -1;
		var p2x:Float = to.getPosition().getCol();
		var p2y:Float = to.getPosition().getRow() * -1;
		var xoffset:Float = p2x - p1x;
		var yoffset:Float = p2y - p1y;

		var hypotenuse:Float = from.getPosition().distanceTo(to.getPosition());
		var sin:Float = xoffset / hypotenuse;
		var cos:Float = yoffset / hypotenuse;

		var length:Int = Math.round(hypotenuse);

		var formX:Int = from.getPosition().getCol();
		var fromY:Int = from.getPosition().getRow();

		for (index in 1...length + 1)
		{
			var x:Int = Math.round(sin * index) + formX;
			var y:Int = -Math.round(cos * index) + fromY;
			var position:Position = Position.forRC(y, x);
			if (openArray[position.getKey()] == null)
			{
				return false;
			}
		}
		return true;
	}

	private function checkTimeout(beginTime:Float):Void 
	{
		if (!TIMEOUT_ENABLE)
			return;
		if (Lib.getTimer() - beginTime > TIMEOUT) 
		{
			throw new RouteTimeoutError();
		}
	}
}