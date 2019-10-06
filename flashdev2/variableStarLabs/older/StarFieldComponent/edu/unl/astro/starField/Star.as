
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class Star extends EventDispatcher implements IStar {
		
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _magnitude:Number = 0;
		protected var _callUpdate:Boolean = true;
		protected var _epoch:Number = 0;
		
		public function Star(...argsList):void {
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		protected function update():void {
			dispatchEvent(new Event(StarField.STAR_CHANGED));
		}
		
		public function loadSettings(...argsList):void {
			loadSettingsFromObjectsList(argsList);
		}
		
		protected function loadSettingsFromObjectsList(objectsList):void {
			_callUpdate = false;
			var settingsObj:Object;
			for (var i:int = 0; i<objectsList.length; i++) {
				if (objectsList[i] is Object) {
					settingsObj = objectsList[i];
					if (settingsObj.x is Number) x = settingsObj.x;
					if (settingsObj.y is Number) y = settingsObj.y;
					if (settingsObj.magnitude is Number) magnitude = settingsObj.magnitude;
				}
			}
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
