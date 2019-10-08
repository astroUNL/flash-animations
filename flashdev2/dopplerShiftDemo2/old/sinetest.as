
package {
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	public class sinetest extends Sprite {
		
		protected var _historySP:Sprite;
		protected var _activityState:Boolean = false;
		protected var _updateTimer:Timer;
		
		protected var _historyDuration:Number = 15000;
		protected var _historyWidth:Number = 700;
		protected var _historyHeight:Number = 100;
		
		protected var _omega:Number = 2*Math.PI/1200;
		
		// the phi intervals list is assumed to be ordered with the most recent intervals at the end
		protected var _phiIntervalsList:Array = [];
		
		protected var _activePhiInterval:PhiInterval = null;
		
		public function sinetest() {
			
			_historySP = new Sprite();
			addChild(_historySP);
			
			var hh:Number = _historyHeight;
			var w:Number = _historyWidth;
			
			graphics.clear();
			graphics.moveTo(0, hh);
			graphics.lineStyle(1, 0xa0a0a0);
			graphics.lineTo(w, hh);
			graphics.lineTo(w, -hh);
			graphics.lineTo(0, -hh);
			graphics.lineTo(0, hh);
			
			_updateTimer = new Timer(10);
			_updateTimer.addEventListener("timer", update);
			_updateTimer.start();
		}
		
		protected var _lastGetTimerSecond:Number = 0;
		
		protected function flushAncientHistory():void {
			var spliceCount:int = 0;
			var expirationTime:Number = getTimer() - _historyDuration;
			for (var i:int = 0; i<_phiIntervalsList.length; i++) {
				if (_phiIntervalsList[i].timeEnd<expirationTime) spliceCount++;
			}			
			_phiIntervalsList.splice(0, spliceCount);
		}
		
		protected function update(evt:TimerEvent):void {
			
			var timeNow:Number = getTimer();
			
			var historyStart:Number = timeNow - _historyDuration;
			
			var i:int;
			
			var tStep:Number = _historyDuration/_historyWidth;
			
			var w:Number = _omega;
			var phi:Number;
			var timeEnd:Number;
			
			var t:Number = historyStart;
			var sx:Number = 0;
			var sy:Number = 0;
			
			var yScale:Number = -80;
			
			var interval:PhiInterval;
			
			_historySP.graphics.clear();
			_historySP.graphics.lineStyle(2, 0xff0000);
			_historySP.graphics.moveTo(0, 0);
			
			for (i=0; i<_phiIntervalsList.length; i++) {
				interval = _phiIntervalsList[i];
				
				if (_phiIntervalsList[i].timeEnd<historyStart) continue;
				
				timeEnd = _phiIntervalsList[i].timeEnd;
				phi = _phiIntervalsList[i].phi;
				
				if (t<_phiIntervalsList[i].timeStart) {
					t = Math.min(_phiIntervalsList[i].timeStart, timeNow);
					sx = _historyWidth*((t-historyStart)/_historyDuration);
					sy = yScale*interval.getValue(t);
					_historySP.graphics.lineTo(sx, 0);
					_historySP.graphics.lineTo(sx, sy);
				}
				else {
					// should execute once, and only if the first interval straddles the history starting time
					sy = yScale*interval.getValue(t);
					_historySP.graphics.moveTo(sx, sy);
				}
				
				for (t+=tStep; (t<timeEnd && t<timeNow); t+=tStep) {
					sx = _historyWidth*((t-historyStart)/_historyDuration);
					sy = yScale*interval.getValue(t);
					_historySP.graphics.lineTo(sx, sy);
				}				
				
				if (t>=timeNow) break;
				
				_historySP.graphics.lineTo(sx, 0);
			}
			
			if (t<timeNow) _historySP.graphics.lineTo(_historyWidth, 0);
			else _historySP.graphics.lineTo(_historyWidth, sy);
			
			// flush ancient history
			var getTimerSecond:Number = Math.floor(timeNow/1000);
			if (getTimerSecond!=_lastGetTimerSecond && getTimerSecond%5==0) flushAncientHistory();
			_lastGetTimerSecond = getTimerSecond;
			
			//trace("update: "+(getTimer()-timeNow));
			
			evt.updateAfterEvent();
			
			if (_transitionInEffect && timeNow>_transitionEndTime) {
				_transitionInEffect = false;
				dispatchEvent(new Event("onTransition"));
			}
		}
		
		protected var _transitionInEffect:Boolean = false;
		protected var _transitionEndTime:Number = 0;
		protected var _transitionTotalTime:Number = 2000;
		
		public function get activityState():Boolean {
			return _activityState;
		}
		
		public function set activityState(arg:Boolean):void {
		
			if (_transitionInEffect) {
				trace("can't set activityState, currently in transition");
				return;
			}
			
			var previousActivityState:Boolean = _activityState;
			
			_activityState = arg;
			
			var timeNow:Number = getTimer();
			var phiNow:Number = (0.75*Math.PI) - (timeNow*_omega)%(2*Math.PI);	
						
			if (_activityState && _activePhiInterval==null) {
				_activePhiInterval = new PhiInterval(timeNow, phiNow, _omega);
				_phiIntervalsList.push(_activePhiInterval);
				
				
			}
			else if (!_activityState && _activePhiInterval!=null) {
				_activePhiInterval.timeEnd = timeNow + PhiInterval.rampTime;
				_activePhiInterval = null;
				
				
			}
			
			
			
			if (previousActivityState!=_activityState) {
				_transitionInEffect = true;
				_transitionEndTime = timeNow + PhiInterval.rampTime;
				dispatchEvent(new Event("onTransition"));
			}
			
			
		}		
		
		public function get inTransition():Boolean {
			return _transitionInEffect;			
		}
		
	}
	
}

