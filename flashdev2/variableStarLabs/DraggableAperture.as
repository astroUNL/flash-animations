﻿
package {

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Point;	
	
	public class DraggableAperture extends Sprite {
		
		// the bounds rectangle limits the range of the aperture; if null, no limits are enforced
		private var _boundsRect:Rectangle;
		
		// the color of the outline
		private var _outlineColor:uint = 0xffcc00;
		
		// the radius controls the size of the aperature
		private var _apertureRadius:uint = 6;
		
		// the x and y offsets are used when dragging
		private var _xOffset:Number;
		private var _yOffset:Number;
		
		
		public function DraggableAperture(...argsList):void {
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc);
			loadSettingsFromObjectsList(argsList);
		}
		
		public function loadSettings(...argsList):void {
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		private function loadSettingsFromObjectsList(objectsList):void {
			var propName:String;
			for each (var item in objectsList) {
				if (item is Object) {
					for (propName in item) this[propName] = item[propName];					
				}
			}
			redrawOutline();
		}
				
		private function onMouseDownFunc(...ignored):void {
			_xOffset = x - parent.mouseX;
			_yOffset = y - parent.mouseY;
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
			parent.setChildIndex(this, parent.numChildren-1);
		}
		
		private function onMouseUpFunc(...ignored):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);			
		}
		
		private function onMouseMoveFunc(evt:MouseEvent):void {
			moveTo(new Point(_xOffset+parent.mouseX, _yOffset+parent.mouseY));
			evt.updateAfterEvent();
		}
		
		public function moveTo(pt:Point):void {
			var nx:Number = pt.x;
			var ny:Number = pt.y;
			
			if (_boundsRect!=null) {
				if (nx<_boundsRect.left) nx = _boundsRect.left;
				else if (nx>_boundsRect.right) nx = _boundsRect.right;
				if (ny<_boundsRect.top) ny = _boundsRect.top;
				else if (ny>_boundsRect.bottom) ny = _boundsRect.bottom;
			}
			
			nx = Math.round(nx);
			ny = Math.round(ny);
			
			if (nx!=x || ny!=y) {
				x = nx;
				y = ny;				
				dispatchEvent(new Event("apertureMoved"));
			}
		}
				
		public function get bounds():Rectangle {
			return _boundsRect.clone();			
		}
	
		public function set bounds(arg:Rectangle):void {
			_boundsRect = arg.clone();
			moveTo(new Point(x, y));
		}
			
		public function get outlineColor():uint {
			return _outlineColor;			
		}
		
		public function set outlineColor(arg:uint):void {
			_outlineColor = arg;
			redrawOutline();
		}		
		
		public function get apertureRadius():uint {
			return _apertureRadius;
		}
		
		public function set apertureRadius(arg:uint):void {
			if (arg==0 || arg>1000) return;
			_apertureRadius = arg;
			redrawOutline();
		}
		
		private function redrawOutline():void {
			// this function draws the outline of the box as well as the invisible 
			// fill that lets the user drag the box around
			graphics.clear();
			graphics.lineStyle(0, _outlineColor, 1);
			graphics.beginFill(0xff0000, 0);
			graphics.drawCircle(0.5, 0.5, _apertureRadius);
			graphics.endFill();
		}
		
	}
	
}
	