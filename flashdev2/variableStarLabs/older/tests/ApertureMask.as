package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class ApertureMask extends Sprite {
		
		private var _boundsRect:Rectangle;
		private var _xOffset:Number;
		private var _yOffset:Number;
		private var _starField:StarField;
		
		public function ApertureMask():void {			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc);
			graphics.beginFill(0xff0000*Math.random());
			graphics.drawCircle(0, 0, 6);
			graphics.endFill();		
		}
		
		public function linkToStarField(sf:StarField):void {
			_starField = sf;
			_boundsRect = new Rectangle(sf.x, sf.y, sf.width, sf.height);
		}		
		
		private function onMouseDownFunc(event:MouseEvent):void {
			_xOffset = x - parent.mouseX;
			_yOffset = y - parent.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
			parent.setChildIndex(this, parent.numChildren-1);
		}
		
		private function onMouseUpFunc(event:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);			
		}
		
		private function onMouseMoveFunc(event:MouseEvent):void {
			var newX:Number = _xOffset + parent.mouseX;
			if (newX<_boundsRect.left) newX = _boundsRect.left;
			else if (newX>_boundsRect.right) newX = _boundsRect.right;
			var newY:Number = _yOffset + parent.mouseY;
			if (newY<_boundsRect.top) newY = _boundsRect.top;
			else if (newY>_boundsRect.bottom) newY = _boundsRect.bottom;
			x = newX;
			y = newY;
			event.updateAfterEvent();
		}
	}
}
	