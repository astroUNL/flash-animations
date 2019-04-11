
package {
	
	import flash.display.Sprite;
	
	public class PhaseDisc extends Sprite {
		
		protected var _phaseAngle:Number = 0;
		
		public var radius:Number = 100;		
		public var lightColor:uint = 0xe0e0e0;
		public var darkColor:uint = 0x404040;
		public var lineThickness:Number = 1;
		public var lineColor:uint = 0x202020;
		public var lineAlpha:Number = 0;
		
		protected var _darkArea:Sprite;
		protected var _lightArea:Sprite;
		
		public function PhaseDisc(params:Object=null) {
			
			_darkArea = new Sprite();
			addChild(_darkArea);
			
			_lightArea = new Sprite();
			addChild(_lightArea);
			
			if (params!=null) {
				if (params.radius is Number) radius = params.radius;
				if (params.lightColor is Number) lightColor = params.lightColor;
				if (params.darkColor is Number) darkColor = params.darkColor;
				if (params.lineThickness is Number) lineThickness = params.lineThickness;
				if (params.lineColor is Number) lineColor = params.lineColor;
				if (params.lineAlpha is Number) lineAlpha = params.lineAlpha;
				
				if (params.phaseAngle is Number) phaseAngle = params.phaseAngle;
				else if (params.positions is Object) setPositions(params.positions);
				else update();
			}
			else update();
		}
		
		public function get phaseAngle():Number {
			return _phaseAngle;
		}
		
		public function set phaseAngle(arg:Number):void {
			_phaseAngle = (arg%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			update();
		}
		
		public function getPhaseAngleDeg():Number {
			return _phaseAngle*180/Math.PI;
		}
		
		public function setPhaseAngleDeg(arg:Number):void {
			phaseAngle = arg*Math.PI/180;
		}
		
		public function setPositions(positions:Object):Number {
			// the positions object should have x0, y0, x1, y1, x2, and y2 properties; the phase angle will
			// be calculated assuming that these are the coordinates for the illuminator, observer, and
			// observed body respectively; that is, the disc will be drawn for an observer at body 1 looking
			// at body 2, being illuminated by body 0
			var x1:Number = positions.x1 - positions.x0;
			var y1:Number = positions.y1 - positions.y0;
			var x2:Number = positions.x2 - positions.x0;
			var y2:Number = positions.y2 - positions.y0;
			var r1:Number = Math.sqrt(x1*x1 + y1*y1);
			var r2:Number = Math.sqrt(x2*x2 + y2*y2);
			var angle1:Number = Math.atan2(y1, x1);
			var angle2:Number = Math.atan2(y2, x2);
			var theta:Number = (2*Math.PI)*((((angle2 - angle1)/(2*Math.PI))%1 + 1)%1);
			var cosTheta:Number = Math.cos(theta);
			var d:Number = Math.sqrt(r1*r1 + r2*r2 - 2*r1*r2*cosTheta);
			var cosBeta:Number = (r2 - r1*cosTheta)/d;
			if (cosBeta>1) cosBeta = 1;
			else if (cosBeta<-1) cosBeta = -1;
			var beta:Number = Math.acos(cosBeta);
			phaseAngle = (theta<Math.PI) ? beta : 2*Math.PI - beta;
			return phaseAngle;
		}
		
		public function update(...ignored):void {
			
			var f:Number = (_phaseAngle<Math.PI) ? -1 : 1;
			
			var n:int = 4;
			var s:Number = radius*Math.cos(_phaseAngle);
			var step:Number = Math.PI/n;
			var halfStep:Number = step/2;
			var kr:Number = radius/Math.cos(halfStep);
			var ks:Number = s/Math.cos(halfStep);
				
			var i:int;
			var angle:Number, cAngle:Number;
			var ax:Number, ay:Number, cx:Number, cy:Number;
			
			_darkArea.graphics.clear();
			_darkArea.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			_darkArea.graphics.moveTo(0, -radius);
			_darkArea.graphics.beginFill(darkColor);
			for (i=1; i<=n; i++) {
				angle = i*step;
				ax = radius*Math.sin(angle);
				ay = -radius*Math.cos(angle);
				cAngle = angle - halfStep;
				cx = kr*Math.sin(cAngle);
				cy = -kr*Math.cos(cAngle);
				_darkArea.graphics.curveTo(f*cx, cy, f*ax, ay);
			}
			for (i=(n-1); i>=0; i--) {
				angle = i*step;
				ax = s*Math.sin(angle);
				ay = -radius*Math.cos(angle);
				cAngle = angle + halfStep;
				cx = ks*Math.sin(cAngle);
				cy = -kr*Math.cos(cAngle);
				_darkArea.graphics.curveTo(f*cx, cy, f*ax, ay);
			}
			_darkArea.graphics.endFill();
			
			_lightArea.graphics.clear();
			_lightArea.graphics.lineStyle(lineThickness, lineColor, lineAlpha);			
			_lightArea.graphics.moveTo(0, -radius);
			_lightArea.graphics.beginFill(lightColor);
			for (i=1; i<=n; i++) {
				angle = i*step;
				ax = -radius*Math.sin(angle);
				ay = -radius*Math.cos(angle);
				cAngle = angle - halfStep;
				cx = -kr*Math.sin(cAngle);
				cy = -kr*Math.cos(cAngle);
				_lightArea.graphics.curveTo(f*cx, cy, f*ax, ay);
			}
			for (i=(n-1); i>=0; i--) {
				angle = i*step;
				ax = s*Math.sin(angle);
				ay = -radius*Math.cos(angle);
				cAngle = angle + halfStep;
				cx = ks*Math.sin(cAngle);
				cy = -kr*Math.cos(cAngle);
				_lightArea.graphics.curveTo(f*cx, cy, f*ax, ay);
			}
			_lightArea.graphics.endFill();
			
		}	
	}	
}


