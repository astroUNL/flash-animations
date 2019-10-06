
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
		
				
		private var _backgroundSP:Sprite;
		private var _displaySP:Sprite;
		private var _customMarkingsSP:Sprite;
		private var _customMarkingsMaskSP:Sprite;
		private var _activePixelSP:Sprite;		
		
		public function PixelDisplay(...argsList):void {
			_activePixel = new Point(-1, -1);
			
			_backgroundSP = new Sprite();
			addChild(_backgroundSP);
			
			_displaySP = new Sprite();
			addChild(_displaySP);
			
			_customMarkingsSP = new Sprite();
			addChild(_customMarkingsSP);
			
			_customMarkingsMaskSP = new Sprite();
			addChild(_customMarkingsMaskSP);
			
			_activePixelSP = new Sprite();
			addChild(_activePixelSP);
			
			_customMarkingsSP.mask = _customMarkingsMaskSP;
			
			tabChildren = false;
			mouseChildren = false;
			
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
			
			enabled = true;
		}
		
		private var _enabled:Boolean = false;
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(arg:Boolean):void {
			if (!_enabled && arg) {
				// transition to enabled
				addEventListener(MouseEvent.ROLL_OVER, onRollOverFunc);
				addEventListener(MouseEvent.ROLL_OUT, onRollOutFunc);
				
				addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChanged);
				addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onMouseFocusChanged);
				tabEnabled = true;
			}
			else if (_enabled && !arg) {
				// transition to disabled
				removeEventListener(MouseEvent.ROLL_OVER, onRollOverFunc);
				removeEventListener(MouseEvent.ROLL_OUT, onRollOutFunc);
				
				removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChanged);
				removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onMouseFocusChanged);
				tabEnabled = false;
			}
			_enabled = arg;
		}
		
		private function onFocusIn(...ignored):void {
			if (_activePixel.x==-1) {
				setActivePixel(new Point(int(_pixelWidth/2), int(_pixelHeight/2)));
				
			}
			stage.addEventListener("keyDown", onKeyDownFunc);
			trace("onFocusIn, "+this.name);
		}
		
		private function onFocusOut(evt:FocusEvent):void {
			clearActivePixel();
			stage.removeEventListener("keyDown", onKeyDownFunc);
			trace("onFocusOut, "+this.name);
			trace(" going to: "+evt.relatedObject);
		}	
		
		
		public function onKeyFocusChanged(evt:FocusEvent):void {
			trace("onKeyFocusChanged, "+this.name);
			trace(" keyCode: "+evt.keyCode);
			
			
			
			// don't allow the focus to be changed by the arrow keys
			if (evt.keyCode>=37 && evt.keyCode<=40) evt.preventDefault();
		}
		
		public function onMouseFocusChanged(evt:FocusEvent):void {
			trace("onMouseFocusChanged, "+this.name);
			trace(" relatedObject: "+evt.relatedObject.name);
			trace(" target: "+evt.target.name);
			trace(" currentTarget: "+evt.currentTarget.name);
			evt.relatedObject.visible = false;
		}
				
		public function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==37) {
				trace("left arrow down, "+this.name);
				// left arrow
				setActivePixel(new Point(_activePixel.x-1, _activePixel.y));
			//	moveTo(new Point(x-1, y));
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==38) {
				trace("up arrow down, "+this.name);
				setActivePixel(new Point(_activePixel.x, _activePixel.y-1));
				// up arrow
				//moveTo(new Point(x, y-1));
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==39) {
				trace("right arrow down, "+this.name);
				// right arrow
				setActivePixel(new Point(_activePixel.x+1, _activePixel.y));
			//	moveTo(new Point(x+1, y));
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==40) {
				trace("bottom arrow down, "+this.name);
				// bottom arrow
				setActivePixel(new Point(_activePixel.x, _activePixel.y+1));
			//	moveTo(new Point(x, y+1));
				evt.updateAfterEvent();
			}
		}
				
				
		
		
				
				
		
		// how focus is gained
		//  - rollover while mouse button is up
		//  - mouse button release while over
		//  - tab 
				
		
		
		
		// how focus is gained:
		//  - by rolling over (when not dragging a pixel mask)
		//  - by releasing over (after having dragged a pixel mask)
		//  - by tabbing
		
		
		
		private var _listeningForMouseMove:Boolean = false;
		private var _listeningForFocusLoss:Boolean = false;
		
		
		private function onRollOverFunc(...ignored):void {
			if (!(stage.focus is PixelMaskProxy) || ((stage.focus is PixelMaskProxy) && !(stage.focus as PixelMaskProxy).beingDragged)) {
				
				if (!_listeningForMouseMove) {
					checkForActivePixelChange();
					addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
					_listeningForMouseMove = true;
					
					stage.focus = this;
				}
				else {
					trace("WAIT! why was this called?, 1");
				}
			}
			else {
				if (!_listeningForFocusLoss) {
					_listeningForFocusLoss = true;
					stage.addEventListener(FocusEvent.FOCUS_OUT, onStageFocusOut);
				}
				else {
					trace("WAIT! why was this called?, 2");
				}
			}
		}		
		
		
		
		
		
		
		
		
		
		
		
		
		private function onStageFocusOut(evt:FocusEvent):void {
			trace("stage focus out, "+evt.target.name);
			trace(" is pm: "+(evt.target is PixelMaskProxy));
			trace(" focus: "+String(stage.focus));
			
			
			
			if (_listeningForFocusLoss) {
				
			//setActivePixel(new Point(int(_displayWidth/2), int(_displayHeight/2)));
				checkForActivePixelChange();
			
			
				_listeningForFocusLoss = false;
				stage.removeEventListener(FocusEvent.FOCUS_OUT, onStageFocusOut);
			}			
			else if (_listeningForFocusLoss) {
				trace("WAIT! why was this called, 3");
			}
			
			stage.focus = this;
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
			checkForActivePixelChange();
			redrawDisplay();
		}
		
		
		
		
		private function onMouseMoveFunc(evt:MouseEvent):void {
			checkForActivePixelChange();
			evt.updateAfterEvent();
		}
		
		private function onRollOutFunc(...ignored):void {
			if (_listeningForMouseMove) {
				checkForActivePixelChange();
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
				_listeningForMouseMove = false;
			}
			else if (_listeningForFocusLoss) {
				_listeningForFocusLoss = false;
				stage.removeEventListener(FocusEvent.FOCUS_OUT, onStageFocusOut);
			}
		}
		
		private function checkForActivePixelChange(...ignored):void {
			// this function checks whether the current position of the mouse is different than
			// the active pixel position -- if it is, the active pixel is redrawn and an event is dispatched
			var mousePixel:Point = getPixelFromPoint(new Point(mouseX, mouseY));
			if ((mousePixel.x!=_activePixel.x) || (mousePixel.y!=_activePixel.y)) {
				setActivePixel(mousePixel);
				//_activePixel = mousePixel;
				//drawPixelOutline();				
				//dispatchEvent(new Event("activePixelChanged"));
			}
		}
		
		public function setActivePixel(px:Point):void {
			var ax:Number = px.x;
			var ay:Number = px.y;
			trace("setting active pixel");
			trace(" ax: "+ax);
			trace(" ay: "+ay);
			if (!isFinite(ax) || !isFinite(ay) || isNaN(ax) || isNaN(ay)) return;
			if (!(ax==-1 && ay==-1)) {
				if (ax<0) ax = 0;
				else if (ax>_displayWidth) ax = _displayWidth;
				if (ay<0) ay = 0;
				else if (ay>_displayHeight) ay = _displayHeight;
			}
			_activePixel.x = ax;
			_activePixel.y = ay;
			drawPixelOutline();
			dispatchEvent(new Event("activePixelChanged"));
		}
		
		public function clearActivePixel():void {
			
			_activePixel.x = -1;
			_activePixel.y = -1;
			if (_listeningForMouseMove) {
				removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
				_listeningForMouseMove = false;
			}
			drawPixelOutline();
		}
		
		public function get activePixel():Point {
			return _activePixel.clone();
		}
		
		private function getPixelFromPoint(arg:Point):Point {
			// this function gets the pixel associated with a given screen point
			// the pixel is returned as a point, with x and y equal to -1 if the 
			// point is out of bounds (but this behavior can be changed by modifying the code below)
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			var px:int = Math.floor(mouseX/xPixelSize);
			var py:int = Math.floor(mouseY/yPixelSize);
			
			if (px<0 || py<0 || px>=_pixelWidth || py>=_pixelHeight) px = py = -1;
			
			/*
			// this commented out block of code would select the pixel nearest to the out of bounds point
			// if it replaced the line of code directly above
			if (px<0) px = 0;
			else if (px>=_pixelWidth) px = _pixelWidth-1;
			if (py<0) py = 0;
			else if (py>=_pixelHeight) py = _pixelHeight-1;
			*/
			
			return new Point(px, py);
		}
		
		public function drawPixelOutline(...ignored):void {
			// this function is responsible for drawing the outline around the active pixel
			
			_activePixelSP.graphics.clear();
			
			if (_activePixel.x==-1) return;
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			/*
			var x1:int = xPixelSize*_activePixel.x;
			var x2:int = x1 + xPixelSize;
			var y1:int = yPixelSize*_activePixel.y;
			var y2:int = y1 + yPixelSize;
			
			_activePixelSP.graphics.clear();
			*/
			_activePixelSP.graphics.lineStyle(2, 0xffffa000, 1);
			
			/*
			_activePixelSP.graphics.moveTo(x1, y1);
			_activePixelSP.graphics.lineTo(x2, y1);
			_activePixelSP.graphics.lineTo(x2, y2);
			_activePixelSP.graphics.lineTo(x1, y2);
			_activePixelSP.graphics.lineTo(x1, y1);
			*/
			
			_activePixelSP.graphics.drawRect(xPixelSize*_activePixel.x, yPixelSize*_activePixel.y, xPixelSize, yPixelSize);
		}
		
		public function get xPixelSize():Number {
			return _displayWidth/_pixelWidth;
		}
		
		public function get yPixelSize():Number {
			return _displayHeight/_pixelHeight;
		}
		
		public function redrawDisplay(...ignored):void {
			_displaySP.graphics.clear();
			_customMarkingsMaskSP.graphics.clear();
			
			if (_pixelArray==null) return;
			
			var i:int;
			var j:int;
			
			var xPixelSize:Number = _displayWidth/_pixelWidth;
			var yPixelSize:Number = _displayHeight/_pixelHeight;
			
			var alpha:Number;
			
			for (i=0; i<_pixelWidth; i++) {
				for (j=0; j<_pixelHeight; j++) {
					alpha = 1 - (((_pixelArray[i][j] & 0xff000000) >> 24) & 0x000000ff)/0xff;
					_displaySP.graphics.beginFill(0x00ffffff & _pixelArray[i][j], alpha);
					_displaySP.graphics.drawRect(i*xPixelSize, j*yPixelSize, xPixelSize, yPixelSize);					
					_displaySP.graphics.endFill();
				}
			}			
			
			_customMarkingsMaskSP.graphics.beginFill(0xff0000, 1);
			_customMarkingsMaskSP.graphics.drawRect(0, 0, _displayWidth, _displayHeight);
			_customMarkingsMaskSP.graphics.endFill();		
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
			
			_backgroundSP.graphics.clear();
			_backgroundSP.graphics.beginBitmapFill(bmd);
			_backgroundSP.graphics.drawRect(0, 0, _displayWidth, _displayHeight);
			_backgroundSP.graphics.endFill();
			
		}
		
		
		
		
		
		public function clearCustomMarkings(...ignored):void {
			_customMarkingsSP.graphics.clear();
		}
		
		public function addCustomMarking(params:Object):void {
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

	