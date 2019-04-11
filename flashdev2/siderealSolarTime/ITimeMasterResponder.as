
package {
	
	public interface ITimeMasterResponder {
		
		// called when an animation first starts
		function onTimeMasterAnimationStart():void;
		
		// this is called before onTimeMasterTimeChanged is called, so don't use the time values in this function
		function onTimeMasterAnimationStop():void;
		
		// this is called whenever the time value has changed during an animation (but not at the end)
		function onTimeMasterAnimationUpdate():void;
		
		// this is called when a time value has changed instantly, or when an animation of the time
		// value has stopped (whether it has reached its intended target value or not)
		function onTimeMasterTimeChanged():void;
		
		// this is called when the mode has changed
		// note that setting the mode causes the time to be reset and possibly an animation to be
		// cancelled -- this function get called before all the other responders (so don't use
		// the time values in this function)
		function onTimeMasterModeChanged():void;
		
	}	
}
