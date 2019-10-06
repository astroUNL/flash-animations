
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	
	public class StarDisc extends Sprite {
		
		// _dataObj is the object that contains 
		private var _dataObj:Object;
		
		// these offsets used when dragging
		private var _xOffset:Number;
		private var _yOffset:Number;
		
		private var _mouseOver:Boolean = false;
		private var _selected:Boolean = false;
		
		public function StarDisc(dataObj):void {
			
			_dataObj = dataObj;		
			
			x = _dataObj.x;
			y = _dataObj.y;
			
			addEventListener(flash.events.MouseEvent.MOUSE_OVER, onMouseRollOverFunc);
			addEventListener(flash.events.MouseEvent.MOUSE_OUT, onMouseRollOutFunc);
			addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDownFunc);
			
			updateAppearance();			
		}
		
		private function onMouseRollOverFunc(...ignored):void {
			_mouseOver = true;
			
			updateAppearance();
		}
		
		private function onMouseRollOutFunc(...ignored):void {
			_mouseOver = false;
			
			updateAppearance();
		}
		
		private function onMouseDownFunc(...ignored):void {
			_xOffset = x - parent.mouseX;
			_yOffset = y - parent.mouseY;
			
			if ((root as Object).deleteIsDown) {
				// remove the star
				
				(root as Object).removeStar(_dataObj);
			}
			else {
				// drag the star (select it first)
				
				(root as Object).selectStar(_dataObj);
				
				stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUpFunc);
				stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
			}
		}
		
		private function onMouseUpFunc(...ignored):void {
			stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUpFunc);
			stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
		}
		
		private function onMouseMoveFunc(evt:MouseEvent):void {
			x = _dataObj.star.x = _dataObj.x = int(parent.mouseX + _xOffset);
			y = _dataObj.star.y = _dataObj.y = int(parent.mouseY + _yOffset);
			
			(root as Object).starsListDP.invalidateItem(_dataObj);
			
			evt.updateAfterEvent();
		}
		
		public function bringToFront():void {
			parent.setChildIndex(this, parent.numChildren-1);
		}
		
		public function select():void {
			bringToFront();
			_selected = true;
			updateAppearance();
		}
		
		public function deselect():void {
			_selected = false;
			updateAppearance();
		}
		
		public function updateAppearance():void {
			
			var lineThickness:Number = 1;
			var lineAlpha:Number = 0;
			
			if (_selected || _mouseOver) {
				lineThickness = 1;
				lineAlpha = 100;
			}
			
			var lineColor:uint;
			var fillColor:uint = 0xff0000;
			
			var circleRadius:int = 8;
			
			if (_dataObj.type=="constant star") lineColor = 0xffaaaa;
			else if (_dataObj.type=="pulsating star") lineColor = 0xaaffaa;
			else if (_dataObj.type=="eclipsing binary") lineColor = 0xaaaaff;
			
			graphics.clear();
			graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			graphics.beginFill(fillColor, 0);
			graphics.drawCircle(0.5, 0.5, circleRadius);
			graphics.endFill();			
		}		
		
		public function updatePosition():void {
			x = _dataObj.x;
			y = _dataObj.y;
		}
		
	}
	
}
