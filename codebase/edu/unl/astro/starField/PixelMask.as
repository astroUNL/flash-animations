
package edu.unl.astro.starField {
	
	public class PixelMask implements IPixelMask {
		
		protected var _data:Array;
		protected var _radius:uint;
		
		public function PixelMask(r:uint = 6):void {
			radius = r;
		}		
		
		public function get radius():uint {
			return _radius;
		}
		
		public function set radius(arg:uint):void {
				
			_radius = arg;
			
			var n:int = 2*_radius + 1;
			
			var i:int;
			var j:int;
			var x:int;
			var y:int;
			
			var d2:int;
			
			var r2:Number = _radius*_radius;
			
			_data = [];
			
			for (i=0; i<n; i++) {
				x = -_radius + i;
				
				_data[i] = [];
				
				for (j=0; j<n; j++) {
					y = -_radius + j;
					
					d2 = x*x + y*y;
					
					if (d2>r2) {
						_data[i][j] = false;
					}
					else {
						_data[i][j] = true;
					}
				}
			}
			
			_width = n;
			_height = n;
		}	
		
		protected var _top:int = 0;
		protected var _left:int = 0;
		protected var _width:uint;
		protected var _height:uint;
		
		public function set top(arg:int):void {
			_top = arg;			
		}
		
		public function set left(arg:int):void {
			_left = arg;			
		}
		
		public function get top():int {
			return _top;			
		}
		
		public function get left():int {
			return _left;			
		}
		
		public function get width():uint {
			return _width;			
		}
		
		public function get height():uint {
			return _height;			
		}
		
		public function get data():Array {
			return _data;			
		}
		
	}
	
}
