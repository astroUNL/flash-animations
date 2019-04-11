
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	public class DayOfYearSlider extends Sprite {
		
		
		private const barWidth:Number = 390;
		
		public function DayOfYearSlider() {
			
			buttonMode = true;
			tabEnabled = false;
			useHandCursor = true;
			


			setThumbActive(false);
			
			bar.addEventListener(MouseEvent.MOUSE_DOWN, onBarMouseDown);
			
			thumb.addEventListener(MouseEvent.MOUSE_OVER, onThumbMouseOver);
			thumb.addEventListener(MouseEvent.MOUSE_UP, onThumbMouseUp);
			thumb.addEventListener(MouseEvent.MOUSE_OUT, onThumbMouseOut);
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbMouseDown);
		}
		
		public var onThumbDragged:Function;
		public var tropicalYear:Number;
		
		protected var _thumbOffset:Number;		
		protected var _mouseIsOverThumb:Boolean = false;
		protected var _mouseIsDownOnThumb:Boolean = false;
		
		protected function setThumbActive(arg:Boolean):void {
			thumb.gotoAndStop((arg) ? "mouseOver" : "mouseOut");
		}
		
		protected function onThumbMouseOver(evt:MouseEvent):void {
			_mouseIsOverThumb = true;
			if (!_mouseIsDownOnThumb) setThumbActive(true);
		}
		
		protected function onThumbMouseUp(evt:MouseEvent):void {
			_mouseIsDownOnThumb = false;
			if (_mouseIsOverThumb) setThumbActive(true);		
		}
		
		protected function onThumbMouseOut(evt:MouseEvent):void {
//			trace("on thumb mouse out");
			_mouseIsOverThumb = false;
			if (!_mouseIsDownOnThumb) setThumbActive(false);
		}
		
		protected function onThumbMouseDown(evt:MouseEvent):void {
			_mouseIsDownOnThumb = true;
			onThumbDragged(0); // stops any animation
			_thumbOffset = mouseX - thumb.x;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveForThumb);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpForThumb);
		}
		
		protected function onStageMouseMoveForThumb(evt:MouseEvent):void {			
			var deltaPx:Number = (mouseX - thumb.x) - _thumbOffset;
			deltaPx = (deltaPx%barWidth + barWidth)%barWidth;
			if (deltaPx>(barWidth/2)) deltaPx -= barWidth;
			var timeDelta:Number = (tropicalYear/barWidth)*deltaPx;
			if (onThumbDragged!=null) onThumbDragged(timeDelta);
			evt.updateAfterEvent();
		}
		
		protected function onStageMouseUpForThumb(evt:MouseEvent):void {
			_mouseIsDownOnThumb = false;
			if (!_mouseIsOverThumb) setThumbActive(false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveForThumb);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpForThumb);
		}
		
		protected function onBarMouseDown(evt:MouseEvent):void {
			if (onThumbDragged!=null) onThumbDragged(0); // stops any animation
			
			var timeDelta:Number = 0;
			if (mouseX<thumb.x) timeDelta = -1;
			else if (mouseX>thumb.x) timeDelta = 1;
			
			if (onThumbDragged!=null) onThumbDragged(timeDelta);
		}
		
		public function setTime(solarDaysSinceLastVernalEquinox:Number):void {
			thumb.x = barWidth*(((solarDaysSinceLastVernalEquinox/tropicalYear)%1 + 1)%1);
		}
		
	}
}

