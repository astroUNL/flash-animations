
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class ConstantStar extends EventDispatcher implements IStar {
		// - a constant star is one whose properties (x, y, and magnitude) do not change
		//   with time (the epoch); of course these properties can be changed after the 
		//   star has been added to the star field -- in that case the ConstantStar instance
		//   informs the StarField class that its settings have changed and so the StarField
		//   will automatically update (as long as it is not locked)
		
		public function ConstantStar(initX:Number = 0, initY:Number = 0, initMagnitude:Number = 0):void {
			_paramsObj = new StarParamsObject(initX, initY, initMagnitude);
		}
		
		private var _paramsObj:StarParamsObject;
		private var _epoch:Number = 0;
		
		public function getParamsObject(epoch:Number):StarParamsObject {
			return _paramsObj;
		}
		
		public function get x():Number {
			return _paramsObj.x;
		}
		
		public function set x(arg:Number):void {
			_paramsObj.x = arg;
			dispatchEvent(new Event(StarField.STAR_CHANGED));
		}
		
		public function get y():Number {
			return _paramsObj.y;
		}
		
		public function set y(arg:Number):void {
			_paramsObj.y = arg;
			dispatchEvent(new Event(StarField.STAR_CHANGED));
		}
		
		public function get magnitude():Number {
			return _paramsObj.magnitude;
		}
		
		public function set magnitude(arg:Number):void {
			_paramsObj.magnitude = arg;
			dispatchEvent(new Event(StarField.STAR_CHANGED));
		}
		
		public function get epoch():Number { 
			return _epoch;
		}
		
		public function set epoch(arg:Number):void {
			_epoch = arg;
		}
		
	}
	
}
