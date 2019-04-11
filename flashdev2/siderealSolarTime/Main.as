
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import fl.controls.Button;
	
	public class Main extends Sprite implements ITimeMasterResponder {
		
		private var _timeMaster:TimeMaster;
		
		private var _vernalEquinoxButton:Button;
		private var _summerSolsticeButton:Button;
		private var _autumnalEquinoxButton:Button;
		private var _winterSolsticeButton:Button;
		
		private var _buttonLookup:Dictionary = new Dictionary();
		private var _buttonTextFormat:TextFormat = new TextFormat("Verdana", 11, 0x000000, false, false, false, null, null, "center");
		private var _nextButtonTabIndex:int = 1;
		
		public function Main() {			
			
			titlebar.addEventListener(NAAPTitleBar.RESET, reset);

			_timeMaster = new TimeMaster();
			_timeMaster.responder = this;
			
			initializeButton(incrementBySolarDayButton, "Ordinary", onIncrementBySolarDayAnimated);
			initializeButton(incrementByTenSolarDaysButton, "Ordinary", onIncrementByTenSolarDaysAnimated);
			initializeButton(incrementBySiderealDayButton, "Ordinary", onIncrementBySiderealDayAnimated);
			initializeButton(incrementByTenSiderealDaysButton, "Ordinary", onIncrementByTenSiderealDaysAnimated);
						
			initializeButton(midnightButton, "Ordinary", onGoToMidnightAnimated);
			initializeButton(sunriseButton, "Ordinary", onGoToSunriseAnimated);
			initializeButton(noonButton, "Ordinary", onGoToNoonAnimated);
			initializeButton(sunsetButton, "Ordinary", onGoToSunsetAnimated);
			
			initializeButton(sidereal0hButton, "Ordinary", onGoTo0hAnimated);
			initializeButton(sidereal6hButton, "Ordinary", onGoTo6hAnimated);
			initializeButton(sidereal12hButton, "Ordinary", onGoTo12hAnimated);
			initializeButton(sidereal18hButton, "Ordinary", onGoTo18hAnimated);
			
			_vernalEquinoxButton = new Button();
			_vernalEquinoxButton.x = dayOfYearSlider.x - 16;
			_vernalEquinoxButton.y = dayOfYearSlider.y + 20;
			_vernalEquinoxButton.width = 66;
			_vernalEquinoxButton.height = 43;
			initializeButton(_vernalEquinoxButton, "VernalEquinox", onGoToVernalEquinoxAnimated);
			_vernalEquinoxButton.label = "Vernal\nEquinox";
			addChild(_vernalEquinoxButton);
			
			_summerSolsticeButton = new Button();
			_summerSolsticeButton.x = dayOfYearSlider.x + 97.5 - 33;
			_summerSolsticeButton.y = _vernalEquinoxButton.y;
			_summerSolsticeButton.width = 66;
			_summerSolsticeButton.height = 43;
			initializeButton(_summerSolsticeButton, "Event", onGoToSummerSolsticeAnimated);
			_summerSolsticeButton.label = "Summer\nSolstice";
			addChild(_summerSolsticeButton);
			
			_autumnalEquinoxButton = new Button();
			_autumnalEquinoxButton.x = dayOfYearSlider.x + 195 - 33;
			_autumnalEquinoxButton.y = _vernalEquinoxButton.y;
			_autumnalEquinoxButton.width = 66;
			_autumnalEquinoxButton.height = 43;
			initializeButton(_autumnalEquinoxButton, "Event", onGoToAutumnalEquinoxAnimated);
			_autumnalEquinoxButton.label = "Autumnal\nEquinox";
			addChild(_autumnalEquinoxButton);			
			
			_winterSolsticeButton = new Button();
			_winterSolsticeButton.x = dayOfYearSlider.x + 292.5 - 33;
			_winterSolsticeButton.y = _vernalEquinoxButton.y;
			_winterSolsticeButton.width = 66;
			_winterSolsticeButton.height = 43;
			initializeButton(_winterSolsticeButton, "Event", onGoToWinterSolsticeAnimated);
			_winterSolsticeButton.label = "Winter\nSolstice";
			addChild(_winterSolsticeButton);			
			
			siderealAnalogClock.showAmPmLabels = false;
			
			orbitView.onDragged = _timeMaster.incrementLatestSolarTime;
			solarAnalogClock.onHandsDragged = _timeMaster.incrementLatestSolarTime;
			siderealAnalogClock.onHandsDragged = _timeMaster.incrementLatestSiderealTime;
			
			dayOfYearSlider.onThumbDragged = _timeMaster.incrementLatestSolarTime;
			
			reset();
		}
		
		private function goToFractionOfYear(fractionOfYear:Number, animationDuration:Number=0):void {
			var t:Number = (_timeMaster.latestSolarTime - _timeMaster.SOLAR_TIME_AT_EPOCH)/_timeMaster.tropicalYear;
			t = getNextTimeWithFraction(t, fractionOfYear);
			t = _timeMaster.SOLAR_TIME_AT_EPOCH + t*_timeMaster.tropicalYear;
			if (!_timeMaster.timesAreEqual(_timeMaster.solarTime, t)) _timeMaster.setSolarTime(t, animationDuration);
		}
		
		private function goToSolarTimeOfDay(solarTimeOfDay:Number, animationDuration:Number=0):void {
			var t:Number = getNextTimeWithFraction(_timeMaster.latestSolarTime, solarTimeOfDay);
			if (!_timeMaster.timesAreEqual(_timeMaster.solarTime, t)) _timeMaster.setSolarTime(t, animationDuration);
		}
		
		private function goToSiderealTimeOfDay(siderealTimeOfDay:Number, animationDuration:Number=0):void {
			var t:Number = getNextTimeWithFraction(_timeMaster.latestSiderealTime, siderealTimeOfDay);
			if (!_timeMaster.timesAreEqual(_timeMaster.siderealTime, t)) _timeMaster.setSiderealTime(t, animationDuration);
		}
		
		private function getNextTimeWithFraction(currentTime:Number, fraction:Number):Number {
			fraction = (fraction%1 + 1)%1;
			var currInt:int = Math.floor(currentTime);
			var currFrac:Number = currentTime - currInt;
			if ((fraction-currFrac)<1e-8) currInt += 1;
			return (currInt+fraction);			
		}
		
		private function onGoToMidnightAnimated(...ignored):void {
			goToSolarTimeOfDay(0, 1000);			
		}
		private function onGoToSunriseAnimated(...ignored):void {
			goToSolarTimeOfDay(0.25, 1000);			
		}
		private function onGoToNoonAnimated(...ignored):void {
			goToSolarTimeOfDay(0.5, 1000);			
		}		
		private function onGoToSunsetAnimated(...ignored):void {
			goToSolarTimeOfDay(0.75, 1000);			
		}
		
		private function onGoTo0hAnimated(...ignored):void {
			goToSiderealTimeOfDay(0, 1000);
		}
		private function onGoTo6hAnimated(...ignored):void {
			goToSiderealTimeOfDay(0.25, 1000);
		}
		private function onGoTo12hAnimated(...ignored):void {
			goToSiderealTimeOfDay(0.5, 1000);
		}
		private function onGoTo18hAnimated(...ignored):void {
			goToSiderealTimeOfDay(0.75, 1000);
		}
		
		private function reset(...ignored):void {
			// setting the mode also resets the clock and calls the associated handler
			_timeMaster.mode = TimeMaster.SIMPLE;
		}
		
		private function toggleMode(...ignored):void {
			if (_timeMaster.mode==TimeMaster.SIMPLE) _timeMaster.mode = TimeMaster.JULIAN;
			else _timeMaster.mode = TimeMaster.SIMPLE;
		}		
		
		
		private function onIncrementByTenSolarDaysAnimated(...ignored):void {
			_timeMaster.incrementSolarTime(10, 2000);
		}
		
		private function onIncrementByTenSiderealDaysAnimated(...ignored):void {
			_timeMaster.incrementSiderealTime(10, 2000);
		}		
		
		private function onIncrementBySolarDayAnimated(...ignored):void {
			_timeMaster.incrementSolarTime(1, 1000);
		}
		
		private function onIncrementBySiderealDayAnimated(...ignored):void {
			_timeMaster.incrementSiderealTime(1, 1000);
		}		
		
		private function onGoToVernalEquinoxAnimated(...ignored):void {
			goToFractionOfYear(0, 2000);
		}

		private function onGoToSummerSolsticeAnimated(...ignored):void {
			goToFractionOfYear(0.25, 2000);
		}
		
		private function onGoToAutumnalEquinoxAnimated(...ignored):void {
			goToFractionOfYear(0.5, 2000);
		}
		
		private function onGoToWinterSolsticeAnimated(...ignored):void {
			goToFractionOfYear(0.75, 2000);
		}

		// the time master responder functions
		
		public function onTimeMasterAnimationStart():void {
			//trace("on animation start");
		}
		
		public function onTimeMasterAnimationStop():void {
			//trace("on animation stop");
		}
		
		public function onTimeMasterAnimationUpdate():void {
			
			solarDaysSinceVernalEquinoxField.text = _timeMaster.latestSolarDaysSinceLastVernalEquinox.toFixed(3);
			siderealDaysSinceVernalEquinoxField.text = _timeMaster.latestSiderealDaysSinceLastVernalEquinox.toFixed(3);
			
			setButtonHighlighted(sidereal0hButton, _timeMaster.latestIsAt0h);
			setButtonHighlighted(sidereal6hButton, _timeMaster.latestIsAt6h);
			setButtonHighlighted(sidereal12hButton, _timeMaster.latestIsAt12h);
			setButtonHighlighted(sidereal18hButton, _timeMaster.latestIsAt18h);
			
			setButtonHighlighted(midnightButton, _timeMaster.latestIsAtMidnight);
			setButtonHighlighted(sunriseButton, _timeMaster.latestIsAtSunrise);
			setButtonHighlighted(noonButton, _timeMaster.latestIsAtNoon);
			setButtonHighlighted(sunsetButton, _timeMaster.latestIsAtSunset);
			
			setButtonHighlighted(_vernalEquinoxButton, _timeMaster.latestIsAtVernalEquinox);
			setButtonHighlighted(_summerSolsticeButton, _timeMaster.latestIsAtSummerSolstice);
			setButtonHighlighted(_autumnalEquinoxButton, _timeMaster.latestIsAtAutumnalEquinox);
			setButtonHighlighted(_winterSolsticeButton, _timeMaster.latestIsAtWinterSolstice);
			
			dayOfYearSlider.setTime(_timeMaster.latestSolarDaysSinceLastVernalEquinox);
			orbitView.setTime(_timeMaster.latestSolarTime, _timeMaster.latestSolarDaysSinceLastVernalEquinox);
			solarAnalogClock.setTime(_timeMaster.latestSolarTime);
			siderealAnalogClock.setTime(_timeMaster.latestSiderealTime);
		}
		
		public function onTimeMasterTimeChanged():void {
			
			solarDaysSinceVernalEquinoxField.text = _timeMaster.solarDaysSinceLastVernalEquinox.toFixed(3);
			siderealDaysSinceVernalEquinoxField.text = _timeMaster.siderealDaysSinceLastVernalEquinox.toFixed(3);
			
			trace("");
			trace("solar days since ve: "+_timeMaster.solarDaysSinceLastVernalEquinox);
			trace("sidereal days since ve: "+_timeMaster.siderealDaysSinceLastVernalEquinox);
			
			setButtonHighlighted(sidereal0hButton, _timeMaster.isAt0h);
			setButtonHighlighted(sidereal6hButton, _timeMaster.isAt6h);
			setButtonHighlighted(sidereal12hButton, _timeMaster.isAt12h);
			setButtonHighlighted(sidereal18hButton, _timeMaster.isAt18h);
			
			setButtonHighlighted(midnightButton, _timeMaster.isAtMidnight);
			setButtonHighlighted(sunriseButton, _timeMaster.isAtSunrise);
			setButtonHighlighted(noonButton, _timeMaster.isAtNoon);
			setButtonHighlighted(sunsetButton, _timeMaster.isAtSunset);
			
			setButtonHighlighted(_vernalEquinoxButton, _timeMaster.isAtVernalEquinox);
			setButtonHighlighted(_summerSolsticeButton, _timeMaster.isAtSummerSolstice);
			setButtonHighlighted(_autumnalEquinoxButton, _timeMaster.isAtAutumnalEquinox);
			setButtonHighlighted(_winterSolsticeButton, _timeMaster.isAtWinterSolstice);
			
			dayOfYearSlider.setTime(_timeMaster.solarDaysSinceLastVernalEquinox);
			orbitView.setTime(_timeMaster.solarTime, _timeMaster.solarDaysSinceLastVernalEquinox);
			solarAnalogClock.setTime(_timeMaster.solarTime);
			siderealAnalogClock.setTime(_timeMaster.siderealTime);
		}
		
		
		private function initializeButton(button:Button, skinPrefix:String, clickEventListener:Function):void {
			
			button.setStyle("focusRectSkin", skinPrefix+"ButtonFocusRectSkin");
			button.setStyle("textFormat", _buttonTextFormat);
			button.setStyle("embedFonts", true);
			button.setStyle("textPadding", 0);
			button.useHandCursor = true;
			button.tabIndex = _nextButtonTabIndex++;
			button.addEventListener(MouseEvent.CLICK, clickEventListener);
			
			_buttonLookup[button] = {};
			_buttonLookup[button].skinPrefix = skinPrefix;
			_buttonLookup[button].highlighted = true;
			
			setButtonHighlighted(button, false);
			
			button.validateNow();
		}
		
		private function setButtonHighlighted(button:Button, highlighted:Boolean):void {
			if (highlighted==_buttonLookup[button].highlighted) return;
			_buttonLookup[button].highlighted = highlighted;
			var skinPrefix:String = _buttonLookup[button].skinPrefix;
			if (highlighted) {
				button.setStyle("upSkin", skinPrefix+"HighlightedButtonUpSkin");
				button.setStyle("overSkin", skinPrefix+"HighlightedButtonOverSkin");
				button.setStyle("downSkin", skinPrefix+"HighlightedButtonDownSkin");
			}
			else {
				button.setStyle("upSkin", skinPrefix+"ButtonUpSkin");
				button.setStyle("overSkin", skinPrefix+"ButtonOverSkin");
				button.setStyle("downSkin", skinPrefix+"ButtonDownSkin");
			}
		}
		
		public function onTimeMasterModeChanged():void {
			
			orbitView.tropicalYear = _timeMaster.tropicalYear;
			orbitView.siderealPerSolar = _timeMaster.siderealPerSolar;
			
			dayOfYearSlider.tropicalYear = _timeMaster.tropicalYear;
			
			// the day of year slider only works in simple mode
			dayOfYearSlider.visible = (_timeMaster.mode==TimeMaster.SIMPLE);
		}
	
	}
}

