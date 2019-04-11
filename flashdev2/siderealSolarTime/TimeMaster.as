
package {
	

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import astroUNL.utils.easing.CubicEaser;
	
	
	public class TimeMaster {
		
		// note: the initial starting time is solarTime = 0.5 (this is the value that this component
		// gets reset to when the mode changes)
		// in all modes this is defined to be solar noon on March 20, and also the exact moment of
		// the first vernal equinox
		public const SOLAR_TIME_AT_EPOCH:Number = 0.5;
		
		/**
		* In this mode all years (calendar, sidereal, tropical) are exactly 365 days long.
		*/
		public static const SIMPLE:String = "simple";
		
		/**
		* In this mode the sidereal and tropical years are both exactly 365.25 days long, and
		* the calendar year is either 365 or 366 days long (depending on whether there is a leap
		* year, which occurs every four years).
		*/
		public static const JULIAN:String = "julian";
		
		private var _timer:Timer;
		private var _solarTimeEaser:CubicEaser;
		private var _timerOffset:Number; // used to work around a bug in CubicEaser for large times
		private var _mode:String;
		private var _tropicalYear:Number;		
		private var _siderealPerSolar:Number;
		private var _latestSolarTime:Number;		
		
		public function TimeMaster() {
			
			
			_solarTimeEaser = new CubicEaser(0);
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			mode = TimeMaster.SIMPLE; // also sets time to 0.5
		}
				
		public var responder:ITimeMasterResponder;
		
		
		/**
		* Setting the mode also causes the time to be reset.
		*/
		
		public function get mode():String {
			return _mode;			
		}
		
		public function set mode(arg:String):void {
			if (arg==TimeMaster.SIMPLE) {
				_mode = arg;
				_tropicalYear = 365;
				_siderealPerSolar = (_tropicalYear+1)/_tropicalYear;
			}
			else if (arg==TimeMaster.JULIAN) {
				_mode = arg;				
				_tropicalYear = 365.25;
				_siderealPerSolar = (_tropicalYear+1)/_tropicalYear;
			}
			else {
				throw new Error("mode not supported");
			}
			
			_solarDaysToSummerSolstice = 0.25*_tropicalYear;
			_solarDaysToAutumnalEquinox = 0.5*_tropicalYear;
			_solarDaysToWinterSolstice = 0.75*_tropicalYear;			
			
			if (responder!=null) responder.onTimeMasterModeChanged();
			setSolarTime(SOLAR_TIME_AT_EPOCH);
		}
		
		protected var _solarDaysToSummerSolstice:Number;
		protected var _solarDaysToAutumnalEquinox:Number;
		protected var _solarDaysToWinterSolstice:Number;
		
		/**
		* Indicates whether an animation is currently active.
		*/
		public function get isAnimating():Boolean {
			return _timer.running;			
		}
		
		/**
		* Specifies the tropical year in solar days, which varies depending on mode.
		*/
		public function get tropicalYear():Number {
			return _tropicalYear;
		}
		
		/**
		* This is the ratio of the length of the sidereal day to the solar day.
		*/
		public function get siderealPerSolar():Number {
			return _siderealPerSolar;
		}
				
		/**
		* If an animation is running this is the solar time at the latest animation update. Otherwise, this
		* is identical to solarTime.
		*/
		public function get latestSolarTime():Number {
			if (isAnimating) return _latestSolarTime;
			else return solarTime;
		}
		
		/**
		* Solar time is in decimal days (integers correspond to midnight). If an animation is in progress
		* this will be the target value. Use
		* latestSolarTime for the solar time at the latest animation update. Setting this value directly
		* will be immediate and any ongoing animation will be cancelled. Use setSolarTime or incrementSolarTime
		* to change the value with an animation.
		*/
		public function get solarTime():Number {
			return _solarTimeEaser.targetValue;
		}
		
		public function set solarTime(arg:Number):void {
			setSolarTime(arg);
		}
		
		
		public function timesAreEqual(time1:Number, time2:Number):Boolean {
			return (Math.abs(time1-time2)<1e-6); // a millionth of a day is about a tenth of a second
		}
		
		public function get latestIsAtVernalEquinox():Boolean {
			return (timesAreEqual(latestSolarDaysSinceLastVernalEquinox, 0) 
					|| timesAreEqual(latestSolarDaysSinceLastVernalEquinox-_tropicalYear, 0));
		}
		
		public function get latestIsAtSummerSolstice():Boolean {
			return timesAreEqual(latestSolarDaysSinceLastVernalEquinox, _solarDaysToSummerSolstice);
		}
		
		public function get latestIsAtAutumnalEquinox():Boolean {
			return timesAreEqual(latestSolarDaysSinceLastVernalEquinox, _solarDaysToAutumnalEquinox);
		}
		
		public function get latestIsAtWinterSolstice():Boolean {
			return timesAreEqual(latestSolarDaysSinceLastVernalEquinox, _solarDaysToWinterSolstice);
		}
		
		
		public function get latestIsAt0h():Boolean {
			var t:Number = (latestSiderealTime%1 + 1)%1;
			return (timesAreEqual(t, 0) || timesAreEqual(t-1, 0));
		}
		
		public function get latestIsAt6h():Boolean {
			var t:Number = (latestSiderealTime%1 + 1)%1;
			return timesAreEqual(t, 0.25);
		}
		
		public function get latestIsAt12h():Boolean {
			var t:Number = (latestSiderealTime%1 + 1)%1;
			return timesAreEqual(t, 0.5);
		}
		
		public function get latestIsAt18h():Boolean {
			var t:Number = (latestSiderealTime%1 + 1)%1;
			return timesAreEqual(t, 0.75);
		}
		
		public function get isAt0h():Boolean {
			var t:Number = (siderealTime%1 + 1)%1;
			return (timesAreEqual(t, 0) || timesAreEqual(t-1, 0));
		}
		
		public function get isAt6h():Boolean {
			var t:Number = (siderealTime%1 + 1)%1;
			return timesAreEqual(t, 0.25);
		}
		
		public function get isAt12h():Boolean {
			var t:Number = (siderealTime%1 + 1)%1;
			return timesAreEqual(t, 0.5);
		}
		
		public function get isAt18h():Boolean {
			var t:Number = (siderealTime%1 + 1)%1;
			return timesAreEqual(t, 0.75);
		}
		
		
		
		
		public function get isAtMidnight():Boolean {
			var t:Number = (solarTime%1 + 1)%1;
			return (timesAreEqual(t, 0) || timesAreEqual(t-1, 0));
		}
		
		public function get isAtSunrise():Boolean {
			var t:Number = (solarTime%1 + 1)%1;
			return timesAreEqual(t, 0.25);
		}
		
		public function get isAtNoon():Boolean {
			var t:Number = (solarTime%1 + 1)%1;
			return timesAreEqual(t, 0.5);
		}
		
		public function get isAtSunset():Boolean {
			var t:Number = (solarTime%1 + 1)%1;
			return timesAreEqual(t, 0.75);
		}
		
		public function get latestIsAtMidnight():Boolean {
			var t:Number = (latestSolarTime%1 + 1)%1;
			return (timesAreEqual(t, 0) || timesAreEqual(t-1, 0));
		}
		
		public function get latestIsAtSunrise():Boolean {
			var t:Number = (latestSolarTime%1 + 1)%1;
			return timesAreEqual(t, 0.25);
		}
		
		public function get latestIsAtNoon():Boolean {
			var t:Number = (latestSolarTime%1 + 1)%1;
			return timesAreEqual(t, 0.5);
		}
		
		public function get latestIsAtSunset():Boolean {
			var t:Number = (latestSolarTime%1 + 1)%1;
			return timesAreEqual(t, 0.75);
		}		
		
		public function get isAtVernalEquinox():Boolean {
			return (timesAreEqual(solarDaysSinceLastVernalEquinox, 0) 
					|| timesAreEqual(solarDaysSinceLastVernalEquinox-_tropicalYear, 0));
		}
		
		public function get isAtSummerSolstice():Boolean {
			return timesAreEqual(solarDaysSinceLastVernalEquinox, _solarDaysToSummerSolstice);
		}
		
		public function get isAtAutumnalEquinox():Boolean {
			return timesAreEqual(solarDaysSinceLastVernalEquinox, _solarDaysToAutumnalEquinox);
		}
		
		public function get isAtWinterSolstice():Boolean {
			return timesAreEqual(solarDaysSinceLastVernalEquinox, _solarDaysToWinterSolstice);
		}
		
		
		public function get solarDaysSinceLastVernalEquinox():Number {
			return ((solarTime - SOLAR_TIME_AT_EPOCH)%_tropicalYear + _tropicalYear)%_tropicalYear;
		}
		
		public function get latestSolarDaysSinceLastVernalEquinox():Number {
			return ((latestSolarTime - SOLAR_TIME_AT_EPOCH)%_tropicalYear + _tropicalYear)%_tropicalYear;
		}
		
		public function get siderealDaysSinceLastVernalEquinox():Number {
			return solarDaysSinceLastVernalEquinox*_siderealPerSolar;
		}
		
		public function get latestSiderealDaysSinceLastVernalEquinox():Number {
			return latestSolarDaysSinceLastVernalEquinox*_siderealPerSolar;
		}
		
		/**
		* If an animation is running this is the sidereal time at the latest animation update. Otherwise, this
		* is identical to siderealTime.
		*/
		public function get latestSiderealTime():Number {
			return getSiderealTimeForSolarTime(latestSolarTime);
		}
		
		/**
		* This is the sidereal time in decimal days. If an animation is in progress this is the target value.
		* Use latestSiderealTime for the sidereal time at the latest animation update.
		*/		
		public function get siderealTime():Number {
			return getSiderealTimeForSolarTime(solarTime);
		}

		public function setSolarTime(arg:Number, animationDuration:Number=0):void {
			// this is the function where _solarTime is officially set (all other time changing functions
			// should call this one)
						
			if (animationDuration==0) {
				stopAnimatingWithSolarTime(arg);
			}
			else {				
				if (!_timer.running) {
					// no animation in progress, must start one
					
					_timerOffset = getTimer(); // this is used to get around a bug in CubicEaser
					_timer.start();
					
					_solarTimeEaser.setTarget(0, solarTime, animationDuration, arg)
					_latestSolarTime = solarTime;
					
					if (responder!=null) responder.onTimeMasterAnimationStart();
				}
				else {
					// an animation is in progress, use it
					var t:Number = getTimer() - _timerOffset;
					_solarTimeEaser.setTarget(t, null, t+animationDuration, arg);
				}
			}
		}
		
		public function setSiderealTime(arg:Number, animationDuration:Number=0):void {
			setSolarTime(getSolarTimeForSiderealTime(arg), animationDuration);			
		}
		
		private function stopAnimatingWithSolarTime(solar:Number):void {
			_solarTimeEaser.init(solar);
			_latestSolarTime = solar;
			if (_timer.running) {
				_timer.stop();				
				if (responder!=null) responder.onTimeMasterAnimationStop();
			}
			if (responder!=null) responder.onTimeMasterTimeChanged();
		}		
		
		/**
		* Increments the solar time (which means that if called during an animation it increments
		* the target value, not the latest value).
		*/		
		public function incrementSolarTime(solarTimeDelta:Number, animationDuration:Number=0):void {
			setSolarTime(solarTime + solarTimeDelta, animationDuration);			
		}
		
		/**
		* Increments the sidereal time (which means that if called during an animation it increments
		* the target value, not the latest value).
		*/		
		public function incrementSiderealTime(siderealTimeDelta:Number, animationDuration:Number=0):void {
			setSolarTime(solarTime + siderealTimeDelta/_siderealPerSolar, animationDuration); // correct	
		}
		
		
		
		public function incrementLatestSolarTime(solarTimeDelta:Number, animationDuration:Number=0):void {
			setSolarTime(latestSolarTime + solarTimeDelta, animationDuration);			
		}
		
		public function incrementLatestSiderealTime(siderealTimeDelta:Number, animationDuration:Number=0):void {
			setSolarTime(latestSolarTime + siderealTimeDelta/_siderealPerSolar, animationDuration); // correct
		}
		
		
		/**
		* Returns the sidereal time corresponding to the given solar time. The details of the conversion
		* depend on the mode.
		*/
		public function getSiderealTimeForSolarTime(solar:Number):Number {
			return (solar - SOLAR_TIME_AT_EPOCH)*_siderealPerSolar;
		}
		
		/**
		* Returns the solar time corresponding to the given sidereal time.
		*/		
		public function getSolarTimeForSiderealTime(sidereal:Number):Number {
			return (sidereal/_siderealPerSolar) + SOLAR_TIME_AT_EPOCH;
		}
		
		private function onTimer(evt:TimerEvent):void {
			// called by the animation time function
			var t:Number = getTimer() - _timerOffset;
			if (t>_solarTimeEaser.targetTime) {
				stopAnimatingWithSolarTime(solarTime);
			}
			else {
				_latestSolarTime = _solarTimeEaser.getValue(t);
				if (responder!=null) responder.onTimeMasterAnimationUpdate();
			}
			evt.updateAfterEvent();
		}
		
	}	
}
