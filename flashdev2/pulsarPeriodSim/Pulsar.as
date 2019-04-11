
package {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Pulsar extends MovieClip {
		
		public function Pulsar() {
			
			
//			addEventListener("mouseDown", onMouseDownFunc);
//			
//			addEventListener("enterFrame", onEnterFrameFunc);
			
		}
		
		public function onMouseDownFunc(...ignored):void {
			_dragOffsetX = parent.mouseX - x;
			_dragOffsetY = parent.mouseY - y;
			stage.addEventListener("mouseMove", onMouseMoveFunc);
			stage.addEventListener("mouseUp", onMouseUpFunc);
		}
		
		
		protected var _dragOffsetX:Number;
		protected var _dragOffsetY:Number;
		
		public function onMouseMoveFunc(evt:MouseEvent):void {
			x = parent.mouseX - _dragOffsetX;
			y = parent.mouseY - _dragOffsetY;
			
			evt.updateAfterEvent();			
		}
		
		public function onMouseUpFunc(...ignored):void {
			
			stage.removeEventListener("mouseMove", onMouseMoveFunc);
			stage.removeEventListener("mouseUp", onMouseUpFunc);
		}
		
		public function onEnterFrameFunc(...ignored):void {
			rotation += 16;
			
			
		}
		
	}
	
}
