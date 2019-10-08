

package {
	
	import flash.events.Event;
	
	public class Source extends DraggableObject implements ISource {
		
		public static const WaveOmega:Number = 2*Math.PI/1500;
		
		// the phi intervals list is assumed to be ordered with the most recent intervals at the end
		public var _phiIntervalsList:Array = [];
		
		protected var _activePhiInterval:PhiInterval = null;
		
		protected var _emissionState:Boolean = false;
		protected var _transitionInEffect:Boolean = false;
		protected var _transitionEndTime:Number = 0;
		
		public function Source() {
			//
		}

		public static const ON_TRANSITION:String = "onTransition";
		// a source must dispatch an "onTransition" event when a transition starts and when it ends;
		// or, if the transition is immediate (after calls to setPosition and clearHistory) a single
		// "onTransition" event must be dispatched
		
		override public function setPosition(pos:Position):void {
			// sets the position of the source, clears the history, and sets the emission state to false
			// without transition (but still dispatches a single "onTransition" event)
			super.setPosition(pos);
			clearHistory();
		}
	
		public function clearHistory():void {
			// clears the history and starts over with the current position, and sets the emission state to
			// false without transition (but still dispatches a single "onTransition" event)
			
			_phiIntervalsList = [];
			_activePhiInterval = null;
			_emissionState = false;
			_transitionInEffect = false;
			
			dispatchEvent(new Event("onTransition"));
		}
		
		override public function expireHistory(expTime:Number):void {
			// removes all position and emission history earlier than the given time; one should call this
			// function periodically to keep the history arrays from growing unnessarily large
			
			// remove position history
			super.expireHistory(expTime);

			// remove emission history
			var delCount:uint;
			for (delCount=0; delCount<_phiIntervalsList.length; delCount++) {
				if (_phiIntervalsList[delCount].timeEnd>=expTime) break;				
			}
			_phiIntervalsList.splice(0, delCount);			
		}
		
		public function getValue(time:Number):Number {
			// returns the value of the source emission at the given time
			for (var i:int = 0; i<_phiIntervalsList.length; i++) {
				if (_phiIntervalsList[i].timeStart<=time && time<=_phiIntervalsList[i].timeEnd) return _phiIntervalsList[i].getValue(time);
			}
			return 0;
		}
				
		public function getValues(timesList:Array):void {
			// for each object in the times list the time property is read and the value property is set to
			// the value of the source emission at that time; timesList is assumed to be ordered
			
			for (var i:int = 0; i<timesList.length; i++) {
				timesList[i].value = getValue(timesList[i].time);
			}			
		}		

		
		public function getObservedValue(obsPos:Position, waveSpeed:Number):Number {
			// returns the value that an observer at the given position (time and location) would observe if
			// waves travelled at the given speed; this function takes into account the source's position history
			
			var i:int;
			var j:int;
			
			var q:Number;
			var csp:Position; // current source position
			var psp:Position; // previous source position
			
			var left:Number;
			var right:Number;
			var midpoint:Number;
			var u:Number;
			var tx:Number;
			var ty:Number;
			var qLeft:Number;
			var qRight:Number;
			var qMidpoint:Number;			
			
			var obsTime:Number = obsPos.time;
			var obsX:Number = obsPos.x;
			var obsY:Number = obsPos.y;
				
			var srcTime:Number = Number.NaN;
			
			var sourceLog:Array = _positionLog.getRawLog();
									
			for (i=sourceLog.length-1; i>=0; i--) {
				
				csp = sourceLog[i];
				
				q = Math.sqrt((csp.x-obsX)*(csp.x-obsX) + (csp.y-obsY)*(csp.y-obsY)) - waveSpeed*(obsTime-csp.time);
				
				if (q<0) {
					// this means that sourceTime is more recent than csp.time
					
					if (i<sourceLog.length-1) {
						// so sourceTime is between the current source point time and the previous source point time
						// point (psp.time, which is more recent); we use the bisection method to find q(sourceTime) = 0
										
						left = 0;
						right = 1;
						
						u = left;
						srcTime = csp.time + u*(psp.time - csp.time);
						tx = csp.x + u*(psp.x - csp.x);
						ty = csp.y + u*(psp.y - csp.y);
						qLeft = Math.sqrt((tx-obsX)*(tx-obsX) + (ty-obsY)*(ty-obsY)) - waveSpeed*(obsTime-srcTime);
						
						u = right;
						srcTime = csp.time + u*(psp.time - csp.time);
						tx = csp.x + u*(psp.x - csp.x);
						ty = csp.y + u*(psp.y - csp.y);
						qRight = Math.sqrt((tx-obsX)*(tx-obsX) + (ty-obsY)*(ty-obsY)) - waveSpeed*(obsTime-srcTime);
						
						for (j=0; j<50; j++) {
							
							midpoint = (left + right)/2;
							u = midpoint;
							srcTime = csp.time + u*(psp.time - csp.time);
							tx = csp.x + u*(psp.x - csp.x);
							ty = csp.y + u*(psp.y - csp.y);
							qMidpoint = Math.sqrt((tx-obsX)*(tx-obsX) + (ty-obsY)*(ty-obsY)) - waveSpeed*(obsTime-srcTime);
							
							if (qLeft*qMidpoint>0) {
								left = midpoint;
								qLeft = qMidpoint;
							}
							else {
								right = midpoint;
								qRight = qMidpoint;
							}
						}						
					}
					else {
						
						srcTime = obsTime - Math.sqrt((csp.x-obsX)*(csp.x-obsX) + (csp.y-obsY)*(csp.y-obsY))/waveSpeed;
					}
					
					break;
				}
				
				psp = csp;
			}
			
			if (isNaN(srcTime)) {
				srcTime = obsTime - Math.sqrt((csp.x-obsX)*(csp.x-obsX) + (csp.y-obsY)*(csp.y-obsY))/waveSpeed;
			}
			
			return getValue(srcTime);			
		}
		
		public function getObservedValues(obsPosList:Array, waveSpeed:Number):void {
			// assigns the value property for each object in the observer positions list with the value that
			// would be observed at the given location and time if waves travelled at the given speed
			
			for (var i:int = 0; i<obsPosList.length; i++) {
				obsPosList[i].value = getObservedValue(obsPosList[i], waveSpeed);
				
			}
		}		
		
		public function getPeaks(start:Number, end:Number):Array {
			// returns an array of positions (Position objects) of the source when it was emitting a crest,
			// between the time interval bracketed by the given times
			var arr:Array = [];
			var pks:Array;
			var i:int;
			var j:int;
			var k:int = 0;
			for (i=0; i<_phiIntervalsList.length; i++) {
				pks = _phiIntervalsList[i].getPeaks(start, end);
				_positionLog.getPositions(pks);				
				arr = arr.concat(pks);
			}
			return arr;			
		}
		
		public function getEmissionState():Boolean {
			// returns the emission state; note that the emission state may still be true for a short period
			// after setting it to false while the source transitions between states (cf. inTransition)
			return _emissionState;
		}
		
		public function setEmissionState(newState:Boolean):void {
			// sets the emission state, that is, whether the source is currently emitting waves or not; note
			// that a source may continue to emit waves for a brief period of time after setting the state
			// to false (cf. inTransition); also note that you may not be able to set the state during
			// transitions between states
			if (_transitionInEffect) {
				trace("can't change emission state, currently in transition");
				return;
			}
			
			if (newState==_emissionState) return;
			
			var timeNow:Number = TimeKeeper.getTime();
			
			if (newState && _activePhiInterval==null) {
				var phiNow:Number = (1.85*Math.PI) - (timeNow*WaveOmega)%(2*Math.PI);
				
				_activePhiInterval = new PhiInterval(timeNow, phiNow, WaveOmega);
				_phiIntervalsList.push(_activePhiInterval);
				
				_transitionEndTime = timeNow + PhiInterval.RampTime;
			}
			else if (!newState && _activePhiInterval!=null) {
				
				var timeEnd:Number = (2.15*Math.PI - _activePhiInterval.phi)/WaveOmega;
				var period:Number = 2*Math.PI/WaveOmega;
				
				var nEnd:Number = ((timeEnd/period)%1 + 1)%1;
				
				var cycleStart:Number = _activePhiInterval.timeStart/period;
				var cycleNow:Number = timeNow/period;
				var cycleEnd:Number = Math.floor(cycleNow) + ((timeEnd/period)%1 + 1)%1;
				
				// the end must occur in the future
				if (cycleEnd<cycleNow) cycleEnd += 1;
				
				// there must enough transition time
				// (assumes transition time is less than a full period)
				var relDiff:Number = (cycleEnd-cycleNow)/(PhiInterval.RampTime/period);
				if (relDiff<1) cycleEnd += 1;
				
				// we want at least one complete cycle
				if ((cycleEnd-cycleStart)<1) cycleEnd += 1;
				
				_transitionEndTime = _activePhiInterval.timeEnd = period*cycleEnd;
				
				_activePhiInterval = null;
			}
			
			_emissionState = newState;
			_transitionInEffect = true;
			dispatchEvent(new Event("onTransition"));
		}		
		
		public function toggleEmissionState():Boolean {
			// toggles the emission state and returns the value of the emission state; note that the state
			// may not change if currently in transition
			setEmissionState(!_emissionState);
			return _emissionState;
		}
		
		public function get inTransition():Boolean {
			// a read-only property that indicates whether the source is transitioning from emission to
			// non-emission or vice-versa; during a transition you may not be able to set that emission state
			return _transitionInEffect;			
		}
				
		override public function update(time:Number):void {
			super.update(time);
			if (_transitionInEffect && time>=_transitionEndTime) {
				_transitionInEffect = false;
				dispatchEvent(new Event("onTransition"));
			}
		}
		
	}	
}

