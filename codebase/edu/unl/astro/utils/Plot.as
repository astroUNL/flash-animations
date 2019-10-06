
package edu.unl.astro.utils {
	
	import edu.unl.astro.utils.PlotSeries;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import fl.events.DataChangeEvent;
	import fl.data.DataProvider;
	import fl.motion.easing.Cubic;
	
		
	public class Plot extends Sprite {
		
		protected var _xAxisSettings:AxisSettingsObject;
		protected var _yAxisSettings:AxisSettingsObject;
		
		protected var _locked:Boolean = false;
		
		protected var _backgroundSP:Sprite;
		protected var _xAxisSP:Sprite;
		protected var _yAxisSP:Sprite;
		protected var _xAxisGridlinesSP:Sprite;
		protected var _yAxisGridlinesSP:Sprite;
		protected var _dataSP:Sprite;
		protected var _dataMaskSP:Sprite;
		protected var _borderSP:Sprite;
		protected var _mouseAreaSP:Sprite;
		
		protected var _xAxisTickmarkLabelsSP:Sprite;
		protected var _yAxisTickmarkLabelsSP:Sprite;
		protected var _zoomWindowSP:Sprite;
		protected var _dataLinesSP:Sprite;
		protected var _dataPointsSP:Sprite;
		
		protected var _showXAxisGridlines:Boolean = false;
		protected var _showYAxisGridlines:Boolean = false;
		
		protected var _seriesList:Array = [];
		
		public var tickmarkLabelsPosition:Number = 7;
		public var tickmarkLabelsTextFormat:TextFormat;
		public var backgroundColor:uint = 0xffffff;
		public var backgroundAlpha:Number = 1;
		public var borderThickness:Number = 1;
		public var borderColor:uint = 0x000000;
		public var borderAlpha:Number = 1;
		public var tickmarkLengths:Object = {long: 6, medium: 4, short: 2};
		public var gridlineStyles:Object = {long: {visible: true, thickness: 1, color: 0xdddff0, alpha: 1},
											medium: {visible: true, thickness: 1, color: 0xdddff0, alpha: 0.5},
											short: {visible: true, thickness: 1, color: 0xdddff0, alpha: 0.2}};
		
		public var xAxisPropertyName:String = "x";
		public var yAxisPropertyName:String = "y";
		
		public var zoomWindowFillColor:uint = 0x406840;
		public var zoomWindowFillAlpha:Number = 0.1;
		public var zoomWindowBorderThickness:Number = 1;
		public var zoomWindowBorderColor:uint = 0x406840;
		public var zoomWindowBorderAlpha:Number = 0.5;
		
		public static const ZOOM_START:String = "zoomStart";
		public static const ZOOM_DONE:String = "zoomDone";
		public static const ON_ZOOM_STEP_TAKEN:String = "onZoomStepTaken";
		
		protected var _zoomWindowParams:Object = null;
		protected var _zoomMode:String = "none";
		protected var _zoomAnimationInProgess:Boolean = false;
		protected var _zoomAnimationParams:Object = null;
		
		
		
		// the easing function must have the standard (t, b, c, d) arguments signiture
		public var zoomAnimationEasingFunction:Function = Cubic.easeInOut;
		public var doZoomAnimation:Boolean = true;
		public var zoomAnimationTime:uint = 1000;
		
		
		protected var _checkeredAreaSP:Sprite;
		protected var _checkeredAreaMaskSP:Sprite;
		
		public function Plot(...argsList):void {
			
			tickmarkLabelsTextFormat = new TextFormat("Verdana", 12);
			
			_xAxisSettings = new AxisSettingsObject();
			_xAxisSettings.length = 350;
			_xAxisSettings.minSpacingForTickmarks = 9;
			_xAxisSettings.minSpacingForLabels = 34;
			
			_yAxisSettings = new AxisSettingsObject();
			_yAxisSettings.length = 250;
			_yAxisSettings.minSpacingForTickmarks = 9;
			_yAxisSettings.minSpacingForLabels = 25;
			
			
			_backgroundSP = new Sprite();
			_xAxisSP = new Sprite();
			_yAxisSP = new Sprite();
			_xAxisGridlinesSP = new Sprite();
			_yAxisGridlinesSP = new Sprite();
			_dataSP = new Sprite();
			_dataMaskSP = new Sprite();			
			_borderSP = new Sprite();
			_mouseAreaSP = new Sprite();
			_zoomWindowSP = new Sprite();
			
			_checkeredAreaSP = new Sprite();
			_checkeredAreaMaskSP = new Sprite();
			
			_xAxisTickmarkLabelsSP = new Sprite();
			_yAxisTickmarkLabelsSP = new Sprite();
			
			_xAxisSP.addChild(_xAxisTickmarkLabelsSP);
			_yAxisSP.addChild(_yAxisTickmarkLabelsSP);
			
			_dataLinesSP = new Sprite();
			_dataPointsSP = new Sprite();
			
			_dataSP.addChild(_dataLinesSP);
			_dataSP.addChild(_dataPointsSP);
			
			addChild(_backgroundSP);
			addChild(_xAxisSP);
			addChild(_yAxisSP);
			addChild(_xAxisGridlinesSP);
			addChild(_yAxisGridlinesSP);
			addChild(_dataSP);
			addChild(_dataMaskSP);
			addChild(_borderSP);
			
			addChild(_checkeredAreaSP);
			addChild(_checkeredAreaMaskSP);
			
			_checkeredAreaSP.mask = _checkeredAreaMaskSP;
			
			addChild(_mouseAreaSP);
			addChild(_zoomWindowSP);			
			
			
			setZoomMode("none");
			
			_dataSP.mask = _dataMaskSP;
			
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
			
			updateCheckeredArea();
			updateBackgroundAndBorder();
		}
		
		public function loadSettings(...argsList):void {
			// this function can be used to set any number of the public properties of the plot
			// component; these properties should be passed as properties of an object or objects
			// passed as arguments; this works the same as the constructor initialization
			loadSettingsFromObjectsList(argsList)
		}
		
		protected function loadSettingsFromObjectsList(objectsList:Array):void {
			// this utility function does the actual work of parsing the arguments
			// from loadSettings and the constructor
			var propName:String;
			for each (var item in objectsList) {
				if (item is Object) {
					for (propName in item) this[propName] = item[propName];					
				}
			}
		}
		
		
		public function zoomTo(ranges:Object):void {
			// this function initiates an animation to zoom to a new range as specified in
			// the ranges object; this object should contain at least xMin, xMax, yMin, and yMax
			
			
			// return if there's currently a zooming operation going on
			if (_zoomAnimationInProgess) return;
			
			var xMinValid:Boolean = (ranges.xMin is Number) && !isNaN(ranges.xMin) && isFinite(ranges.xMin);
			var xMaxValid:Boolean = (ranges.xMax is Number) && !isNaN(ranges.xMax) && isFinite(ranges.xMax);
			var yMinValid:Boolean = (ranges.yMin is Number) && !isNaN(ranges.yMin) && isFinite(ranges.yMin);
			var yMaxValid:Boolean = (ranges.yMax is Number) && !isNaN(ranges.yMax) && isFinite(ranges.yMax);
			
			// at least one of the range properties needs to be valid to continue
			if (!xMinValid && !xMaxValid && !yMinValid && !yMaxValid) return;

			// remove any zoom window before continuing
			//clearZoomWindow();
			_zoomWindowSP.graphics.clear();
			
			// keep track of the start position and end position for the valid parameters
			_zoomAnimationParams = {};
			if (xMinValid) {
				_zoomAnimationParams.xMinAtStart = _xAxisSettings.min;
				_zoomAnimationParams.xMinRange = ranges.xMin - _xAxisSettings.min;
			}
			if (xMaxValid) {
				_zoomAnimationParams.xMaxAtStart = _xAxisSettings.max;
				_zoomAnimationParams.xMaxRange = ranges.xMax - _xAxisSettings.max;
			}
			if (yMinValid) {
				_zoomAnimationParams.yMinAtStart = _yAxisSettings.min;
				_zoomAnimationParams.yMinRange = ranges.yMin - _yAxisSettings.min;
			}
			if (yMaxValid) {
				_zoomAnimationParams.yMaxAtStart = _yAxisSettings.max;
				_zoomAnimationParams.yMaxRange = ranges.yMax - _yAxisSettings.max;
			}
			
			_zoomAnimationParams.startTime = getTimer();
			
			// dispatch the zoom start event
			dispatchEvent(new Event(Plot.ZOOM_START));
			
			// start the animation
			_zoomAnimationInProgess = true;			
			addEventListener(flash.events.Event.ENTER_FRAME, zoomAnimationOnEnterFrameFunc);
		}
		
		public function cancelZoomAnimation():void {
			// this function stops the zoom animation (if in progress) without doing any further
			// adjustment to the ranges (it will, however, dispatch the zoom done event)
			
			clearZoomWindow();
			
			// there's no animation in progress so there's nothing to do
			if (!_zoomAnimationInProgess) return;
			
			// cancel the animation
			_zoomAnimationInProgess = false;
			_zoomAnimationParams = null;
			
			// remove the on enter frame listener
			removeEventListener(flash.events.Event.ENTER_FRAME, zoomAnimationOnEnterFrameFunc);
			
			// dispatch the zoom done event
			dispatchEvent(new Event(Plot.ZOOM_DONE));
		}
		
		protected function zoomAnimationOnEnterFrameFunc(...ignored):void {
			// this is the function that's called at the frame rate in order to animate zooming
			
			// find the parameter, u, (from 0 to 1) which determines where we're at
			// between the start and end of the animation
			var t:Number = getTimer() - _zoomAnimationParams.startTime;
			var u:Number = (t>=zoomAnimationTime) ? 1 : zoomAnimationEasingFunction(t, 0, 1, zoomAnimationTime);
			
			// one reason we don't use the setters is that as they are written now they would cancel the
			// the animation and there are already enough private flag variables
			if (_zoomAnimationParams.xMinAtStart!=undefined) {
				var xMin:Number = _zoomAnimationParams.xMinAtStart + u*_zoomAnimationParams.xMinRange;
				_xAxisSettings.min = xMin;
			}
			if (_zoomAnimationParams.xMaxAtStart!=undefined) {
				var xMax:Number = _zoomAnimationParams.xMaxAtStart + u*_zoomAnimationParams.xMaxRange;
				_xAxisSettings.max = xMax;
			}
			if (_zoomAnimationParams.yMinAtStart!=undefined) {
				var yMin:Number = _zoomAnimationParams.yMinAtStart + u*_zoomAnimationParams.yMinRange;
				_yAxisSettings.min = yMin;
			}
			if (_zoomAnimationParams.yMaxAtStart!=undefined) {
				var yMax:Number = _zoomAnimationParams.yMaxAtStart + u*_zoomAnimationParams.yMaxRange;
				_yAxisSettings.max = yMax;
			}
			
			
			
			var xScale:Number = _xAxisSettings.length/(_xAxisSettings.max - _xAxisSettings.min);
			var yScale:Number = -_yAxisSettings.length/(_yAxisSettings.max - _yAxisSettings.min);
			
			_zoomWindowParams.startPointInPixels.x = xScale*(_zoomWindowParams.startPointInUnits.x - _xAxisSettings.min);
			_zoomWindowParams.startPointInPixels.y = yScale*(_zoomWindowParams.startPointInUnits.y - _yAxisSettings.min);
			
			_zoomWindowParams.endPointInPixels.x = xScale*(_zoomWindowParams.endPointInUnits.x - _xAxisSettings.min);
			_zoomWindowParams.endPointInPixels.y = yScale*(_zoomWindowParams.endPointInUnits.y - _yAxisSettings.min);
			
			updateZoomWindowAppearance2();
			//updateZoomWindowAppearance();
			
			update();
			
			// cancel the animation if done (this call also causes the zoom done event to be dispatched)
			if (u>=1) cancelZoomAnimation();
			else dispatchEvent(new Event(Plot.ON_ZOOM_STEP_TAKEN));
		}
				
		protected function updateZoomWindowAppearance2():void {
			
			var xLeft = Math.min(_zoomWindowParams.startPointInPixels.x, _zoomWindowParams.endPointInPixels.x);
			var xRight = Math.max(_zoomWindowParams.startPointInPixels.x, _zoomWindowParams.endPointInPixels.x);
			var yBottom = Math.max(_zoomWindowParams.startPointInPixels.y, _zoomWindowParams.endPointInPixels.y);
			var yTop = Math.min(_zoomWindowParams.startPointInPixels.y, _zoomWindowParams.endPointInPixels.y);
			
			_checkeredAreaMaskSP.graphics.clear();
			
			if (_zoomMode=="xZoomOnly") {
				_checkeredAreaMaskSP.graphics.moveTo(0, 0);
				_checkeredAreaMaskSP.graphics.beginFill(0xff0000, 0.1);
				_checkeredAreaMaskSP.graphics.lineTo(xLeft, 0);
				_checkeredAreaMaskSP.graphics.lineTo(xLeft, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(0, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(0, 0);
				_checkeredAreaMaskSP.graphics.endFill();
				
				_checkeredAreaMaskSP.graphics.moveTo(xRight, 0);
				_checkeredAreaMaskSP.graphics.beginFill(0xff0000, 0.1);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, 0);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(xRight, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(xRight, 0);
				_checkeredAreaMaskSP.graphics.endFill();
			}
			else if (_zoomMode=="yZoomOnly") {
				_checkeredAreaMaskSP.graphics.moveTo(0, 0);
				_checkeredAreaMaskSP.graphics.beginFill(0xff0000, 0.1);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, 0);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, yBottom);
				_checkeredAreaMaskSP.graphics.lineTo(0, yBottom);
				_checkeredAreaMaskSP.graphics.lineTo(0, 0);
				_checkeredAreaMaskSP.graphics.endFill();
				
				_checkeredAreaMaskSP.graphics.moveTo(0, yTop);
				_checkeredAreaMaskSP.graphics.beginFill(0xff0000, 0.1);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, yTop);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(0, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(0, yTop);
				_checkeredAreaMaskSP.graphics.endFill();
			}
			else if (_zoomMode=="xyZoom") {				
				
				_checkeredAreaMaskSP.graphics.moveTo(0, 0);
				_checkeredAreaMaskSP.graphics.beginFill(0xff0000, 0.1);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, 0);
				_checkeredAreaMaskSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(0, -_yAxisSettings.length);
				_checkeredAreaMaskSP.graphics.lineTo(0, 0);
			
				_checkeredAreaMaskSP.graphics.moveTo(xLeft, yBottom);
				_checkeredAreaMaskSP.graphics.lineTo(xLeft, yTop);
				_checkeredAreaMaskSP.graphics.lineTo(xRight, yTop);
				_checkeredAreaMaskSP.graphics.lineTo(xRight, yBottom);
				_checkeredAreaMaskSP.graphics.lineTo(xLeft, yBottom);
				_checkeredAreaMaskSP.graphics.endFill();
			}
			
				
		}
		
		protected function updateZoomWindowAppearance():void {
			updateZoomWindowAppearance2();
			
			// this function erases and (depending on the settings) redraws the zoom window
			
			_zoomWindowSP.graphics.clear();
			
			
			
			// return if there isn't anything to draw
			if (_zoomWindowParams==null || _zoomWindowParams.endPointInPixels==undefined) return;
			
			// draw the window appropriate for the mode
			if (_zoomMode=="xZoomOnly") {
				_zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness, zoomWindowBorderColor, zoomWindowBorderAlpha, false, "normal", "none");
				_zoomWindowSP.graphics.moveTo(_zoomWindowParams.startPointInPixels.x, 0);
				_zoomWindowSP.graphics.beginFill(zoomWindowFillColor, 0);
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x, -_yAxisSettings.length);
				_zoomWindowSP.graphics.lineStyle();
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x, -_yAxisSettings.length)
				_zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness, zoomWindowBorderColor, zoomWindowBorderAlpha, false, "normal", "none");
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x, 0);
				_zoomWindowSP.graphics.lineStyle();
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x, 0);
				_zoomWindowSP.graphics.endFill();
			}
			else if (_zoomMode=="yZoomOnly") {
				_zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness, zoomWindowBorderColor, zoomWindowBorderAlpha, false, "normal", "none");
				_zoomWindowSP.graphics.moveTo(0, _zoomWindowParams.startPointInPixels.y);
				_zoomWindowSP.graphics.beginFill(zoomWindowFillColor, 0);
				_zoomWindowSP.graphics.lineTo(_xAxisSettings.length, _zoomWindowParams.startPointInPixels.y);
				_zoomWindowSP.graphics.lineStyle();
				_zoomWindowSP.graphics.lineTo(_xAxisSettings.length, _zoomWindowParams.endPointInPixels.y);
				_zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness, zoomWindowBorderColor, zoomWindowBorderAlpha, false, "normal", "none");
				_zoomWindowSP.graphics.lineTo(0, _zoomWindowParams.endPointInPixels.y);
				_zoomWindowSP.graphics.lineStyle();
				_zoomWindowSP.graphics.lineTo(0, _zoomWindowParams.startPointInPixels.y);
				_zoomWindowSP.graphics.endFill();
			}
			else if (_zoomMode=="xyZoom") {				
				_zoomWindowSP.graphics.lineStyle(zoomWindowBorderThickness, zoomWindowBorderColor, zoomWindowBorderAlpha);
				_zoomWindowSP.graphics.moveTo(_zoomWindowParams.startPointInPixels.x, _zoomWindowParams.startPointInPixels.y);
				_zoomWindowSP.graphics.beginFill(zoomWindowFillColor, 0);
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x, _zoomWindowParams.endPointInPixels.y);
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x, _zoomWindowParams.endPointInPixels.y);
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.endPointInPixels.x, _zoomWindowParams.startPointInPixels.y);
				_zoomWindowSP.graphics.lineTo(_zoomWindowParams.startPointInPixels.x, _zoomWindowParams.startPointInPixels.y);
				_zoomWindowSP.graphics.endFill();
			}		
		}
				
		protected function onMouseDownOnBackground(...ignored):void {
			// this function is called when the background sprite dispatches a mouse down event;
			// this is where a new zoom window is begun; if there's already a completed zoom window
			// then it is cleared before continuing
			
			// the zoom features are disabled while doing animation
			if (_zoomAnimationInProgess) return;
			
			// clear any existing zoom window (this makes the _zoomWindowParams object null so
			// we need to recreate it)
			clearZoomWindow();
			_zoomWindowParams = {};
			
			// log the start point 		
			_zoomWindowParams.startPointInPixels = {x: _mouseAreaSP.mouseX, y: _mouseAreaSP.mouseY};
			
			// the window is not valid to begin with since there isn't a range to zoom in to
			_zoomWindowParams.isValid = false;		
			
			// the window is also not listening for clicks (it hasn't been created yet)
			_zoomWindowParams.isListening = false;
						
			// start zoom window dragging
			_zoomWindowParams.draggingInProgress = true;
			stage.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, updateZoomWindowDragging);
			stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, stopZoomWindowDragging);
		}
		
		protected function updateZoomWindowDragging(evt:MouseEvent):void {
			// this function is called when the cursor moves while the mouse button is down and a 
			// zoom window is being created
			
			// the current mouse cursor position will be the end point of the zoom window; one thing
			// we need to do is make sure zoom window stays within the plot area
			var ex:Number = _mouseAreaSP.mouseX;
			var ey:Number = _mouseAreaSP.mouseY;
			if (ex<0) ex = 0;
			else if (ex>_xAxisSettings.length) ex = _xAxisSettings.length;
			if (ey>0) ey = 0;
			else if (ey<-_yAxisSettings.length) ey = -_yAxisSettings.length;
			
			// now determine if the zoom window is valid
			if (_zoomMode=="xZoomOnly") {
				_zoomWindowParams.isValid = (_zoomWindowParams.startPointInPixels.x != ex);
			}
			else if (_zoomMode=="yZoomOnly") {
				_zoomWindowParams.isValid = (_zoomWindowParams.startPointInPixels.y != ey);
			}
			else if (_zoomMode=="xyZoom") {
				_zoomWindowParams.isValid = (_zoomWindowParams.startPointInPixels.x != ex) && (_zoomWindowParams.startPointInPixels.y != ey);
			}
			
			_zoomWindowParams.endPointInPixels = {};
			_zoomWindowParams.endPointInPixels.x = ex;
			_zoomWindowParams.endPointInPixels.y = ey;
			
			updateZoomWindowAppearance();
			
			evt.updateAfterEvent();
		}
		
		protected function stopZoomWindowDragging(...ignored):void {
			// this function is called when the mouse button goes up while the zoom window was
			// being dragged
			
			// first check if there's a defined zoom window (e.g. if the cursor
			// never moves there isn't a valid defined range); if there isn't then clean up and return
			if (!_zoomWindowParams.isValid) {
				clearZoomWindow();
				return;				
			}
			
			// refresh the zoom window appearance now that the mouse button is up
			updateZoomWindowAppearance();
			
			// now add a listener so the user can click on the created zoom window to the effect the zoom
			_zoomWindowParams.isListening = true;
			_zoomWindowSP.addEventListener(flash.events.MouseEvent.CLICK, onZoomWindowClicked);
						
			_zoomWindowParams.draggingInProgress = false;
			stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, updateZoomWindowDragging);
			stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, stopZoomWindowDragging);
		}
		
		public var xZoomRangeLimit:Number = Number.NaN;
		public var yZoomRangeLimit:Number = Number.NaN;
		
		protected function onZoomWindowClicked(evt:Event):void {
			// this function is called when the user clicks on an existing zoom window, which
			// will cause the zoom to take effect			
			
			var xScale:Number = _xAxisSettings.length/(_xAxisSettings.max - _xAxisSettings.min);
			var yScale:Number = -_yAxisSettings.length/(_yAxisSettings.max - _yAxisSettings.min);
			
			var startPointInUnits:Object = {};
			startPointInUnits.x = _xAxisSettings.min + (_zoomWindowParams.startPointInPixels.x/xScale);
			startPointInUnits.y = _yAxisSettings.min + (_zoomWindowParams.startPointInPixels.y/yScale);
			
			var endPointInUnits:Object = {};
			endPointInUnits.x = _xAxisSettings.min + (_zoomWindowParams.endPointInPixels.x/xScale);
			endPointInUnits.y = _yAxisSettings.min + (_zoomWindowParams.endPointInPixels.y/yScale);
			
			_zoomWindowParams.startPointInUnits = startPointInUnits;
			_zoomWindowParams.endPointInUnits = endPointInUnits;
			
			var xMin:Number = Math.min(startPointInUnits.x, endPointInUnits.x);
			var xMax:Number = Math.max(startPointInUnits.x, endPointInUnits.x);
			var yMin:Number = Math.min(startPointInUnits.y, endPointInUnits.y);
			var yMax:Number = Math.max(startPointInUnits.y, endPointInUnits.y);
			
			if (!isNaN(xZoomRangeLimit) && isFinite(xZoomRangeLimit) && ((xMax-xMin)<xZoomRangeLimit)) {
				var xCenter:Number = xMin + (xMax-xMin)/2;
				xMin = xCenter - xZoomRangeLimit/2;
				xMax = xCenter + xZoomRangeLimit/2;
			}
			
			if (!isNaN(yZoomRangeLimit) && isFinite(yZoomRangeLimit) && ((yMax-yMin)<yZoomRangeLimit)) {
				var yCenter:Number = yMin + (yMax-yMin)/2;
				yMin = yCenter - yZoomRangeLimit/2;
				yMax = yCenter + yZoomRangeLimit/2;
			}
			
			if (doZoomAnimation) {
				// begin zooming animation
				if (_zoomMode=="xZoomOnly") {
					zoomTo({xMin: xMin, xMax: xMax});
				}
				else if (_zoomMode=="yZoomOnly") {
					zoomTo({yMin: yMin, yMax: yMax});
				}
				else if (_zoomMode=="xyZoom") {
					zoomTo({xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax});
				}				
			}
			else {
				// immediately zoom in on the selected range, clear up the zoom window, and
				// then dispatch the notification event
				if (_zoomMode=="xZoomOnly") {
					setXAxisRange(xMin, xMax);
				}
				else if (_zoomMode=="yZoomOnly") {
					setYAxisRange(yMin, yMax);
				}
				else if (_zoomMode=="xyZoom") {
					lock();
					setXAxisRange(xMin, xMax);
					setYAxisRange(yMin, yMax);
					unlock();
				}
				clearZoomWindow();
				dispatchEvent(new Event(Plot.ZOOM_DONE));
			}
		}
		
		protected function clearZoomWindow():void {
			// this function removes any zoom window that has been defined
			
			// clear any zoom window
			_zoomWindowSP.graphics.clear();
			_checkeredAreaMaskSP.graphics.clear();
			
			// remove the zoom window's listener (if one is defined, which we can 
			// determine if the window parameters object is non-null)
			if (_zoomWindowParams!=null) {
				if (_zoomWindowParams.isListening) {
					_zoomWindowSP.removeEventListener(flash.events.MouseEvent.CLICK, onZoomWindowClicked);
				}
				if (_zoomWindowParams.draggingInProgress) {
					stage.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, updateZoomWindowDragging);
					stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, stopZoomWindowDragging);
				}
			}
			
			// nullify the window parameters
			_zoomWindowParams = null;			
		}
		
		public function setZoomMode(arg:String):void {
			// This function is used to specify whether the plot will allow zooming in by
			// mouse interaction. The mode options are:
			//		"xZoomOnly" - allow the user to alter the x range; the y range stays fixed
			//		"yZoomOnly" - allow the user to alter the y range; the x range stays fixed
			//		"xyZoom" - allow the user to changed both ranges
			//		"none" - don't allow mouse interaction to change ranges
			
			// Here are the steps involved in zooming:
			//	1) start with a plot that's clear of a zoom window
			//	2) when the user presses the mouse button over the plot area, prepare to create
			//		a zoom window; as the user moves the cursor (with the mouse button down)
			//		redraw the resulting zoom window taking into account the zoom limit settings
			//	3) once the user releases the mouse button the zoom window remains fixed and a
			//		listener is set up on it to wait for a mouse click; this is assuming that the
			//		user moved the mouse cursor away from its initial position, if not, then go
			//		back to step 1
			//	4) if the user clicks on the zoom window then zoom in (next step); otherwise
			//		if the user clicks on the plot area but outside the zoom window then
			//		clear away the zoom window and go back to step 1
			//	5) clear away the zoom window and zoom in; we either zoom in immediately
			//		or animate in to the new range depending on the settings; if animating
			//		then the zoom features are temporarily disabled
			//	6) dispatch an event when the zoom operation is completed; return to step 1
			
			// changing the mode clears any zoom window that may exist (it does not affect any zoom animation)
			clearZoomWindow();
			
			if (arg=="xZoomOnly") {
				if (_zoomMode=="none") _mouseAreaSP.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDownOnBackground);
				_zoomMode = arg;
			}
			else if (arg=="yZoomOnly") {
				if (_zoomMode=="none") _mouseAreaSP.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDownOnBackground);
				_zoomMode = arg;
			}
			else if (arg=="xyZoom") {
				if (_zoomMode=="none") _mouseAreaSP.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDownOnBackground);
				_zoomMode = arg;
			}
			else {
				if (_zoomMode!="none") _mouseAreaSP.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDownOnBackground);
				_zoomMode = "none";
			}
		}
		
		public function addSeries(series:PlotSeries):PlotSeries {
			// this function adds a series to the plot
			
			var seriesObj:Object = {};
			seriesObj.series = series;
			
			// add the event listeners
			seriesObj.series.addEventListener(PlotSeries.REFRESH_REQUESTED, onRefreshSeriesRequested);
			seriesObj.series.addEventListener(fl.events.DataChangeEvent.DATA_CHANGE, onRefreshSeriesRequested);
	
			// add the sprites
			seriesObj.linesSP = new Sprite();
			seriesObj.pointsSP = new Sprite();
			_dataLinesSP.addChild(seriesObj.linesSP);
			_dataPointsSP.addChild(seriesObj.pointsSP);
			
			// add the object to the list
			_seriesList.push(seriesObj);
			
			updateSeries(seriesObj);
			
			return series;
		}
		
		protected function onRefreshSeriesRequested(evt:Event):void {
			// this function is called when a series needs updating, 
			for each (var seriesObj in _seriesList) {
				if (seriesObj.series==evt.target) {
					updateSeries(seriesObj);
					break;
				}
			}			
		}

		public function removeSeries(series:PlotSeries):void {
			// this function is responsible for removing the given series from the plot
			for (var i:int = 0; i<_seriesList.length; i++) {
				// find the series object in the list
				if (_seriesList[i].series==series) {
					// remove the series' listeners and sprites
					removeSeriesDebris(_seriesList[i]);									   
					// remove the object from the list 
					_seriesList.splice(i, 1);					
					break;					
				}
			}			
		}
		
		public function removeAllSeries():void {
			// this function is responsible for removing all series from the plot			
			for each (var seriesObj in _seriesList) removeSeriesDebris(seriesObj);
			_seriesList = [];
		}
		
		protected function removeSeriesDebris(seriesObj:Object):void {
			// this ancillary function removes the listeners and sprites associated with a series
			// remove the listeners
			seriesObj.series.removeEventListener(PlotSeries.REFRESH_REQUESTED, onRefreshSeriesRequested);
			seriesObj.series.removeEventListener(fl.events.DataChangeEvent.DATA_CHANGE, onRefreshSeriesRequested);
			// remove the sprites
			_dataLinesSP.removeChild(seriesObj.linesSP);
			_dataPointsSP.removeChild(seriesObj.pointsSP);
		}
		
		protected function getFormattedNumber(num:Number, place:int):String {
			// this function takes a number and returns a string representation rounded
			// to the indicated digit (indicated by the power of ten of that place, e.g.
			// place = -1 causes the number to be rounded to the nearest tenth)
			if (place>=0) {
				var p:Number = Math.pow(10, place);
				return String(p*Math.round(num/p));
			}
			else return num.toFixed(-place);
		}
		
		protected function getTickmarksInfo(axisSettings:AxisSettingsObject):Object {
			// This function returns an object with four lists:
			//		longTickmarksList, mediumTickmarksList, shortTickmarksList, and tickmarkLabelsList
			// The tickmark lists consist of objects that define the tickmarks, and have 
			// value and position properties. The label list consists of objects that define tickmark
			// labels and have label and position properties. The tickmarks and labels generated follow
			// a base ten pattern, and will be arranged in one of two ways:
			//		1) If a power of ten is chosen as the tickmark spacing (ie. S = 10^p), then
			//		   the long tickmarks will be for multiples of the next greater power of 
			//		   ten (ie. S_long = 10^[p+1]), medium tickmarks will be for half of that next
			//		   greater power of ten (ie. S_med = 0.5*10^[p+1]), and the short tickmarks will
			//		   be for the remaining power of ten multiples (ie. S_short = 10^p).
			//		2) If half of a power of ten is chosen as the tickmark spacing (ie. S = 0.5*10^p), then
			//		   the long tickmarks will be for the next greater power of ten (ie. S_long = 10^[p+1]),
			//		   the medium tickmarks will be for the power of ten (ie. S_med = 10^p), and the 
			//		   short tickmarks will be for the halfs (ie. S_short = 0.5*10^p).
			// Which tickmarks get labels is determined by the specified minimum label spacing (NB: this spacing
			// does not take into account the size of the text, but merely refers to the distance between 
			// centers).
			
			// scale in units per px
			var scale:Number = axisSettings.length/(axisSettings.max - axisSettings.min);

			// what we want is to find the tickmark spacing in units that gives a pixel
			// spacing that's at least as big as the minimum spacing; we'll use either
			// a power of ten or half of a power of ten for the tickmark spacing

			// determine the minimum spacing in units for the tickmarks and labels
			var minSpacingInUnits:Number = axisSettings.minSpacingForTickmarks/scale;
			var minSpacingForLabelsInUnits:Number = axisSettings.minSpacingForLabels/scale;
			
			// find the least power of ten that's greater to or equal to the minimum spacing;
			// this power will also be used to specify the needed precision when creating label text 
			// (the value of precision may be adjusted later on)
			var precision:int = Math.ceil(Math.log(minSpacingInUnits)/Math.LN10);
			var spacingInUnits:Number = Math.pow(10, precision);
			
			var i:int;
			
			var longsMultiple:int;
			var mediumsMultiple:int;
			var labelsMultiple:int;
			
			// now determine which of the two ways of distributing the tickmarks to use (see comment
			// at the top of this function); this involves determining the (short) tickmark spacing
			// spacing to use, the multiples of this spacing to use for the medium and long tickmarks,
			// and multiples to use for labels
			if ((spacingInUnits/2)>=minSpacingInUnits) {
				// tickmark spacing is halfs (ie. in the form 0.5*10^p)
				
				spacingInUnits = spacingInUnits/2;
				
				longsMultiple = 20;
				mediumsMultiple = 2;
				
				for (i=1; i<=100000; i*=10) {
					if (minSpacingForLabelsInUnits<=(i*spacingInUnits)) {
						labelsMultiple = i;
						precision -= 1;
						break;
					}
					else if (minSpacingForLabelsInUnits<=(2*i*spacingInUnits)) {
						labelsMultiple = 2*i;
						break;					
					}
					precision += 1;
				}
			}
			else {
				// tickmark spacing is in integer multiples of a power of ten (ie. in the form 10^p)
				
				longsMultiple = 10;
				mediumsMultiple = 5;
				
				for (i=1; i<=100000; i*=10) {
					if (minSpacingForLabelsInUnits<=(i*spacingInUnits)) {
						labelsMultiple = i;
						break;
					}
					else if (minSpacingForLabelsInUnits<=(5*i*spacingInUnits)) {
						labelsMultiple = 5*i;
						break;					
					}
					precision += 1;
				}
			}
			
			// determine the tickmark ranges for the chosen spacing
			var startTickmarkNum:int = Math.ceil(axisSettings.min/spacingInUnits);
			var tickmarkNumLimit:int = 1 + Math.floor(axisSettings.max/spacingInUnits);
			
			var longTickmarksList:Array = [];
			var mediumTickmarksList:Array = [];
			var shortTickmarksList:Array = [];
			var tickmarkLabelsList:Array = [];
			
			// now generate the tickmarks and labels
			var tickmark:Object;
			for (i=startTickmarkNum; i<tickmarkNumLimit; i++) {
				tickmark = {};
				tickmark.value = i*spacingInUnits;
				tickmark.position = scale*(tickmark.value - axisSettings.min);
				if (axisSettings.inverted) tickmark.position = axisSettings.length - tickmark.position;
				
				if (i%longsMultiple==0) longTickmarksList.push(tickmark);
				else if (i%mediumsMultiple==0) mediumTickmarksList.push(tickmark);					
				else shortTickmarksList.push(tickmark);
				
				if (i%labelsMultiple==0) tickmarkLabelsList.push({position: tickmark.position, label: getFormattedNumber(tickmark.value, precision)});
			}
			
			var infoObj:Object = {};
			infoObj.longTickmarksList = longTickmarksList;
			infoObj.mediumTickmarksList = mediumTickmarksList;
			infoObj.shortTickmarksList = shortTickmarksList;
			infoObj.tickmarkLabelsList = tickmarkLabelsList;
			
			return infoObj;
		}
		
		public function update():void {
			if (_locked) {
				trace("skipped update due to lock");
				return;
			}
			var startTimer:Number = getTimer();
			updateXAxis();
			updateYAxis();
			updateAllSeries();
			trace("plot update: "+(getTimer()-startTimer));
		}		
		
		public function set showGridlines(arg:Boolean):void {
			_showXAxisGridlines = _showYAxisGridlines = arg;
			updateXAxis();
			updateYAxis();
		}
		
		public function get showGridlines():Boolean {
			return _showXAxisGridlines;
		}
		
		protected function updateAllSeries():void {
			// this function is responsible for redrawing all series
			for each (var seriesObj in _seriesList) updateSeries(seriesObj);
		}
		
		protected function updateSeries(seriesObj:Object):void {
			// this function is responsible for redrawing the given series (specified by the
			// series object as it occurs in the series list, ie. with series, linesSP, and pointsSP properties)
			
			var startTimer:Number = getTimer();
			
			var lG:Graphics = seriesObj.linesSP.graphics;
			var pG:Graphics = seriesObj.pointsSP.graphics;
			var s:PlotSeries = seriesObj.series;
			var d:DataProvider = seriesObj.series.dataProvider;
			var p:Object;
			var px:Number;
			var py:Number;
			
			var xScale:Number = _xAxisSettings.length/(_xAxisSettings.max - _xAxisSettings.min);
			var yScale:Number = -_yAxisSettings.length/(_yAxisSettings.max - _yAxisSettings.min);
			
			// determine whether to use the default property names defined on this plot component
			// or the property names defined (ie. not empty) on the series object
			var xPropName:String = (s.xAxisPropertyName=="") ? xAxisPropertyName : s.xAxisPropertyName;
			var yPropName:String = (s.yAxisPropertyName=="") ? yAxisPropertyName : s.yAxisPropertyName;
			
			lG.clear();
			lG.lineStyle(s.lineThickness, s.lineColor, s.lineAlpha);
					
			pG.clear();
			pG.lineStyle(s.pointOutlineThickness, s.pointOutlineColor, s.pointOutlineAlpha);
			
			// don't go further if the data provider is empty or null
			if (d==null || d.length==0) return;
			
			// for efficiency's sake we don't draw every point or line segment that is outside the
			// plot area; what we do is define four regions outside the plot area and establish if
			// a point is in any of these regions; if the next point is in the plot area we draw
			// the segment and the next point; if it is in a different out of bounds region we draw the line
			// segment but not the point; if it is in the same out of bounds region we don't draw anything
			// but move the pen to the new point
			
			// now define the out of bounds regions (we use a margin so that we can see a part of a point)
			// NB: region 4 means the point is inside the plot area
			var margin:Number = s.pointRadius;
			var region0Limit:Number = -margin; // left of the plot
			var region1Limit:Number = -_yAxisSettings.length - margin; // above the plot
			var region2Limit:Number = margin; // below the plot
			var region3Limit:Number = _xAxisSettings.length + margin; // right of the plot
			var regionLast:int;
			var regionCurr:int;
			
			// we need to consider the first point separately in order to set things up
			
			p = d.getItemAt(0);
			px = xScale*(p[xPropName] - _xAxisSettings.min);
			py = yScale*(p[yPropName] - _yAxisSettings.min);
			if (_xAxisSettings.inverted) px = _xAxisSettings.length - px;
			if (_yAxisSettings.inverted) py = -_yAxisSettings.length - py;
			
			if (px<region0Limit) regionCurr = 0;
			else if (py<region1Limit) regionCurr = 1;
			else if (py>region2Limit) regionCurr = 2;
			else if (px>region3Limit) regionCurr = 3;
			else regionCurr = 4;
			
			// we need to move the line pen to the first point regardless of which region it is in
			if (s.showLines) lG.moveTo(px, py);
			
			if (regionCurr==4) {
				// the first point is in the plot area, so draw the point
				if (s.showPoints) {
					pG.beginFill(s.pointFillColor, s.pointFillAlpha);
					pG.drawCircle(px, py, s.pointRadius);
					pG.endFill();
				}				
			}
			
			regionLast = regionCurr;
			
			// now go through the rest of the points in the series
			for (var i:int = 1; i<d.length; i++) {
				
				p = d.getItemAt(i);
				px = xScale*(p[xPropName] - _xAxisSettings.min);
				py = yScale*(p[yPropName] - _yAxisSettings.min);
				if (_xAxisSettings.inverted) px = _xAxisSettings.length - px;
				if (_yAxisSettings.inverted) py = -_yAxisSettings.length - py;
				
				if (px<region0Limit) regionCurr = 0;
				else if (py<region1Limit) regionCurr = 1;
				else if (py>region2Limit) regionCurr = 2;
				else if (px>region3Limit) regionCurr = 3;
				else regionCurr = 4;
				
				if (regionCurr==4) {
					// the current point is in the plot area, draw the line segment and point
					if (s.showLines) lG.lineTo(px, py);				
					if (s.showPoints) {
						pG.beginFill(s.pointFillColor, s.pointFillAlpha);
						pG.drawCircle(px, py, s.pointRadius);
						pG.endFill();
					}				
				}
				else if (regionCurr!=regionLast) {
					// the current point is outside the plot area, but it has moved between regions,
					// so draw the line but not the point
					if (s.showLines) lG.lineTo(px, py);	
				}
				else {
					// the current point is outside the plot area and has not moved between regions, 
					// so just move the pen
					if (s.showLines) lG.moveTo(px, py);				
				}
				
				regionLast = regionCurr;
			}
			
			trace("updateSeries: "+(getTimer()-startTimer));
		}
		
		protected function updateBackgroundAndBorder():void {
			_backgroundSP.graphics.clear();
			_backgroundSP.graphics.moveTo(0, 0);
			_backgroundSP.graphics.beginFill(backgroundColor, backgroundAlpha);
			_backgroundSP.graphics.lineTo(_xAxisSettings.length, 0);
			_backgroundSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
			_backgroundSP.graphics.lineTo(0, -_yAxisSettings.length);
			_backgroundSP.graphics.lineTo(0, 0);
			_backgroundSP.graphics.endFill();
			_borderSP.graphics.clear();
			_borderSP.graphics.moveTo(0, 0);
			_borderSP.graphics.lineStyle(borderThickness, borderColor, borderAlpha);
			_borderSP.graphics.lineTo(_xAxisSettings.length, 0);
			_borderSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
			_borderSP.graphics.lineTo(0, -_yAxisSettings.length);
			_borderSP.graphics.lineTo(0, 0);
			_dataMaskSP.graphics.clear();
			_dataMaskSP.graphics.moveTo(0, 0);
			_dataMaskSP.graphics.beginFill(0xff0000);
			_dataMaskSP.graphics.lineTo(_xAxisSettings.length, 0);
			_dataMaskSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
			_dataMaskSP.graphics.lineTo(0, -_yAxisSettings.length);
			_dataMaskSP.graphics.lineTo(0, 0);
			_dataMaskSP.graphics.endFill();
			_mouseAreaSP.graphics.clear();
			_mouseAreaSP.graphics.moveTo(0, 0);
			_mouseAreaSP.graphics.beginFill(0x0000ff, 0);
			_mouseAreaSP.graphics.lineTo(_xAxisSettings.length, 0);
			_mouseAreaSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
			_mouseAreaSP.graphics.lineTo(0, -_yAxisSettings.length);
			_mouseAreaSP.graphics.lineTo(0, 0);
			_mouseAreaSP.graphics.endFill();
		}
		
		protected function createNewTextField(paramsObj:Object):TextField {
			// the paramsObj is expected to have the following properties:
			//		x, y, format, autoSize, and text
			var tf:TextField = new TextField();
			tf.x = paramsObj.x;
			tf.y = paramsObj.y;
			tf.width = 0;
			tf.height = 0;
			tf.selectable = false;
			tf.embedFonts = true;
			tf.defaultTextFormat = paramsObj.format;
			tf.autoSize = paramsObj.autoSize;
			tf.text = paramsObj.text;
			return tf;		
		}
		
		protected function renderXAxisTickmarks(paramsObj:Object):void {
			// this function draws the given tickmarks with the given length along the x axis
			// paramsObj is expected to have the following properties:
			//		tickmarksList - a list of the tickmarks (each an object with a position property)
			//		length - the length of the tickmark
			for each (var tickmark in paramsObj.tickmarksList) {
				_xAxisSP.graphics.moveTo(tickmark.position, 0);
				_xAxisSP.graphics.lineTo(tickmark.position, paramsObj.length);
			}
		}
		
		protected function renderYAxisTickmarks(paramsObj:Object):void {
			// this function draws the given tickmarks with the given length along the y axis
			// paramsObj is expected to have the following properties:
			//		tickmarksList - a list of the tickmarks (each an object with a position property)
			//		length - the length of the tickmark
			for each (var tickmark in paramsObj.tickmarksList) {
				_yAxisSP.graphics.moveTo(0, -tickmark.position);
				_yAxisSP.graphics.lineTo(-paramsObj.length, -tickmark.position);
			}
		}
		
		protected function renderXAxisTickmarkLabels(labelsList:Array):void {
			// this function adds the given tickmark labels along the x axis at the specified locations
			// each item in the labels list is expected to have label (string) and position properties
			var label:TextField;
			for each (var labelObj in labelsList) {
				label = createNewTextField({x: labelObj.position,
											text: labelObj.label,
											format: tickmarkLabelsTextFormat,
											autoSize: "center"});
				label.y = tickmarkLabelsPosition;
				_xAxisTickmarkLabelsSP.addChild(label);
			}
		}

		protected function renderYAxisTickmarkLabels(labelsList:Array):void {
			// this function adds the given tickmark labels along the y axis at the specified locations
			// each item in the labels list is expected to have label (string) and position properties
			var label:TextField;
			for each (var labelObj in labelsList) {
				label = createNewTextField({x: -tickmarkLabelsPosition,
											y: -labelObj.position,
											text: labelObj.label,
											format: tickmarkLabelsTextFormat,
											autoSize: "right"});
				label.y -= label.height/2;			
				_yAxisTickmarkLabelsSP.addChild(label);
			}
		}
		
		protected function renderXAxisGridlines(linesList:Array):void {
			for each (var line in linesList) {
				_xAxisGridlinesSP.graphics.moveTo(line.position, 0);
				_xAxisGridlinesSP.graphics.lineTo(line.position, -_yAxisSettings.length);
			}
		}
		
		protected function renderYAxisGridlines(linesList:Array):void {
			for each (var line in linesList) {
				_yAxisGridlinesSP.graphics.moveTo(0, -line.position);
				_yAxisGridlinesSP.graphics.lineTo(_xAxisSettings.length, -line.position);
			}
		}
		
		protected function updateXAxis():void {
			// this function is responsible for redrawing the x axis tickmarks, tickmark labels, and gridlines
			
			var infoObj:Object = getTickmarksInfo(_xAxisSettings);
			
			_xAxisSP.graphics.clear();
			_xAxisSP.graphics.lineStyle(borderThickness, borderColor, borderAlpha);
			
			_xAxisSP.removeChild(_xAxisTickmarkLabelsSP);
			_xAxisTickmarkLabelsSP = new Sprite();
			_xAxisSP.addChild(_xAxisTickmarkLabelsSP);
			
			renderXAxisTickmarks({tickmarksList: infoObj.longTickmarksList, length: tickmarkLengths.long});
			renderXAxisTickmarks({tickmarksList: infoObj.mediumTickmarksList, length: tickmarkLengths.medium});
			renderXAxisTickmarks({tickmarksList: infoObj.shortTickmarksList, length: tickmarkLengths.short});
			
			renderXAxisTickmarkLabels(infoObj.tickmarkLabelsList);
			
			_xAxisGridlinesSP.graphics.clear();
			if (_showXAxisGridlines) {
				if (gridlineStyles.long.visible) {
					_xAxisGridlinesSP.graphics.lineStyle(gridlineStyles.long.thickness,
														 gridlineStyles.long.color,
														 gridlineStyles.long.alpha, false, "normal", "none");
					renderXAxisGridlines(infoObj.longTickmarksList);
				}
				if (gridlineStyles.medium.visible) {
					_xAxisGridlinesSP.graphics.lineStyle(gridlineStyles.medium.thickness,
														 gridlineStyles.medium.color,
														 gridlineStyles.medium.alpha, false, "normal", "none");
					renderXAxisGridlines(infoObj.mediumTickmarksList);
				}
				if (gridlineStyles.short.visible) {
					_xAxisGridlinesSP.graphics.lineStyle(gridlineStyles.short.thickness,
														 gridlineStyles.short.color,
														 gridlineStyles.short.alpha, false, "normal", "none");
					renderXAxisGridlines(infoObj.shortTickmarksList);
				}
			}			
		}
		
		protected function updateYAxis():void {
			// this function is responsible for redrawing the y axis tickmarks, tickmark labels, and gridlines
			
			var infoObj:Object = getTickmarksInfo(_yAxisSettings);			
			
			_yAxisSP.graphics.clear();
			_yAxisSP.graphics.lineStyle(borderThickness, borderColor, borderAlpha);
			
			_yAxisSP.removeChild(_yAxisTickmarkLabelsSP);
			_yAxisTickmarkLabelsSP = new Sprite();
			_yAxisSP.addChild(_yAxisTickmarkLabelsSP);
			
			renderYAxisTickmarks({tickmarksList: infoObj.longTickmarksList, length: tickmarkLengths.long});
			renderYAxisTickmarks({tickmarksList: infoObj.mediumTickmarksList, length: tickmarkLengths.medium});
			renderYAxisTickmarks({tickmarksList: infoObj.shortTickmarksList, length: tickmarkLengths.short});
			
			renderYAxisTickmarkLabels(infoObj.tickmarkLabelsList);
			
			_yAxisGridlinesSP.graphics.clear();
			if (_showYAxisGridlines) {
				if (gridlineStyles.long.visible) {
					_yAxisGridlinesSP.graphics.lineStyle(gridlineStyles.long.thickness,
														 gridlineStyles.long.color,
														 gridlineStyles.long.alpha, false, "normal", "none");
					renderYAxisGridlines(infoObj.longTickmarksList);
				}
				if (gridlineStyles.medium.visible) {
					_yAxisGridlinesSP.graphics.lineStyle(gridlineStyles.medium.thickness,
														 gridlineStyles.medium.color,
														 gridlineStyles.medium.alpha, false, "normal", "none");
					renderYAxisGridlines(infoObj.mediumTickmarksList);
				}
				if (gridlineStyles.short.visible) {
					_yAxisGridlinesSP.graphics.lineStyle(gridlineStyles.short.thickness,
														 gridlineStyles.short.color,
														 gridlineStyles.short.alpha, false, "normal", "none");
					renderYAxisGridlines(infoObj.shortTickmarksList);
				}
			}
		}
		
		public function setXAxisRange(min:Number, max:Number):void {
			if (!isFinite(min) || isNaN(min) || !isFinite(max) || isNaN(max) || min==max) return;
			
			// clear any zoom window and stop the zoom animation if in effect
			clearZoomWindow();
			cancelZoomAnimation();
			
			if (min>max) {
				var tmp:Number = min;
				min = max;
				max = tmp;
			}
			_xAxisSettings.min = min;
			_xAxisSettings.max = max;
			update();
		}
		
		public function getXAxisRange():Object {
			return {min: _xAxisSettings.min, max: _xAxisSettings.max};			
		}
		
		public function setYAxisRange(min:Number, max:Number):void {
			if (!isFinite(min) || isNaN(min) || !isFinite(max) || isNaN(max) || min==max) return;
			
			// clear any zoom window and stop the zoom animation if in effect
			clearZoomWindow();
			cancelZoomAnimation();
			
			if (min>max) {
				var tmp:Number = min;
				min = max;
				max = tmp;
			}
			_yAxisSettings.min = min;
			_yAxisSettings.max = max;
			update();
		}
		
		public function getYAxisRange():Object {
			return {min: _yAxisSettings.min, max: _yAxisSettings.max};			
		}
		
		public function setPlotDimensions(w:Number, h:Number):void {
			if (!isFinite(w) || isNaN(w) || !isFinite(w) || isNaN(w) || w<=0 || h<=0) return;
			_xAxisSettings.length = w;
			_yAxisSettings.length = h;
			updateCheckeredArea();
			updateBackgroundAndBorder();
			update();
		}
		
		public var checkeredPatternColor1:uint = 0x50d0d0d0;
		public var checkeredPatternColor2:uint = 0x50a0a0a0;
		public var checkeredPatternSize:uint = 2;
		
		import flash.display.BitmapData;
		import flash.geom.Rectangle;
		
		protected function updateCheckeredArea():void {
			_checkeredAreaSP.graphics.clear();
			
			var fillRect:Rectangle = new Rectangle(0, 0, checkeredPatternSize, checkeredPatternSize);
			var patternBMD:BitmapData = new BitmapData(2*checkeredPatternSize, 2*checkeredPatternSize, true);
			patternBMD.fillRect(fillRect, checkeredPatternColor1);
			fillRect.x = checkeredPatternSize;
			patternBMD.fillRect(fillRect, checkeredPatternColor2);
			fillRect.y = checkeredPatternSize;
			patternBMD.fillRect(fillRect, checkeredPatternColor1);
			fillRect.x = 0;
			patternBMD.fillRect(fillRect, checkeredPatternColor2);
			
			_checkeredAreaSP.graphics.clear();
			_checkeredAreaSP.graphics.moveTo(0, 0);
			_checkeredAreaSP.graphics.beginBitmapFill(patternBMD);
			_checkeredAreaSP.graphics.lineTo(_xAxisSettings.length, 0);
			_checkeredAreaSP.graphics.lineTo(_xAxisSettings.length, -_yAxisSettings.length);
			_checkeredAreaSP.graphics.lineTo(0, -_yAxisSettings.length);
			_checkeredAreaSP.graphics.lineTo(0, 0);
			_checkeredAreaSP.graphics.endFill();
		}
		
		public function getPlotDimensions():Object {
			return {width: _xAxisSettings.length, height: _yAxisSettings.length};			
		}
		
		public function lock():void {
			locked = true;			
		}
		
		public function unlock():void {
			locked = false;			
		}
		
		public function get locked():Boolean {
			return _locked;
		}
		
		public function set locked(arg:Boolean):void {
			_locked = arg;
			if (!_locked) update();
		}
		

		
		public function get xMin():Number {
			return _xAxisSettings.min;			
		}
		
		public function set xMin(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg>=xMax) return;
			// clear any zoom window and stop the zoom animation if in effect
			clearZoomWindow();
			cancelZoomAnimation();			
			_xAxisSettings.min = arg;
			update();
		}
		
		public function get xMax():Number {
			return _xAxisSettings.max;			
		}
		
		public function set xMax(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=xMin) return;
			// clear any zoom window and stop the zoom animation if in effect
			clearZoomWindow();
			cancelZoomAnimation();			
			_xAxisSettings.max = arg;
			update();
		}
				
		public function get yMin():Number {
			return _yAxisSettings.min;			
		}
		
		public function set yMin(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg>=yMax) return;
			// clear any zoom window and stop the zoom animation if in effect
			clearZoomWindow();
			cancelZoomAnimation();			
			_yAxisSettings.min = arg;
			update();
		}
		
		public function get yMax():Number {
			return _yAxisSettings.max;			
		}
		
		public function set yMax(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=yMin) return;
			// clear any zoom window and stop the zoom animation if in effect
			clearZoomWindow();
			cancelZoomAnimation();			
			_yAxisSettings.max = arg;
			update();
		}		
		
		public function get invertXAxis():Boolean {
			return _xAxisSettings.inverted;
		}
		
		public function set invertXAxis(arg:Boolean):void {
			_xAxisSettings.inverted = arg;
			update();			
		}
		
		public function get invertYAxis():Boolean {
			return _yAxisSettings.inverted;			
		}
		
		public function set invertYAxis(arg:Boolean):void {
			_yAxisSettings.inverted = arg;
			update();			
		}
		
		public function get plotWidth():Number {
			return _xAxisSettings.length;			
		}
		
		public function set plotWidth(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_xAxisSettings.length = arg;
			updateCheckeredArea();
			updateBackgroundAndBorder();
			update();
		}
		
		public function get plotHeight():Number {
			return _yAxisSettings.length;			
		}
		
		public function set plotHeight(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_yAxisSettings.length = arg;
			updateCheckeredArea();
			updateBackgroundAndBorder();
			update();
		}
		
		public function get zoomMode():String {
			return _zoomMode;			
		}
		
		public function set zoomMode(arg:String):void {
			setZoomMode(arg);			
		}
		
	}
	
}

internal class AxisSettingsObject {
	public var min:Number = 0;
	public var max:Number = 10;
	public var length:Number = 300;
	public var minSpacingForTickmarks:Number = 10;
	public var minSpacingForLabels:Number = 30;
	public var inverted:Boolean = false;
}
