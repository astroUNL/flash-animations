
package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class PixelDisplay extends Sprite {
		
		private var _width:uint;
		private var _height:uint;
		private var _pixelArray:Array;
		private var _pixelSize:uint;
		
		private var _overlay:Sprite;
		
		public function PixelDisplay(w:uint, h:uint, s:uint):void {
			_width = w;
			_height = h;
			_pixelSize = s;
			_pixelArray = [];	
			
			_overlay = new Sprite();
			
			addChild(_overlay);
			
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc);
		}
		
		private function onMouseOverFunc(...ignored):void {
			drawPixelOutline();						
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
			dispatchEvent(new Event("needToDisplayInfo"));
		}
		
		private function onMouseMoveFunc(event:MouseEvent):void {
			drawPixelOutline();
			dispatchEvent(new Event("needToDisplayInfo"));
			
			event.updateAfterEvent();
		}
		
		private function drawPixelOutline():void {
			var i:int = mouseX/_pixelSize;
			var j:int = mouseY/_pixelSize;
			var x1:int = _pixelSize*i;
			var x2:int = x1 + _pixelSize;
			var y1:int = _pixelSize*j;
			var y2:int = y1 + _pixelSize;
			
				
			_overlay.graphics.clear();
			_overlay.graphics.lineStyle(2, 0xff00ccff);
			_overlay.graphics.moveTo(x1, y1);
			_overlay.graphics.lineTo(x2, y1);
			_overlay.graphics.lineTo(x2, y2);
			_overlay.graphics.lineTo(x1, y2);
			_overlay.graphics.lineTo(x1, y1);
		}
		
		public function getRelativePixelCoordinate():Object {
			var obj:Object = {};
			obj.x = int(mouseX/_pixelSize);
			obj.y = int(mouseY/_pixelSize);
			if (obj.x<0 || obj.x>_width || obj.y<0 || obj.y>_height) {
				obj.x = null;
				obj.y = null;
			}
			return obj;
		}
		
		private function onMouseOutFunc(...ignored):void {
			_overlay.graphics.clear();
			dispatchEvent(new Event("needToDisplayInfo"));
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
		}
		
		/*
		private var _starField:StarField;
		public function linkToStarField(sf:StarField):void {
			_starField = sf;
		}
		*/
		
		
		public function setPixelSize(s:uint):void {
			_pixelSize = s;
			update();			
		}
		
		public function setPixelDimensions(w:uint, h:uint):void {
			_width = w;
			_height = h;
			update();			
		}
		
		public function setPixels(arr:Array):void {
			_pixelArray = arr;
			update();
		}
		
		private function update():void {
			graphics.clear();
			
			if (_pixelArray.length==0) return;
			
			var startTimer:Number = getTimer();
			
			var i:int;
			var j:int;
			
			var x1:int;
			var x2:int;
			var y1:int;
			var y2:int;
			
			for (i=0; i<_width; i++) {
				x1 = _pixelSize*i;
				x2 = x1 + _pixelSize;
				for (j=0; j<_height; j++) {
					y1 = _pixelSize*j;
					y2 = y1 + _pixelSize;
					graphics.moveTo(x1, y1);
					graphics.beginFill(0x00ffffff & _pixelArray[i][j]);
					graphics.lineTo(x2, y1);
					graphics.lineTo(x2, y2);
					graphics.lineTo(x1, y2);
					graphics.lineTo(x1, y1);
					graphics.endFill();
				}
			}
			
			//trace("update pixel display: "+(getTimer()-startTimer));
		}
	}
	
}

