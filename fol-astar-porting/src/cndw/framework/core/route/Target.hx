package cndw.framework.core.route;
import cndw.framework.common.util.Position;

/**
 * ...
 * @author statm
 */

interface Target 
{

	function getPosition():Position;
	
	function checkArrived(position:Position):Bool;
	
}