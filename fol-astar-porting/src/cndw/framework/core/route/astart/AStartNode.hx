package cndw.framework.core.route.astart;
import cndw.framework.common.util.Position;
import cndw.framework.core.route.Node;
import de.polygonal.ds.Heapable;
import flash.Vector;

/**
 * ...
 * @author statm
 */

class AStartNode implements Node, implements Heapable<AStartNode>
{
	private var node:Node;
	private var parent:AStartNode;
	private var goal:Node;

	private var cost:Int;
	private var fromStartCost:Int = 0;
	private var toGoalCost:Int;

	public function new(node:Node) 
	{
		this.node = node;
	}
	
	public static inline function forGoal(node:Node, goal:Node):AStartNode 
	{
		var aStartNode:AStartNode = new AStartNode(node);
		aStartNode.setGoal(goal);
		aStartNode.setParent(null);
		return aStartNode;
	}

	public static inline function forFrom(node:Node, from:AStartNode):AStartNode 
	{
		var aStartNode:AStartNode = new AStartNode(node);
		aStartNode.setGoal(from.getGoal());
		aStartNode.setParent(from);
		return aStartNode;
	}

	public inline function getPosition():Position 
	{
		return node.getPosition();
	}

	public inline function getValidNeighborList(prober:Prober):Vector<Node> 
	{
		return node.getValidNeighborList(prober);
	}

	public inline function getCostTo(to:Node):Int 
	{
		return node.getCostTo(to);
	}

	public inline function toString():String 
	{
		return node.toString();
	}

	/**
	 * 获得寻路父节点
	 */
	public inline function getParent():AStartNode 
	{
		return parent;
	}

	/**
	 * 设置父节点
	 *
	 */
	public inline function setParent(parent:AStartNode):Void 
	{
		if (parent != null) 
		{
			this.fromStartCost = parent.getFromStartCost() + parent.getCostTo(this);
			this.parent = parent;
		}
		this.cost = this.fromStartCost + this.toGoalCost;
	}

	/**
	 * 获得总代价
	 */
	public inline function getCost():Int 
	{
		return cost;
	}

	/**
	 * 获得从开始节点代价
	 */
	public inline function getFromStartCost():Int 
	{
		return fromStartCost;
	}

	/**
	 * 获得从当前节点到终点节点代价
	 */
	public inline function getToGoalCost():Int 
	{
		return toGoalCost;
	}

	/**
	 * 获得终点节点
	 */
	public inline function getGoal():Node 
	{
		return goal;
	}

	/**
	 * 对比当前移动成本和从指定节点移动成本
	 *
	 * @param from 指定从此节点移动到当前节点
	 * @return 如果指定的节点成本比当前成本低则返回true, 否则返回false
	 *
	 */
	public inline function cheaperFrom(from:AStartNode):Bool 
	{
		return (from.getFromStartCost() + from.getCostTo(this)) < getFromStartCost();
	}

	/**
	 * 设置终点
	 *
	 * @param goal
	 *
	 */
	private inline function setGoal(goal:Node):Void 
	{
		this.toGoalCost = getCostTo(goal);
		this.goal = goal;
	}
	
	public var position:Int; // 不要修改
	
	public function compare(other:AStartNode):Int
	{
		return other.cost - cost;
	}
}