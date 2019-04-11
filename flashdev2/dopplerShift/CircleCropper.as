
package {
	
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class CircleCropper {
		
		protected var _graphics:Graphics;
		protected var _range:Rectangle;
		
		public function CircleCropper() {
			//		
		}	
		
		public function get graphics():Graphics {
			return _graphics;
		}
		
		public function set graphics(g:Graphics):void {
			_graphics = g;
		}
		
		public function get range():Rectangle {
			return _range;
		}
		
		public function set range(rect:Rectangle):void {
			_range = rect;
		}
		
		public function drawCircle(x:Number, y:Number, r:Number):void {
			if (_graphics==null) return;
			if (_range==null) {
				drawArc(x, y, r);
			}
			else {
				var theta:Number;
				var arcStart:Number;
				var lastArcEnd:Number;
				
				theta = Math.acos((_range.right-x)/r);
				if (!isNaN(theta)) {
					// the excluded right side arc goes from -theta to theta
					arcStart = (theta%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
					lastArcEnd = 2*Math.PI - theta;
				}
				else {
					arcStart = 0;
					lastArcEnd = 2*Math.PI;
				}
				
				theta = Math.asin((y-_range.top)/r);
				if (!isNaN(theta)) {
					// the excluded top side arc goes from theta to PI-theta
					theta = (theta%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
					if (theta>arcStart) drawArc(x, y, r, arcStart, theta);
					arcStart = ((Math.PI-theta)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
				}
				
				theta = Math.acos((_range.left-x)/r);
				if (!isNaN(theta)) {
					// the excluded left side arc goes from theta to -theta
					theta = ((theta)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
					if (theta>arcStart) drawArc(x, y, r, arcStart, theta);
					arcStart = ((-theta)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
				}
				
				theta = Math.asin((y-_range.bottom)/r);
				if (!isNaN(theta)) {
					// the excluded bottom side arc goes from PI-theta to theta
					theta = ((Math.PI-theta)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
					if (theta>arcStart) drawArc(x, y, r, arcStart, theta);
					arcStart = ((Math.PI-theta)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
				}
				
				if (lastArcEnd>arcStart) drawArc(x, y, r, arcStart, lastArcEnd);				
			}
		}
		
		protected const maxArcStep:Number = 0.5;
		
		protected function drawArc(x:Number, y:Number, radius:Number, startAngle:Number=0, endAngle:Number=0):void {
			startAngle = (startAngle%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			endAngle = (endAngle%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			var rnge:Number = endAngle-startAngle;
			if (rnge<=0) rnge = (2*Math.PI)+rnge;
			var n:int = Math.ceil(rnge/maxArcStep);
			var step:Number = rnge/n;
			var half:Number = step/2;
			var cRadius:Number = radius/Math.cos(half);
			var aAngle:Number = startAngle;
			var cAngle:Number = startAngle - half;
			_graphics.moveTo(x + radius*Math.cos(startAngle), y - radius*Math.sin(startAngle));
			for (var i:int = 0; i<n; i++) {
				aAngle += step;
				cAngle += step;
				_graphics.curveTo(x + cRadius*Math.cos(cAngle), y - cRadius*Math.sin(cAngle), x + radius*Math.cos(aAngle), y - radius*Math.sin(aAngle));
			}
		}
		
	}	
}

