
package edu.unl.astro.starField {
	
	import flash.events.IEventDispatcher;
	
	public interface IStar extends IEventDispatcher {
		// - in addition to these functions every instance of an IStar is expected to dispatch an
		//   event with type StarField.STAR_CHANGED when any property (except epoch) that might affect
		//   the magnitude or position has changed		
		// - to easiest way to get the event listener functions is to have your class extend EventDispatcher
		// - x and y are the field coordinates in pixels (note that at present the StarField component
		//   only considers the integer parts of these coordinates)
		// - magnitude is the magnitude of the star, at time epoch
		// - epoch is the time (in days) at which the value of time dependent properties are measured;
		//   the StarField component will set the epoch value immediately before reading the x, y,
		//   and magnitude properties
		function get x():Number;
		function get y():Number;
		function get magnitude():Number;
		function set epoch(arg:Number):void;
	}
	
}
