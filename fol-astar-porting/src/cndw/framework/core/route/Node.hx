package cndw.framework.core.route;
import cndw.framework.common.util.Position;
import flash.Vector;

/**
 * ...
 * @author statm
 */

interface Node 
{

	function getPosition():Position;
	
	function getValidNeighborList(prober:Prober):Vector<Node>;
	
	function getCostTo(to:Node):Int;
	
	function toString():String;
	
}