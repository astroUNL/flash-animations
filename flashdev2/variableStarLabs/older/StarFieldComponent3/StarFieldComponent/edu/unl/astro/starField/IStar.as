
package edu.unl.astro.starField {
	
	public interface IStar {
		// - in addition to these functions every instance of an IStar is expected to dispatch an
		//   event with type StarField.STAR_CHANGED when any property has changed such that a
		//   new call to getParamsObject might return different values (e.g. when the position has changed)
		// - to easiest way to get the event listener functions is to have your class extend EventDispatcher
		
		//function getParamsObject(epoch:Number):StarParamsObject;
		
		
		/*
		function set epoch(arg:Number):void;
		function get x():Number;
		function get y():Number;
		function get magnitude():Number;
		*/
		
		function get x():Number;
		function get y():Number;
		function get magnitude():Number;
		function set epoch(arg:Number):void;
		function get epoch():Number;

		
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
	}
	
}
