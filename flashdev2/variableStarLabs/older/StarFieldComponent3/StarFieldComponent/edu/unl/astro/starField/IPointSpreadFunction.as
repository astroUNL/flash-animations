
package edu.unl.astro.starField {
	public interface IPointSpreadFunction {
		function set epoch(arg:Number):void;
		function get data():Array;
		function get width():uint;
		function get height():uint;
		function get x():int;
		function get y():int;
	//	function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
	//	function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
}
