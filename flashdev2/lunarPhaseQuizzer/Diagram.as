
package {
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	import astroUNL.utils.easing.CubicEaser;
	
	public class Diagram extends Sprite {
		
		public static const SUNLIGHT_DRAGGED:String = "sunlightDragged";
		public static const MOON_DRAGGED:String = "moonDragged";
		
		public static const MODE_TRANSITION_STEP:String = "modeTransitionStep";
		public static const MODE_FINALIZED:String = "modeFinalized";
		
		public static const HIDE_SUNLIGHT:String = "hideSunlight";
		public static const HIDE_MOON:String = "hideMoon";
		public static const HIDE_MOON_APPEARANCE:String = "hideMoonAppearance";
		public static const SHOW_ALL:String = "showAll";
		
		protected var _moonDistance:Number = 155;
		protected var _sunlightDistance:Number = 235;
		
		protected var _moonAngle:Number = 0;
		protected var _sunlightAngle:Number = 0;
		protected var _phaseAngle:Number = 0;
		
		protected var _mode:String;
		
		protected var _modeTransitionTimer:Timer;
		protected var _moonAlphaEaser:CubicEaser;
		protected var _sunlightAlphaEaser:CubicEaser;
		protected var _modeTransitionStopTime:Number;
		protected var _modeTransitionDuration:Number = 250;
		
		public function get modeTransitionStopTime():Number {
			return _modeTransitionStopTime;
		}
		
		public function Diagram() {
			
			moonLocationQuestion.alpha = 0;
			sunlightLocationQuestion.alpha = 0;
			
			_modeTransitionTimer = new Timer(20);
			_modeTransitionTimer.addEventListener(TimerEvent.TIMER, onModeTransitionTimer);
			
			_moonAlphaEaser = new CubicEaser(1);
			_sunlightAlphaEaser = new CubicEaser(1);
			
			_mode = "";
			
			setMode(Diagram.SHOW_ALL, true);
			
			sunlight.diagram = this;
			sunlight.eventType = Diagram.SUNLIGHT_DRAGGED;
			sunlight.propertyName = "sunlightAngle";
			
			moon.diagram = this;
			moon.eventType = Diagram.MOON_DRAGGED;
			moon.propertyName = "moonAngle";
			
			update();			
		}
		
		// both moonAngle and sunlightAngle are measured CCW from right, and expressed in radians
		
		public function get moonAngle():Number {
			return _moonAngle;
		}
		
		public function set moonAngle(arg:Number):void {
			if (_mode==Diagram.HIDE_MOON) {
				trace("not allowed to change moon angle in this mode");
				return;
			}
			_moonAngle = (arg%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			if (_mode==Diagram.SHOW_ALL) {
				// when in showAll (ie. answer) mode change the phase angle when the moon angle changes
				_phaseAngle = ((Math.PI + _sunlightAngle - _moonAngle)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)
			}
			update();
		}
		
		public function get sunlightAngle():Number {
			return _sunlightAngle;
		}
		
		public function set sunlightAngle(arg:Number):void {
			if (_mode==Diagram.HIDE_SUNLIGHT) {
				trace("not allowed to change sunlight angle in this mode");
				return;
			}
			_sunlightAngle = (arg%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			if (_mode==Diagram.SHOW_ALL) {
				// when in showAll (ie. answer) mode change the phase angle when the sunlight angle changes
				_phaseAngle = ((Math.PI + _sunlightAngle - _moonAngle)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)
			}
			update();
		}
		
		// phaseAngle is expressed in radians
		// a phaseAngle of _Pi_ corresponds to new moon and the phaseAngle _decreases_ as the moon
		// progresses through its phases -- this convention matches the phaseDisc component's definition
		
		public function get phaseAngle():Number {
			return _phaseAngle;
		}
		
		public function set phaseAngle(arg:Number):void {
			if (_mode==Diagram.HIDE_MOON_APPEARANCE) {
				trace("not allowed to change phase angle in this mode");
				return;
			}
			_phaseAngle = (arg%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			if (_mode==Diagram.SHOW_ALL) {
				// when in showAll (ie. answer) mode change the moon angle when the phase angle changes
				_moonAngle = ((Math.PI + _sunlightAngle - _phaseAngle)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)
			}
			update();
		}
		
		protected function update():void {			
			if (_mode==Diagram.HIDE_SUNLIGHT) {
				// move the sun to match
				_sunlightAngle = ((_phaseAngle + _moonAngle - Math.PI)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)
			}
			else if (_mode==Diagram.HIDE_MOON) {
				// move the moon to match
				_moonAngle = ((Math.PI + _sunlightAngle - _phaseAngle)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)
			}
			else if (_mode==Diagram.HIDE_MOON_APPEARANCE) {
				// determine the phaseAngle for the given moon and sunlight angles
				_phaseAngle = ((Math.PI + _sunlightAngle - _moonAngle)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)
			}
			// else: in showAll mode the individual setters do the necessary calculations, as it depends on what's being set
		
			moon.x = _moonDistance*Math.cos(_moonAngle);
			moon.y = -_moonDistance*Math.sin(_moonAngle);
			moon.rotation = -_moonAngle*180/Math.PI;
			
			sunlight.x = _sunlightDistance*Math.cos(_sunlightAngle);
			sunlight.y = -_sunlightDistance*Math.sin(_sunlightAngle);
			sunlight.rotation = -_sunlightAngle*180/Math.PI;
			
			moon.shadow.rotation = sunlight.rotation - moon.rotation;
			earth.shadow.rotation = sunlight.rotation - earth.rotation;
		}
		
		public function get mode():String {
			return _mode;
		}
		
		public function set mode(arg:String):void {
			setMode(arg);
		}
		
		public function setMode(arg:String, noTransition:Boolean=false):Boolean {
			if ((arg==Diagram.HIDE_SUNLIGHT || arg==Diagram.HIDE_MOON || arg==Diagram.HIDE_MOON_APPEARANCE || arg==Diagram.SHOW_ALL) && arg!=_mode) {
				// the new mode is valid and it's different than the current mode				
				_mode = arg;

				// immediately disable and enable the appropriate objects
				// and also throw focus off selected object if it's being hid
				// and also change the first time instructions
				if (_mode==Diagram.HIDE_SUNLIGHT) {
					if (stage.focus==sunlight) stage.focus = null;
					sunlight.mouseEnabled = sunlight.tabEnabled = false;
					moon.mouseEnabled = moon.tabEnabled = true;
					firstRunInstructions.instructionsField.text = "Drag the Moon or change the Moon's\rphase to change the sunlight direction.";
				}
				else if (_mode==Diagram.HIDE_MOON) {
					if (stage.focus==moon) stage.focus = null;
					sunlight.mouseEnabled = sunlight.tabEnabled = true;
					moon.mouseEnabled = moon.tabEnabled = false;
					firstRunInstructions.instructionsField.text = "Drag the sunlight arrows or change the\rMoon's phase to move the Moon.";
				}
				else {
					sunlight.mouseEnabled = sunlight.tabEnabled = true;
					moon.mouseEnabled = moon.tabEnabled = true;
					firstRunInstructions.instructionsField.text = "Drag the Moon or the sunlight arrows\rto change the Moon's phase.";
				}				
				
				if (noTransition) finalizeMode();
				else {
					var timeNow:Number = getTimer();
					_modeTransitionStopTime = timeNow + _modeTransitionDuration;
					if (_mode==Diagram.HIDE_SUNLIGHT) {
						_sunlightAlphaEaser.setTarget(timeNow, null, _modeTransitionStopTime, 0);
						_moonAlphaEaser.setTarget(timeNow, null, _modeTransitionStopTime, 1);
					}
					else if (_mode==Diagram.HIDE_MOON) {
						_sunlightAlphaEaser.setTarget(timeNow, null, _modeTransitionStopTime, 1);
						_moonAlphaEaser.setTarget(timeNow, null, _modeTransitionStopTime, 0);
					}
					else {
						_sunlightAlphaEaser.setTarget(timeNow, null, _modeTransitionStopTime, 1);
						_moonAlphaEaser.setTarget(timeNow, null, _modeTransitionStopTime, 1);
					}
					if (!_modeTransitionTimer.running) _modeTransitionTimer.start();
				}				
				
				return true;
			}
			else return false;
		}
		
		protected function onModeTransitionTimer(evt:TimerEvent):void {
			var timeNow:Number = getTimer();			
			if (timeNow>_sunlightAlphaEaser.targetTime) finalizeMode();				
			else {
				earth.shadow.alpha = moon.shadow.alpha = sunlight.alpha = _sunlightAlphaEaser.getValue(timeNow);
				moon.alpha = _moonAlphaEaser.getValue(timeNow);
			}
			dispatchEvent(new Event(Diagram.MODE_TRANSITION_STEP));
			moonLocationQuestion.alpha = 1 - moon.alpha;
			sunlightLocationQuestion.alpha = 1 - sunlight.alpha;
			evt.updateAfterEvent();			
		}
		
		protected function finalizeMode():void {
			if (_mode==Diagram.HIDE_SUNLIGHT) {
				_sunlightAlphaEaser.init(0);
				_moonAlphaEaser.init(1);
				earth.shadow.alpha = moon.shadow.alpha = sunlight.alpha = 0;
				moon.alpha = 1;
			}
			else if (_mode==Diagram.HIDE_MOON) {
				_sunlightAlphaEaser.init(1);
				_moonAlphaEaser.init(0);
				earth.shadow.alpha = moon.shadow.alpha = sunlight.alpha = 1;
				moon.alpha = 0;
			}
			else {
				_sunlightAlphaEaser.init(1);
				_moonAlphaEaser.init(1);
				earth.shadow.alpha = moon.shadow.alpha = sunlight.alpha = 1;
				moon.alpha = 1;
			}
			if (_modeTransitionTimer.running) _modeTransitionTimer.stop();
			moonLocationQuestion.alpha = 1 - moon.alpha;
			sunlightLocationQuestion.alpha = 1 - sunlight.alpha;
			dispatchEvent(new Event(Diagram.MODE_FINALIZED));
		}
		
		
		protected var _firstRunInstructionsTimer:Timer;
		protected var _firstRunInstructionsAlphaEaser:CubicEaser;
		protected var _firstRunInstructionsTransitionDuration:Number = 400;		
		
		public function hideFirstRunInstructions():void {
			if (_firstRunInstructionsTimer!=null) return;
			var timeNow:Number = getTimer();
			_firstRunInstructionsAlphaEaser = new CubicEaser(firstRunInstructions.alpha);
			_firstRunInstructionsAlphaEaser.setTarget(timeNow, null, timeNow+_firstRunInstructionsTransitionDuration, 0);
			_firstRunInstructionsTimer = new Timer(20);
			_firstRunInstructionsTimer.addEventListener(TimerEvent.TIMER, onHideFirstRunInstructionsTimer);
			_firstRunInstructionsTimer.start();
		}
		
		protected function onHideFirstRunInstructionsTimer(evt:TimerEvent):void {
			var timeNow:Number = getTimer();
			if (timeNow>=_firstRunInstructionsAlphaEaser.targetTime) {
				_firstRunInstructionsAlphaEaser.init(0);
				firstRunInstructions.alpha = 0;
				_firstRunInstructionsTimer.stop();
			}
			else {
				firstRunInstructions.alpha = _firstRunInstructionsAlphaEaser.getValue(timeNow);
			}
		}		
		
	}	
}
