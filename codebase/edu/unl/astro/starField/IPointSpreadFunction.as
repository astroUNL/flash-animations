
package edu.unl.astro.starField {
	
	public interface IPSF {
		// - in addition to these functions every instance of an IPSF is expected to dispatch an
		//   event with type StarField.PSF_CHANGED when any property (except epoch) that might affect
		//   the data, width, height, or position properties has changed
		// - the easiest way to get the event listener functions is to have your class extend EventDispatcher
		// - data is a two-dimensional array (with dimensions of width by height) that contains the
		//   psf template; this array should consist of Numbers with values between 0 and 1; the StarField
		//   component will scale this template for each star according to its magnitude
		// - width and height are the dimensions of the data array
		// - x and y refer the center of the template with respect to its upper left pixel; the controls the 
		//   placement of the template for a given star's coordinates
		// - epoch is the time (in days) at which the value of time dependent properties are measured; the
		//   epoch is set by the StarField component immediately before reading the data, width, height, x 
		//   and y properties
		function get data():Array;
		function get width():uint;
		function get height():uint;
		function get x():int;
		function get y():int;
		function get epoch():Number;
		function set epoch(arg:Number):void;
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
	
}
