
package {
	
	import flash.display.Sprite;
	
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import fl.controls.Button;
	
	
	public class Main extends Sprite implements ITimeMasterResponder {
		
		
		private var _skyView:ZodiacSkyView;
		
		private var _timeMaster:TimeMaster;
		
		public function Main() {
			
			titlebar.addEventListener(NAAPTitleBar.RESET, reset);

			_timeMaster = new TimeMaster();
			_timeMaster.responder = this;
			
			_skyView = new ZodiacSkyView(886);
			_skyView.x = 7;
			_skyView.y = 37;
			addChild(_skyView);
			
			setChildIndex(latitudeNote, numChildren-1);
			setChildIndex(titlebar, numChildren-1);
			
			initializeButton(minusTwoHoursButton, onMinusTwoHoursButtonPressed);
			initializeButton(plusTwoHoursButton, onPlusTwoHoursButtonPressed);
			initializeButton(minusSixHoursButton, onMinusSixHoursButtonPressed);
			initializeButton(plusSixHoursButton, onPlusSixHoursButtonPressed);
			initializeButton(minusOneMonthButton, onMinusOneMonthButtonPressed);
			initializeButton(plusOneMonthButton, onPlusOneMonthButtonPressed);
			
			showConstellationLabelsCheck.setStyle("textFormat", _controlTextFormat);
			showConstellationLabelsCheck.setStyle("embedFonts", true);
			showConstellationLabelsCheck.addEventListener(Event.CHANGE, onShowConstellationLabelsChanged);
			
			showEclipticLabelCheck.setStyle("textFormat", _controlTextFormat);
			showEclipticLabelCheck.setStyle("embedFonts", true);
			showEclipticLabelCheck.addEventListener(Event.CHANGE, onShowEclipticLabelChanged);
			
			showCelestialEquatorLabelCheck.setStyle("textFormat", _controlTextFormat);
			showCelestialEquatorLabelCheck.setStyle("embedFonts", true);
			showCelestialEquatorLabelCheck.addEventListener(Event.CHANGE, onShowCelestialEquatorLabelChanged);
			
			
			solarTimeClock.onHandsDragged = _timeMaster.incrementLatestSolarTime;			
			dayOfYearSlider.onThumbDragged = onDayOfYearSliderThumbDragged;			
			
			reset();
		}
		
		private var _controlTextFormat:TextFormat = new TextFormat("Verdana", 11, 0x000000, false, false, false, null, null, "center");
		
		private function initializeButton(button:Button, clickEventListener:Function):void {
			button.setStyle("focusRectSkin", "OrdinaryButtonFocusRectSkin");
			button.setStyle("upSkin", "OrdinaryButtonUpSkin");
			button.setStyle("overSkin", "OrdinaryButtonOverSkin");
			button.setStyle("downSkin", "OrdinaryButtonDownSkin");
			button.setStyle("textFormat", _controlTextFormat);
			button.setStyle("embedFonts", true);
			button.setStyle("textPadding", 0);
			button.useHandCursor = true;
			button.addEventListener(MouseEvent.CLICK, clickEventListener);
		}
		
		private function onDayOfYearSliderThumbDragged(delta:Number):void {
			_timeMaster.incrementLatestSolarTime(Math.round(delta));			
		}
		
		private function onMinusTwoHoursButtonPressed(evt:MouseEvent):void {
			_timeMaster.incrementSolarTime(-2/24, 700);
		}
		
		private function onPlusTwoHoursButtonPressed(evt:MouseEvent):void {
			_timeMaster.incrementSolarTime(2/24, 700);
		}
		
		private function onMinusSixHoursButtonPressed(evt:MouseEvent):void {
			_timeMaster.incrementSolarTime(-0.25, 1000);
		}
		
		private function onPlusSixHoursButtonPressed(evt:MouseEvent):void {
			_timeMaster.incrementSolarTime(0.25, 1000);
		}
		
		private function onMinusOneMonthButtonPressed(evt:MouseEvent):void {
			_timeMaster.incrementSolarTime(-30, 0);
		}
		
		private function onPlusOneMonthButtonPressed(evt:MouseEvent):void {
			_timeMaster.incrementSolarTime(30, 0);
		}
		
		private function reset(...ignored):void {
			
			showEclipticLabelCheck.selected = false;
			onShowEclipticLabelChanged();
			
			showCelestialEquatorLabelCheck.selected = false;
			onShowCelestialEquatorLabelChanged();
						
			showConstellationLabelsCheck.selected = false;
			onShowConstellationLabelsChanged();
			
			// setting the mode also resets the clock and calls the associated handler
			_timeMaster.mode = TimeMaster.SIMPLE;
		}
		
		private function onShowConstellationLabelsChanged(...ignored):void {
			_skyView.showConstellationLabels = showConstellationLabelsCheck.selected;
		}
		
		private function onShowEclipticLabelChanged(...ignored):void {
			_skyView.showEclipticLabel = showEclipticLabelCheck.selected;
		}
		
		private function onShowCelestialEquatorLabelChanged(...ignored):void {
			_skyView.showCelestialEquatorLabel = showCelestialEquatorLabelCheck.selected;
		}
		
		// the time master responders
		
		// called when an animation first starts
		public function onTimeMasterAnimationStart():void {
			//
		}
		
		// this is called before onTimeMasterTimeChanged is called, so don't use the time values in this function
		public function onTimeMasterAnimationStop():void {
			//
		}
		
		// this is called whenever the time value has changed during an animation (but not at the end)
		public function onTimeMasterAnimationUpdate():void {
			
			_skyView.lock();
			_skyView.setSiderealTime(_timeMaster.latestSiderealTime);
			_skyView.sunLongitude = (_timeMaster.latestSolarDaysSinceLastVernalEquinox/_timeMaster.tropicalYear)*2*Math.PI;
			_skyView.unlock();
			
			dayOfYearSlider.setTime(_timeMaster.latestSolarDaysSinceLastVernalEquinox);
			solarTimeClock.setTime(_timeMaster.latestSolarTime);
			
			dayOfYearField.text = getDayStringFromDaysSinceLastVernalEquinox(_timeMaster.latestSolarDaysSinceLastVernalEquinox-_timeMaster.SOLAR_TIME_AT_EPOCH);
		}
		
		// this is called when a time value has changed instantly, or when an animation of the time
		// value has stopped (whether it has reached its intended target value or not)
		public function onTimeMasterTimeChanged():void {
			
			_skyView.lock();
			_skyView.setSiderealTime(_timeMaster.siderealTime);
			_skyView.sunLongitude = (_timeMaster.solarDaysSinceLastVernalEquinox/_timeMaster.tropicalYear)*2*Math.PI;
			_skyView.unlock();
			
			dayOfYearSlider.setTime(_timeMaster.solarDaysSinceLastVernalEquinox);
			solarTimeClock.setTime(_timeMaster.solarTime);
			
			dayOfYearField.text = getDayStringFromDaysSinceLastVernalEquinox(_timeMaster.solarDaysSinceLastVernalEquinox-_timeMaster.SOLAR_TIME_AT_EPOCH);
		}
		
		private function getDayStringFromDaysSinceLastVernalEquinox(daysSinceVE:Number):String {
			
			var str:String = "";
			
			var doy:Number = ((daysSinceVE + 78)%365 + 365)%365;
			
			var monthPoints:Array = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365];
			var monthNames:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
			
			var i:int = 0;
			while (doy>=monthPoints[i] && i<13) i++;
			i--;
			
			return monthNames[i] + " " + String(int(doy-monthPoints[i]+1));
		}
		
		// this is called when the mode has changed
		// note that setting the mode causes the time to be reset and possibly an animation to be
		// cancelled -- this function get called before all the other responders (so don't use
		// the time values in this function)
		public function onTimeMasterModeChanged():void {
			dayOfYearSlider.tropicalYear = _timeMaster.tropicalYear;
			
			// the day of year slider only works in simple mode
			dayOfYearSlider.visible = (_timeMaster.mode==TimeMaster.SIMPLE);
		}
		
	}	
}
