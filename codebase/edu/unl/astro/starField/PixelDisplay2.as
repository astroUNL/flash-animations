
package edu.unl.astro.starField {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	/*
	import flash.geom.Rectangle;
	import flash.utils.getTimer;*/
	
	
	public class PixelDisplay2 extends Sprite {
		
		
		private var _displayWidth:Number = 100;
		private var _displayHeight:Number = 100;
		
		
		// pixelWidth and pixelHeight refer to the dimensions in the display pixels (not screen pixels),
		// these will be consistent with the dimensions of the 2D array pixelArray, which contains the
		// the colors of the pixels in the display
		private var _pixelWidth:uint = 0;
		private var _pixelHeight:uint = 0;
		private var _pixelArray:Array = null;
		
		private var _displaySP:Sprite;
		private var _activePixelSP:Sprite;
		
		private var _activePixel:Point;
		
		
		public function PixelDisplay2(...argsList):void {
			_activePixel = new Point(-1, -1);
			
			_displaySP = new Sprite();
			addChild(_displaySP);
			
			_activePixelSP = new Sprite();
			addChild(_activePixelSP);
			
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
			
			addEventListener(MouseEvent.ROLL_OVER, onRollOverFunc);
			addEventListener(MouseEvent.ROLL_OUT, onRollOutFunc);
		}
		
		public function loadSettings(...argsList):void {
			loadSettingsFromObjectsList(argsList);
		}
		
		private function loadSettingsFromObjectsList(objectsList):void {
			var propName:String;
			for each (var item in objectsList) {
				if (item is Object) {
					for (propName in item) this[propName] = item[propName];					
				}
			}
			drawPixelOutline();
			redrawDisplay();
		}
		
		private function onRollOverFunc(...ignored):void {
			checkForActivePixelChange();
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
		}		
		
		private function onMouseMoveFunc(evt:MouseEvent):void {
			checkForActivePixelChange();
			evt.updateAfterEvent();
		}
		
		private function onRollOutFunc(...ignored):void {
			checkForActivePixelChange();
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
		}
		
		private function checkForActivePixelChange(...ignored):void {
			var mousePixel:Point = getPixelFromPoint(new Point(mouseX, mouseY));
			if ((mousePixel.x!=_activePixel.x) || (mousePixel.y!=_activePixel.y)) {
				_activePixel = mousePixel;
				drawPixelOutline();				
				dispatchEvent(new Event("activePixelChanged"));
			}			
		}
		
		public function get activePixel():Point {
			return _activePixel.clone();
		}
		
		private function getPixelFromPoint(arg:Point):Point {
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			var px:int = Math.floor(mouseX/xPixelSize);
			var py:int = Math.floor(mouseY/yPixelSize);
					
			/*
			// this commented out block of code would select the pixel nearest to the out of bounds point
			// if it replaced the uncommented bit below it
			if (px<0) px = 0;
			else if (px>=_pixelWidth) px = _pixelWidth-1;
			if (py<0) py = 0;
			else if (py>=_pixelHeight) py = _pixelHeight-1;
			*/
			
			if (px<0 || py<0 || px>=_pixelWidth || py>=_pixelHeight) px = py = -1;
			
			return new Point(px, py);
		}
		
		public function drawPixelOutline(...ignored):void {
			
			_activePixelSP.graphics.clear();
			
			if (_activePixel.x==-1) return;
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			
			var x1:int = xPixelSize*_activePixel.x;
			var x2:int = x1 + xPixelSize;
			var y1:int = yPixelSize*_activePixel.y;
			var y2:int = y1 + yPixelSize;
			
			_activePixelSP.graphics.clear();
			_activePixelSP.graphics.lineStyle(2, 0xffffa000, 1);
			_activePixelSP.graphics.moveTo(x1, y1);
			_activePixelSP.graphics.lineTo(x2, y1);
			_activePixelSP.graphics.lineTo(x2, y2);
			_activePixelSP.graphics.lineTo(x1, y2);
			_activePixelSP.graphics.lineTo(x1, y1);
		}
		
		public function redrawDisplay(...ignored):void {
			_displaySP.graphics.clear();
			
			if (_pixelArray==null) return;
			
			var i:int;
			var j:int;
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			
			for (i=0; i<_pixelWidth; i++) {
				for (j=0; j<_pixelHeight; j++) {
					_displaySP.graphics.beginFill(0x00ffffff & _pixelArray[i][j]);
					_displaySP.graphics.drawRect(i*xPixelSize, j*yPixelSize, xPixelSize, yPixelSize);					
					_displaySP.graphics.endFill();
				}
			}			
		}
		
		public function set pixelArray(arg:Array):void {
			if (!(arg is Array) || arg.length==0) {
				trace("error setting pixelArray, type 1: argument must be non-empty array");
				return;
			}
			
			var w:uint = arg.length;
			
			if (!(arg[0] is Array) || arg[0].length==0) {
				trace("error setting pixelArray, type 2: argument must be non-empty 2D array");
				return;
			}
			
			var h:uint = arg[0].length;
						
			var c:uint;
			var i:int;
			var j:int;
			
			var newArray:Array = [];
			
			for (i=0; i<w; i++) {
				if (!(arg[i] is Array) || arg[i].length!=h) {
					trace("error setting pixelArray, type 3: varying dimensions or invalid types in array");
					return;
				}
				
				newArray[i] = [];
				
				for (j=0; j<h; j++) newArray[i][j] = uint(arg[i][j]);
			}
			
			_pixelWidth = w;
			_pixelHeight = h;
			_pixelArray = newArray;
			
			redrawDisplay();
		}
		
		public function get displaySize():Number {
			return _displayWidth;
		}
		
		public function set displaySize(arg:Number):void {
			if (arg<=0 || arg>1000) return;
			_displayWidth = arg;
			_displayHeight = arg;
		}
				
		public function get displayWidth():Number {
			return _displayHeight;
		}
		
		public function set displayWidth(arg:Number):void {
			if (arg<=0 || arg>1000) return;
			_displayWidth = arg;	
		}
		
		public function get displayHeight():Number {
			return _displayHeight;
		}
		
		public function set displayHeight(arg:Number):void {
			if (arg<=0 || arg>1000) return;
			_displayHeight = arg;	
		}
		
	}
	
}

	