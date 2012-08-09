package cndw.framework.core.route;

/**
 * ...
 * @author statm
 */

interface Router 
{

	function route(prober:Prober, nodeGroup:NodeGroup, target:Target, smooth:Bool = true):Path;
	
}