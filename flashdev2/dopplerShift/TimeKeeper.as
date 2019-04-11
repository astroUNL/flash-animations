
package {
	
	import flash.utils.getTimer;
	
	public class TimeKeeper {
		
		protected static var _offset:Number = 0;
		protected static var _isStopped:Boolean = false;
		protected static var _stoppedTime:Number = 0;
		protected static var _rate:Number = 1;
		
		public function TimeKeeper() {
			trace("use the static");		
		}
		
		public static function get rate():Number {
			return _rate;
		}
		
		public static function set rate(newRate:Number):void {
			var timerNow:Number = getTimer();
			var timeNow:Number = (_isStopped) ? _stoppedTime : _rate*timerNow + _offset;
			_rate = newRate;
			calcOffset(timeNow, timerNow);
		}
		
		protected static function calcOffset(time:Number, timer:Number):void {
			_offset = time - _rate*timer;			
		}
		
		public static function start():void {
			if (_isStopped) calcOffset(_stoppedTime, getTimer());
			_isStopped = false;
		}
		
		public static function stop():void {
			_stoppedTime = TimeKeeper.getTime();
			_isStopped = true;
		}
		
		public static function get running():Boolean {
			return !_isStopped;
		}
		
		public static function set running(arg:Boolean):void {
			if (arg && _isStopped) start();
			else if (!arg && !_isStopped) stop();			
		}
		
		public static function getTime():Number {
			if (_isStopped) return _stoppedTime;
			else return _rate*getTimer() + _offset;		
		}
	}
	
}

