package cndw.framework.core.route;
import flash.Vector;

/**
 * ...
 * @author statm
 */

interface Path 
{

	function getPathNodeList():Vector<PathNode>;

	function getNodeNum():Int;

	function append(path:Path):Void;

	function isEmpth():Bool;
	
}