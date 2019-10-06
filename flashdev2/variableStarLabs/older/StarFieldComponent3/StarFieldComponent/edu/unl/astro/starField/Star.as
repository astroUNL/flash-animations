
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Star extends EventDispatcher implements IStar {
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _magnitude:Number = 0;
		protected var _callUpdate:Boolean = true;
		protected var _epoch:Number = 0;
		
		public static const STAR_CHANGED:String = "starChanged";
		
		public function Star(settingsObj:* = null):void {
			if (settingsObj is Object) loadSettings(settingsObj);			
		}
		
		protected function update():void {
			dispatchEvent(new Event(Star.STAR_CHANGED));
		}
		
		public function loadSettings(settingsObj:Object):void {
			_callUpdate = false;
			if (settingsObj.x is Number) x = settingsObj.x;
			if (settingsObj.y is Number) y = settingsObj.y;
			if (settingsObj.magnitude is Number) magnitude = settingsObj.magnitude;
			_callUpdate = true;
			update();			
		}
		
		public function get epoch():Number {
			return _epoch;
		}
		
		public function set epoch(arg:Number):void {
			_epoch = arg;			
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_x = arg;
			if (_callUpdate) update();			
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function set y(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_y = arg;
			if (_callUpdate) update();			
		}
		
		public function get magnitude():Number {
			return _magnitude;			
		}
		
		public function set magnitude(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_magnitude = arg;
			if (_callUpdate) update();			
		}
		
	}
	
}
