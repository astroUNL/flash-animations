
package {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class AnalogClockHand extends MovieClip {
		
		
		public function AnalogClockHand() {
			
			x = y = 0;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc);
		}
		
		public var rotationChangeHandler:Function;
		
		protected var _offset:Number;
		protected var _mouseIsOver:Boolean = false;
		
		protected function onMouseOverFunc(evt:MouseEvent):void {
			_mouseIsOver = true;
			if (!evt.buttonDown) gotoAndStop("mouseOver");
		}
		
		protected function onMouseUpFunc(evt:MouseEvent):void {
			if (_mouseIsOver) gotoAndStop("mouseOver");			
		}
		
		protected function onMouseOutFunc(evt:MouseEvent):void {
			_mouseIsOver = false;
			if (!evt.buttonDown) gotoAndStop("mouseOut");
		}
		
		protected function onMouseDownFunc(evt:MouseEvent):void {
			_offset =  (Math.atan2(parent.mouseY, parent.mouseX)*(180/Math.PI) + 90) - rotation;
			rotationChangeHandler(0);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFunc);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFunc);
		}
		
		protected function onStageMouseMoveFunc(evt:MouseEvent):void {
			var delta:Number = (Math.atan2(parent.mouseY, parent.mouseX)*(180/Math.PI) + 90) - rotation - _offset;
			delta = (delta%360 + 360)%360;
			if (delta>180) delta -= 360;
			if (rotationChangeHandler!=null) rotationChangeHandler(delta);
			evt.updateAfterEvent();
		}
		
		protected function onStageMouseUpFunc(evt:MouseEvent):void {
			if (!_mouseIsOver) gotoAndStop("mouseOut");
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFunc);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFunc);
		}
		
	}	
}

