package cndw.framework.core.route;
import flash.errors.Error;

/**
 * ...
 * @author statm
 */

class RouteTimeoutError extends Error
{

	public function new() 
	{
		super("寻路超时!", 0);
	}
	
}