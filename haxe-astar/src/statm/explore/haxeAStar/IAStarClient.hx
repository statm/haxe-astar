package statm.explore.haxeAStar;

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