
package edu.unl.astro.starField {
	
	public class StarParamsObject {
		
		private var _x:Number = 0;
		public var _y:Number = 0;
		public var _magnitude:Number = 0;
		
		public function StarParamsObject(initX:Number = 0, initY:Number = 0, initMagnitude:Number = 0) {
			_x = initX;
			_y = initY;
			_magnitude = initMagnitude;
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function set x(arg:Number):void {
			//
		}
			
		public function set y(arg:Number):void {
			//
		}
		
		public function set magnitude(arg:Number):void {
			//
		}
	
		public function get y():Number {
			return _y;
		}
		
		public function get magnitude():Number {
			return _magnitude;
		}
		
	}
	
}
