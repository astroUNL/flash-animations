
package {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class SHZTimelineCursor extends MovieClip {
		
		protected var _minX:Number;
		protected var _maxX:Number;
		protected var _offsetX:Number;
		protected var _timeline:SHZTimeline;
		
		public function SHZTimelineCursor(minX:Number, maxX:Number, timeline:SHZTimeline) {
			_minX = minX;
			_maxX = maxX;
			
			_timeline = timeline;
			
			focusRect = false;
			addEventListener("addedToStage", onAddedToStage);
			addEventListener("focusOut", onFocusOut);
		}
		
		protected function onAddedToStage(...ignored):void {
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		protected function onMouseOver(...ignored):void {
			gotoAndStop(2);
		}
		
		protected function onMouseOut(...ignored):void {
			gotoAndStop(1);
		}
		
		protected function onMouseDown(...ignored):void {			
			stage.focus = this;
			addEventListener("keyDown", onKeyDown);
			
			_offsetX = parent.mouseX - x;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseUp(...ignored):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		protected function onMouseMove(evt:MouseEvent):void {
			var newX:Number = parent.mouseX - _offsetX;
			if (newX<_minX) newX = _minX;
			else if (newX>_maxX) newX = _maxX;
			x = newX;
			dispatchEvent(new Event("cursorDragged"));
			evt.updateAfterEvent();
		}
		
		protected function onFocusOut(...ignored):void {
			removeEventListener("keyDown", onKeyDown);
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.LEFT) {				
				_timeline.increment(-1);
			}
			else if (evt.keyCode==Keyboard.RIGHT) {
				_timeline.increment(1);
			}
		}
		
	}		
}
