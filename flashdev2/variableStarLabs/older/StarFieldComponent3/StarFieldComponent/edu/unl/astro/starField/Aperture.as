package edu.unl.astro.starField {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.events.Event;
	
	public class Aperture extends Sprite {
		
		private var _boundsRect:Rectangle;
		private var _xOffset:Number;
		private var _yOffset:Number;
		private var _color:uint = 0xff0000;
		private var _radius:uint = 6;
		private const _evt:Event = new Event("moo");
		
		public function Aperture():void {
			//_evt = new Event("moo");
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc);
			drawOutline();
		}
		
		public function setColor(arg:uint):void {
			_color = arg;
			drawOutline();
		}
		
		public function setRadius(arg:uint):void {
			_radius = arg;
			drawOutline();
		}
		
		private function drawOutline():void {
			graphics.clear();
			graphics.lineStyle(1, _color);
			graphics.beginFill(0xff0000, 0);
			graphics.drawCircle(0, 0, _radius);
			graphics.endFill();
		}
		
		public function setBounds(bounds:Rectangle):void {
			_boundsRect = bounds;
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
			
			dispatchEvent(_evt);
		}
	}
}
	