
package {
	
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	
	import flash.utils.getTimer;
		
	public class PixelDisplay extends Sprite {
		
		// the display width and height are dimensions of the display in screen pixels
		private var _displayWidth:Number = 100;
		private var _displayHeight:Number = 100;		
		
		// pixelWidth and pixelHeight refer to the dimensions in the display pixels (not screen pixels),
		// these will be consistent with the dimensions of the 2D array pixelArray, which contains the
		// the colors of the pixels in the display
		private var _pixelWidth:uint = 0;
		private var _pixelHeight:uint = 0;
		private var _pixelArray:Array = null;
		
		// the active pixel is the pixel in the display with a box around it
		// x and y properties are both -1 if outside the range defined by _pixelWidth and _pixelHeight
		private var _activePixel:Point;
		
		// these properties are needed to keep track of the mouse states
		private var _mouseIsDown:Boolean = false;
		private var _mouseIsOver:Boolean = false;		
				
		private var _displaySP:Sprite;
		private var _customMarkingsSP:Sprite;
		private var _customMarkingsMaskSP:Sprite;
		private var _activePixelSP:Sprite;		
		private var _focusRectSP:Sprite;
		
		// redrawBackground has to be called after changing the focus rectangle properties
		public var focusRectMargin:Number = 5;
		public var focusRectLineThickness:Number = 3;
		public var focusRectLineColor:uint = 0x9090ff;
		
		// drawPixelOutline has to be called after changing these properties
		public var activePixelOutlineThickness:Number = 2;
		public var activePixelOutlineColor:uint = 0x9090ff;
		
		public function PixelDisplay(...argsList):void {
			_activePixel = new Point(-1, -1);
			
			_displaySP = new Sprite();
			addChild(_displaySP);
			
			_customMarkingsSP = new Sprite();
			addChild(_customMarkingsSP);
			
			_customMarkingsMaskSP = new Sprite();
			addChild(_customMarkingsMaskSP);
			
			_activePixelSP = new Sprite();
			addChild(_activePixelSP);
			
			_focusRectSP = new Sprite();
			addChild(_focusRectSP);
			
			_customMarkingsSP.mask = _customMarkingsMaskSP;
			
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
			
			tabEnabled = false;
			tabChildren = false;
			mouseChildren = false;
			focusRect = {};
			_focusRectSP.visible = false;
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
			checkMouseForActivePixelChange();
			redrawDisplay();
		}
		
		// how focus is gained
		//  - rollover while mouse button is up
		//  - rollover with mouse button down and nothing else in focus
		//  - mouse button release while over
		//  - keyboard focus navigation (tabbing)
		
		// - the focus rectangle is shown only when the focus was selected via keyboard navigation		
		
		// how focus is lost
		//  - mouse moves off the display area
		//  - keyboard focus navigation (tabbing)
		
		public function get enabled():Boolean {
			return tabEnabled;
		}
		
		public function set enabled(arg:Boolean):void {
			if (!tabEnabled && arg) {
				// transition to enabled
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				addEventListener(MouseEvent.ROLL_OVER, onDisplayRollOver);
				addEventListener(MouseEvent.ROLL_OUT, onDisplayRollOut);
				addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChanged);
			}
			else if (tabEnabled && !arg) {
				// transition to disabled
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				removeEventListener(MouseEvent.ROLL_OVER, onDisplayRollOver);
				removeEventListener(MouseEvent.ROLL_OUT, onDisplayRollOut);
				removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChanged);
			}
			tabEnabled = arg;
		}
		
		private function onStageMouseDown(...ignored):void {
			_mouseIsDown = true;			
		}
		
		private function onStageMouseUp(...ignored):void {
			_mouseIsDown = false;
			if (stage.focus!=this && _mouseIsOver) {
				// releasing the mouse button while over the display causes it to receive focus
				checkMouseForActivePixelChange();
				stage.focus = this;
			}
		}
		
		private function onDisplayRollOver(...ignored):void {
			_mouseIsOver = true;
			if (!_mouseIsDown) {
				// rolling over while the mouse button is up gives focus
				checkMouseForActivePixelChange();
				stage.focus = this;
			}
			else if (stage.focus==null) {
				// rolling over with the mouse button down but nothing else in focus brings also give focus
				checkMouseForActivePixelChange();
				stage.focus = this;
			}
		}		
		
		private function onDisplayRollOut(...ignored):void {
			_mouseIsOver = false;			
			if (stage.focus==this) {
				// rolling out removes focus
				stage.focus = null;				
			}
		}
		
		private function onFocusIn(...ignored):void {
			if (_activePixel.x==-1) {
				// this is how we tell if the focus was done by tabbing, since the other methods would have set the
				// active pixel to something else (and the active pixel is always <-1, -1> when out of focus)
				
				// put the active pixel in the center of the display window
				activePixel = new Point(int(_pixelWidth/2), int(_pixelHeight/2));
				
				// show the focus box
				_focusRectSP.visible = true;
			}
			stage.addEventListener("keyDown", onStageKeyDownFunc);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFunc);
		}
		
		private function onFocusOut(evt:FocusEvent):void {
			// set the active pixel to <-1, -1>
			clearActivePixel();
			// hide the focus box (it may not have been visible anyway)
			_focusRectSP.visible = false;
			stage.removeEventListener("keyDown", onStageKeyDownFunc);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFunc);
		}	
		
		private function onKeyFocusChanged(evt:FocusEvent):void {
			// this function is needed to prevent the focus from being changed by the arrow keys
			if (evt.keyCode>=37 && evt.keyCode<=40) evt.preventDefault();
		}
		
		private function onStageKeyDownFunc(evt:KeyboardEvent):void {
			// this function moves the active pixel when the arrow keys are pressed
			if (evt.keyCode==37) {
				// left arrow
				activePixel = new Point(_activePixel.x-1, _activePixel.y);
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==38) {
				// up arrow
				activePixel = new Point(_activePixel.x, _activePixel.y-1);
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==39) {
				// right arrow
				activePixel = new Point(_activePixel.x+1, _activePixel.y);
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==40) {
				// bottom arrow
				activePixel = new Point(_activePixel.x, _activePixel.y+1);
				evt.updateAfterEvent();
			}
		}
				
		private function onStageMouseMoveFunc(evt:MouseEvent):void {
			// this function moves the active pixel when the mouse moves
			checkMouseForActivePixelChange();
			evt.updateAfterEvent();
		}
		
		private function checkMouseForActivePixelChange(...ignored):void {
			// this function checks whether the position of the mouse is associated with a different
			// pixel than the current active pixel, and updates the active pixel if that's the case
			// and if the mouse pixel is within bounds
			var mousePixel:Point = getPixelFromMouseLocation();
			if (mousePixel.x!=-1 && ((mousePixel.x!=_activePixel.x) || (mousePixel.y!=_activePixel.y))) activePixel = mousePixel;
		}
		
		private function getPixelFromMouseLocation():Point {
			// this function returns the pixel value associated with the current mouse position;
			// if the mouse is outside the display window the function returns the point <-1, -1>
			
			// note that we need to take into account the fact that if the mouse is exactly at
			// the right or bottom edge it will appear to be in the next pixel outside of the bounds
			// even though we want to consider it as inside the bounds
			var px:int = (mouseX==_displayWidth) ? _pixelWidth-1 : int(mouseX/xPixelSize);
			var py:int = (mouseY==_displayHeight) ? _pixelHeight-1 : int(mouseY/yPixelSize);
			
			// check for bounds
			if (px<0 || px>=_pixelWidth || py<0 || py>=_pixelHeight) {
				px = -1;
				py = -1;
			}																	
			
			return new Point(px, py);
		}
		
		public function get activePixel():Point {
			return _activePixel.clone();
		}
		
		public function set activePixel(px:Point):void {
			// this function is used to set the active pixel; the pixel outline is is redrawn and
			// the activePixelChanged event is dispatched (even if the pixel value remains the same);
			// use <-1, -1> to deselect the active pixel, otherwise any out of bounds pixel value
			// will be brought back in bounds
			
			var ax:Number = px.x;
			var ay:Number = px.y;
			
			if (!isFinite(ax) || !isFinite(ay) || isNaN(ax) || isNaN(ay)) return;
			
			// assuming the new pixel is not <-1, -1> (deselection), bring the pixel value in bounds
			if (!(ax==-1 && ay==-1)) {
				if (ax<0) ax = 0;
				else if (ax>=_pixelWidth) ax = _pixelWidth-1;
				if (ay<0) ay = 0;
				else if (ay>=_pixelHeight) ay = _pixelHeight-1;
			}
			
			// make sure the pixel is an integral
			_activePixel.x = int(ax);
			_activePixel.y = int(ay);
			
			drawPixelOutline();
			dispatchEvent(new Event("activePixelChanged"));
		}
		
		public function clearActivePixel():void {
			activePixel = new Point(-1, -1);
		}
		
		public function drawPixelOutline(...ignored):void {
			// this function is responsible for drawing the outline around the active pixel
			
			_activePixelSP.graphics.clear();
			
			if (_activePixel.x==-1) return;
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			
			_activePixelSP.graphics.lineStyle(activePixelOutlineThickness, activePixelOutlineColor, 1);
			_activePixelSP.graphics.drawRect(xPixelSize*_activePixel.x, yPixelSize*_activePixel.y, xPixelSize, yPixelSize);
		}
		
		public function redrawDisplay(...ignored):void {
			// this function redraws the pixel display to show the current values in pixelArray
			
			_displaySP.graphics.clear();
			
			if (_pixelArray==null) return;
			
			var i:int;
			var j:int;
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			
			var alpha:Number;
			
			for (i=0; i<_pixelWidth; i++) {
				for (j=0; j<_pixelHeight; j++) {
					// siphon off the alpha value from the uint and use it for the fill
					alpha = 1 - (((_pixelArray[i][j] & 0xff000000) >> 24) & 0x000000ff)/0xff;
					_displaySP.graphics.beginFill(0x00ffffff & _pixelArray[i][j], alpha);
					_displaySP.graphics.drawRect(i*xPixelSize, j*yPixelSize, xPixelSize, yPixelSize);					
					_displaySP.graphics.endFill();
				}
			}			
		}
		
		public function set pixelArray(arg:Array):void {
			// use this function to set the pixel array, which should be a 2D array
			// of colors; the display is automatically redrawn after the data is loaded
			
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
		
		// the pixel sizes (the size of an enlarged pixel) are read-only, being contingent
		// on the display size and the number of pixels in the array
		
		public function get xPixelSize():Number {
			return _displayWidth/_pixelWidth;
		}
		
		public function get yPixelSize():Number {
			return _displayHeight/_pixelHeight;
		}
		
		public function get displaySize():Number {
			return _displayWidth;
		}
		
		public function set displaySize(arg:Number):void {
			if (arg<=0 || arg>1000) return;
			_displayWidth = arg;
			_displayHeight = arg;
			redrawBackground();
		}
				
		public function get displayWidth():Number {
			return _displayHeight;
		}
		
		public function set displayWidth(arg:Number):void {
			if (arg<=0 || arg>1000) return;
			_displayWidth = arg;
			redrawBackground();
		}
		
		public function get displayHeight():Number {
			return _displayHeight;
		}
		
		public function set displayHeight(arg:Number):void {
			if (arg<=0 || arg>1000) return;
			_displayHeight = arg;
			redrawBackground();
		}
		
		public function redrawBackground():void {
			// this function draws the background (which consists of a checkered pattern)
			// the focus rectangle, and the custom markings mask
			
			// first draw the checkered background
			
			var bmd:BitmapData = new BitmapData(4, 4);
			bmd.setPixel(0, 0, 0xa0a0a0);
			bmd.setPixel(0, 1, 0xa0a0a0);
			bmd.setPixel(1, 0, 0xa0a0a0);
			bmd.setPixel(1, 1, 0xa0a0a0);
			
			bmd.setPixel(2, 2, 0xa0a0a0);
			bmd.setPixel(2, 3, 0xa0a0a0);
			bmd.setPixel(3, 2, 0xa0a0a0);
			bmd.setPixel(3, 3, 0xa0a0a0);
			
			bmd.setPixel(2, 0, 0xdadada);
			bmd.setPixel(2, 1, 0xdadada);
			bmd.setPixel(3, 0, 0xdadada);
			bmd.setPixel(3, 1, 0xdadada);
			
			bmd.setPixel(0, 2, 0xdadada);
			bmd.setPixel(1, 2, 0xdadada);
			bmd.setPixel(0, 3, 0xdadada);
			bmd.setPixel(1, 3, 0xdadada);
			
			graphics.clear();
			graphics.beginBitmapFill(bmd);
			graphics.drawRect(0, 0, _displayWidth, _displayHeight);
			graphics.endFill();
			
			// now draw the mask for the custom markings
			_customMarkingsMaskSP.graphics.clear();
			_customMarkingsMaskSP.graphics.beginFill(0xff0000, 1);
			_customMarkingsMaskSP.graphics.drawRect(0, 0, _displayWidth, _displayHeight);
			_customMarkingsMaskSP.graphics.endFill();		
			
			// now draw the focus rectangle
			var m:Number = focusRectMargin;
			_focusRectSP.graphics.clear();
			_focusRectSP.graphics.lineStyle(focusRectLineThickness, focusRectLineColor);
			_focusRectSP.graphics.drawRect(-m, -m, _displayWidth+2*m, _displayHeight+2*m);
		}
		
		public function clearCustomMarkings(...ignored):void {
			_customMarkingsSP.graphics.clear();
		}
		
		public function addCustomMarking(params:Object):void {
			// custom markings are a way to draw special features on the pixel display, like the
			// aperture mask outlines
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			
			var i:int;
			var px:Number;
			var py:Number;
			
			var doDrawing:Boolean = false;
			var ptList:Array = [];
			
			if (params.pointsList is Array) {
				var xOffset:Number = (params.xOffset is Number) ? params.xOffset : 0;
				var yOffset:Number = (params.yOffset is Number) ? params.yOffset : 0;
				for (i=0; i<params.pointsList.length; i++) {
					px = params.pointsList[i].x + xOffset;
					py = params.pointsList[i].y + yOffset;
					ptList.push({x: px, y: py});					
					if (px>=0 && py>=0 && px<=_pixelWidth && py<=_pixelHeight) doDrawing = true;
				}
			}
			
			if (doDrawing) {
				if (params.lineStyle is Object) _customMarkingsSP.graphics.lineStyle(params.lineStyle.thickness,
																					  params.lineStyle.color,
																					  params.lineStyle.alpha);
				if (params.fillStyle is Object) _customMarkingsSP.graphics.beginFill(params.fillStyle.color,
																					  params.fillStyle.alpha);
				_customMarkingsSP.graphics.moveTo(xPixelSize*ptList[0].x, yPixelSize*ptList[0].y);
				for (i=1; i<ptList.length; i++) _customMarkingsSP.graphics.lineTo(xPixelSize*ptList[i].x, yPixelSize*ptList[i].y);
				if (params.fillStyle is Object) _customMarkingsSP.graphics.endFill();
			}
		}
		
	}
	
}
