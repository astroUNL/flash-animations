
package edu.unl.astro.starField {
	
	public interface IPixelMask {
		function get top():int;
		function get left():int;
		function get width():uint;
		function get height():uint;
		function get data():Array;
	}	
	
}
