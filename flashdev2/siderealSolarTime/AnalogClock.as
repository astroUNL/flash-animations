
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class AnalogClock extends Sprite {
		
		public function AnalogClock() {
			hourHand.rotationChangeHandler = onHourHandRotated;
			minuteHand.rotationChangeHandler = onMinuteHandRotated;
		}		
		
		// onHandsDragged is called when the hands are dragged with a argument
		// that indicates the change in decimal degrees
		public var onHandsDragged:Function;
		
		public function get showAmPmLabels():Boolean {
			return amPmLabels.visible;
		}
		
		public function set showAmPmLabels(arg:Boolean):void {
			amPmLabels.visible = arg;			
		}		
		
		public function onHourHandRotated(deltaInDegrees:Number):void {
			if (onHandsDragged!=null) onHandsDragged(deltaInDegrees/360);
		}
		
		public function onMinuteHandRotated(deltaInDegrees:Number):void {			
			if (onHandsDragged!=null) onHandsDragged(deltaInDegrees/(360*24));
		}		
		
		/**
		* Time is set in days. Only the fractional part is used.
		*/
		public function setTime(arg:Number):void {
			arg = (arg%1 + 1)%1;
			hourHand.rotation = arg*360;
			minuteHand.rotation = ((arg*24)%1)*360;
		}
		
	}
}

