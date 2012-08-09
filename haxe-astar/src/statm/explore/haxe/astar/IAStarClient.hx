package statm.explore.haxe.astar;

/**
 * A* 数据源。
 * 
 * @author statm
 */

interface IAStarClient 
{
	var rowTotal(default, never):Int;
	
	var colTotal(default, never):Int;
	
	function isWalkable(x:Int, y:Int):Bool;
}