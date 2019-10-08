
package {
	
	import fl.motion.easing.Exponential;

	public class PhiInterval {
		public var phi:Number;
		public var timeStart:Number;
		public var timeEnd:Number = Number.POSITIVE_INFINITY;
		protected var _omega:Number;
		
		public static const RampTime:Number = 250;
		
		public function PhiInterval(t:Number, p:Number, w:Number) {
			timeStart = t;
			phi = p;
			_omega = w;
		}
		
		public function getValue(t:Number):Number {
			if (t<timeStart) return 0;
			else if (t>timeEnd) return 0;
			else if (t<(timeStart+RampTime)) {
				return Math.sin(t*_omega + phi)*Exponential.easeInOut(t-timeStart, 0, 1, RampTime);
			}
			else if (t>(timeEnd-RampTime)) {
				return Math.sin(t*_omega + phi)*Exponential.easeInOut(t-(timeEnd-RampTime), 1, -1, RampTime);
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
			return arr;
		}
		
		public function getPeaks(pksStart:Number, pksEnd:Number):Array {
			var arr:Array = [];
			
			var C:Number = ((Math.PI/2) - phi)/_omega;
			var P:Number = 2*Math.PI/_omega;
			
			var nStart:int = Math.ceil((pksStart - C)/P);
			var nEnd:int = Math.floor((pksEnd - C)/P);
						
			var time:Number;
			var i:int = 0;
			
			var p:Number = 2*Math.PI/_omega;
			if (timeEnd>=pksStart && timeStart<=pksEnd) {
				for (var n:int = nStart; n<=nEnd; n++) {
					time =  C + n*P;
					if (timeStart<=time && time<=timeEnd) arr[i++] = new Position(time, Number.NaN, Number.NaN, getValue(time));
				}				
			}
			return arr;			
		}
		
	}
}
