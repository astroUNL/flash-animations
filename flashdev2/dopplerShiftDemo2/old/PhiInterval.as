
package {
	
	import fl.motion.easing.Exponential;

	public class PhiInterval {
		public var phi:Number;
		public var timeStart:Number;
		public var timeEnd:Number = Number.POSITIVE_INFINITY;
		protected var _omega:Number;
		
		public static const rampTime:Number = 1500;
		
		public function PhiInterval(t:Number, p:Number, w:Number) {
			timeStart = t;
			phi = p;
			_omega = w;
		}
		
		public function getValue(t:Number):Number {
			if (t<timeStart) return 0;
			else if (t>timeEnd) return 0;
			else if (t<(timeStart+rampTime)) {
				return Math.sin(t*_omega + phi)*Exponential.easeInOut(t-timeStart, 0, 1, rampTime);
			}
			else if (t>(timeEnd-rampTime)) {
				return Math.sin(t*_omega + phi)*Exponential.easeInOut(t-(timeEnd-rampTime), 1, -1, rampTime);
			}
			else {
				return Math.sin(t*_omega + phi);
			}
		}
		
		public function getValues(tStart:Number, tEnd:Number, numSteps:int):Array {
			var arr:Array = [];
			var t:Number;
			var tStep:Number = (tEnd - tStart)/numSteps;
			for (var i:int = 0; i<=numSteps; i++) {
				t = tStart + i*tStep;
				arr[i] = getValue(t);
			}
		}
	}
}
