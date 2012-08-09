package cndw.framework.core.route;
import cndw.framework.common.util.Position;

/**
 * ...
 * @author statm
 */

interface NodeGroup 
{
	function hasNode(position:Position):Bool;

	function getNode(position:Position):Node;
	
}