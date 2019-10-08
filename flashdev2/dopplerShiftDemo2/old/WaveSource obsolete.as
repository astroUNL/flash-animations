
package {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import flash.events.Event;
	
	public class WaveSource extends Sprite {
		
		// intensity at time = A*cos(time*2*PI/_freq)
		protected const _frequency:Number = 1;
		
		// wave speed
		protected const _waveSpeed:Number = 1;
		
		// 
		
		protected var _intensityHistory:Array = [];
		
		protected var _historyList:Array = [];
		protected var _timeLast:Number = Number.NaN;
		
		
		protected var _wavesSP:Sprite;
		protected var _motionSP:Sprite;
		
		public function WaveSource() {
			
			_wavesSP = new Sprite();
			_motionSP = new Sprite();
			
			
			
		}
		
		public function getObservation(obsPt:Point, time:Number):Number {
			// returns the intensity observed at the given point and time due to this source
			
			return 1;
			
		}
		
		public function getObservations(detailsList:Array):Array {
			// returns an array of intensities that would be observed for the positions and times given
			// in the details list (each entry of detailsList should have obsPt and time properties)
			
			return [0];
		}
		
		
		
		public function get frequency():Number {
			return _frequency;			
		}
		
		/*		
		public function set frequency(arg:Number):void {
			// sets the frequency of emission for the source
			if (!isNaN(arg) && isFinite(arg) && arg>0) _frequency = arg;
			clearHistory();
		}
		*/

		public function advanceToTime(time:Number):void {
			// advances the source to the given time
			
			
		}
		
		public function setTime(time:Number):void {
			// clears the history and syncs the source to the given time
			
			clearHistory();
			
		}
		
		public function clearHistory():void {
			_historyList = [];
			_wavesSP.graphics.clear();
			_motionSP.graphics.clear();
			dispatchEvent(new Event(WaveSource.HISTORY_CLEARED));
		}
		
		
		public static const HISTORY_CLEARED:String = "historyCleared";
		
		public static const FREESTYLE:String = "freestyle";
		public static const STATIONARY:String = "stationary";
		public static const UNIFORM_CIRCULAR:String = "uniformCircular";
		public static const LINEAR_OSCILLATOR:String = "linearOscillator";
		
		protected var _motionType:String = WaveSource.STATIONARY;
		
		public function get motionType():String {
			return _motionType;
		}
		
		public function set motionType(type:String):void {			
			if (type==WaveSource.FREESTYLE || type==WaveSource.STATIONARY || type==WaveSource.UNIFORM_CIRCULAR || type==WaveSource.LINEAR_OSCILLATOR) {
				_motionType = type;
				clearHistory();
			}

		}
		
		public static const CCW:String = "CCW";
		public static const CW:String = "CW";
		
		protected var _circleX:Number = 100;
		protected var _circleY:Number = 100;
		protected var _circleRadius:Number = 50;
		protected var _circleDirection:String = WaveSource.CCW;
		
		protected var _lineX:Number = 100;
		protected var _lineY:Number = 100;
		protected var _lineLength:Number = 100;
		protected var _lineRotation:Number = 0;
		
		protected var _velocity:Number = 0;
		protected const _maxVelocity:Number = 0.5;
		
		protected const _maxSeparation:Number = Math.sqrt(800*800 + 600*600);
		protected const _maxHistoryTime:Number = _maxSeparation/_waveSpeed;
		protected const _maxNumCrests:int = _maxSeparation/(_waveSpeed/_frequency);
		
		
		protected var _circlePhi:Number = 0;
		protected var _linePhi:Number = 0;
		
		public function setCircleParameters(cx:Number, cy:Number, radius:Number, dir:String, phi:Number):void {
			_circleX = cx;
			_circleY = cy;
			_circleRadius = radius;
			_circleDirection = dir;
			_circlePhi = phi;
		}
		
		
		public function setLineParameters(lx:Number, ly:Number, len:Number, rot:Number, phi:Number):void {
			_lineX = lx;
			_lineY = ly;
			_lineLength = len;
			_lineRotation = rot;
			_linePhi = phi;
		}
		
		public function get velocity():Number {
			return _velocity;
		}
		
		public function set velocity(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<0) return;
			if (arg>_maxVelocity) arg = _maxVelocity;
			
			_velocity = arg;
		}
		
		public function get wavesSP():Sprite {
			return _wavesSP;
		}
		
		public function get motionSP():Sprite {
			return _motionSP;			
		}		
		
		protected var _intensityRampTime:Number = 500;
		protected var _velocityRampTime:Number = 500;
				
	}
	
}


internal class CrestCircle {
	public var x:Number;
	public var y:Number;
	public var startTime:Number;
	public var color:uint;
	public function Circle(initX:Number, initY:Number, initStartTime:Number, initColor:Number) {
		x = initX;
		y = initY;
		startTime = initStartTime;
		color = initColor;		
	}
}
