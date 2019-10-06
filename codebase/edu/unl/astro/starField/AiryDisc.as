
package edu.unl.astro.starField {
		
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AiryDisc extends EventDispatcher implements IPSF {
		
		protected var _radius:uint;
		protected var _center:int;
		protected var _size:uint;
		protected var _data:Array;
		
		public function AiryDisc($radius:uint = 6):void {
			radius = $radius;
		}
		
		public function set epoch(arg:Number):void {
			// do nothing
		}		
		
		public function get data():Array {
			return _data;			
		}
		
		public function get width():uint {
			return _size;
		}
		
		public function get height():uint {
			return _size;
		}
		
		public function get x():int {
			return _center;			
		}
		
		public function get y():int {
			return _center;			
		}
		
		public function get radius():uint {
			return _radius;			
		}
		
		public function set radius(arg:uint):void {
			if (arg<2) return;
			_radius = arg;
			_center = _radius - 1;
			_size = 2*_radius - 1;
			reset();
		}
		
		public function reset():void {
			// - this function generates an airy disc out to the first trough;
			//   the formula used is 4*(J1(r)/r)^2 out to r = 3.831705970256774
			_data = [];
			var i:int;
			var j:int;
			var r2:Number;
			var J1_r:Number;
			var x:Number;
			var y:Number;
			var a:Number;
			var scale:Number = 3.831705970256774/_radius;
			for (i=0; i<_size; i++) _data[i] = [];
			// the way this works is to determine the values in a 45° slice and then mirror them into the array
			for (i=0; i<_radius; i++) {
				x = scale*i;
				for (j=0; j<=i; j++) {
					y = scale*j;
					r2 = x*x + y*y;
					if (r2>=14.681970642501405) a = 0;
					else {
						J1_r = getJ1(Math.sqrt(r2));
						a = 4*J1_r*J1_r/r2;
					}
					_data[_center+i][_center-j] = a;
					_data[_center+j][_center-i] = a;
					_data[_center-j][_center-i] = a;
					_data[_center-i][_center-j] = a;
					_data[_center-i][_center+j] = a;
					_data[_center-j][_center+i] = a;
					_data[_center+j][_center+i] = a;
					_data[_center+i][_center+j] = a;
				}
			}
			_data[_center][_center] = 1;
			
			dispatchEvent(new Event(StarField.PSF_CHANGED));
		}
		
		protected function getJ1(x:Number):Number {
			// calculates the Bessel function J1 according to the method in Numerical Recipes in C
			var y:Number;
			var ans1:Number;
			var ans2:Number;
			var ans:Number;
			var ax:Number = Math.abs(x);
			if (ax<8.0) {
				y = x*x;
				ans1 = x*(72362614232.0 + y*(-7895059235.0 + y*(242396853.1
					+ y*(-2972611.439 + y*(15704.48260 + y*(-30.16036606))))));
				ans2 = 144725228442.0 + y*(2300535178.0 + y*(18583304.74
					+ y*(99447.43394 + y*(376.9991397 + y*1.0))));
				ans = ans1/ans2;
			}
			else {
				var z:Number = 8.0/ax;
				y = z*z;
				var xx:Number = ax - 2.356194491;
				ans1 = 1.0 + y*(0.183105e-2 + y*(-0.3516396496e-4
					+ y*(0.2457520174e-5 + y*(-0.240337019e-6))));
				ans2 = 0.04687499995 + y*(-0.2002690873e-3
					+ y*(0.8449199096e-5 + y*(-0.88228987e-6
					+ y*0.105787412e-6)));
				ans = Math.sqrt(0.636619772/ax)*(Math.cos(xx)*ans1 - z*Math.sin(xx)*ans2);
				if (x<0.0) ans = -ans;
			}
			return ans;
		}

	}
	
}
