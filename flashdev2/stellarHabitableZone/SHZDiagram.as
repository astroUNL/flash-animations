
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
		
	public class SHZDiagram extends Sprite {
		
		public var backgroundColor:uint = 0x000000;
		public var backgroundAlpha:Number = 1;
		public var borderThickness:Number = 1;
		public var borderColor:uint = 0x909090;
		public var borderAlpha:Number = 1;
		
		protected var _backgroundSH:Shape;
		protected var _diagramSP:Sprite;
		protected var _maskSH:Shape;
		protected var _borderSH:Shape;
		
		protected var _zoomerSP:Sprite;
		
		protected var _w:Number;
		protected var _h:Number;
		
		protected var _zonesSP:Sprite;
		protected var _zoneLabelsSP:Sprite;
		protected var _planet:SHZDiagramPlanet;
		protected var _star:SHZDiagramStar;		
		protected var _grid:SHZDiagramGrid;
		protected var _scalebar:SHZDiagramScalebar;
		protected var _refOrbits:Sprite;
		
		protected var _planetDragXOffset:Number;
		protected var _planetDragTimer:Timer;
		protected var _planetDragX:Number;
		protected var _planetDragMinX:Number;
		protected var _planetDragMaxX:Number;
		
		protected var _planetDragMaxDistance:Number = 300;
		protected var _planetDragMinDistance:Number = 0.01;
		
		
		protected var _planetDistance:Number = 2;
		protected var _easingTime:Number = 500;
		protected var _easer:CubicEaser;	
		protected var _planetTargetX:Number;		
		protected var _easingTimer:Timer;		
		
		// the hard margins are the distances (in pixels) from the star (on the left) and
		// from the right edge that the planet can never be dragged beyond
		protected var _planetDragLeftXHardMargin:Number = 135;
		protected var _planetDragRightXHardMargin:Number = 30;
		
		// the soft margins are the distances from the left and right edges of the dragging hard range that,
		// if the planet is dragged beyond, will cause the diagram to zoom in or out to bring the
		// planet back within the range; these distances are expressed as fractions of the hard range
		protected var _planetLeftXSoftMargin:Number = 0.15;
		protected var _planetRightXSoftMargin:Number = 0.35;
		
		protected var _planetZoomMinX:Number;
		protected var _planetZoomMaxX:Number;
		
		// safe radius is a distance away from the star guaranteed to be outside the diagram window
		protected var _safeRadius:Number;
		
		// scale in px/au
		protected var _scale:Number = Number.NaN;
		
		// the position of the star from the left edge
		public const starX:Number = 130;
		
		protected var _easeStopTime:Number;
		
		
		public function SHZDiagram(w:Number, h:Number) {
			
			_w = w;
			_h = h;
			
			_planetTargetX = _w/2;
			
			_safeRadius = 1.1*Math.sqrt((_h*_h/4) + (_w*_w));
			
			_planetDragMinX = starX + _planetDragLeftXHardMargin;
			_planetDragMaxX = _w - _planetDragRightXHardMargin;
			
			_planetZoomMinX = _planetDragMinX + _planetLeftXSoftMargin*(_planetDragMaxX - _planetDragMinX);
			_planetZoomMaxX = _planetDragMinX + (1-_planetRightXSoftMargin)*(_planetDragMaxX - _planetDragMinX);
			
			_backgroundSH = new Shape();
			_diagramSP = new Sprite();
			_maskSH = new Shape();
			_borderSH = new Shape();
			
			addChild(_backgroundSH);
			addChild(_diagramSP);
			addChild(_maskSH);
			addChild(_borderSH);
			
			_grid = new SHZDiagramGrid(this);
			_grid.x = starX;
			_grid.y = _h/2;
			_grid.visible = false;
			_diagramSP.addChild(_grid);
			
			_zonesSP = new Sprite();
			_zonesSP.x = starX;
			_zonesSP.y = _h/2;
			_diagramSP.addChild(_zonesSP);
			
			_refOrbits = new Sprite();
			_refOrbits.x = starX;
			_refOrbits.y = _h/2;
			_diagramSP.addChild(_refOrbits);
			
			_star = new SHZDiagramStar(this);
			_star.x = starX;
			_star.y = _h/2;
			_diagramSP.addChild(_star);
			
			_zoneLabelsSP = new Sprite();
			_zoneLabelsSP.x = starX;
			_zoneLabelsSP.y = _h/2;
			_diagramSP.addChild(_zoneLabelsSP);
			
			_zoomerSP = new Sprite();
			_diagramSP.addChild(_zoomerSP);
			
			_planet = new SHZDiagramPlanet(this);
			_planet.x = _w/2;
			_planet.y = _h/2;
			_diagramSP.addChild(_planet);
			
			_scalebar = new SHZDiagramScalebar(this);
			_scalebar.x = _w - 85;
			_scalebar.y = 23;
			_diagramSP.addChild(_scalebar);
			
			_diagramSP.mask = _maskSH;
			
			_zoomerTimer = new Timer(20);
			_zoomerTimer.stop();
			_zoomerTimer.addEventListener("timer", onZoomerTimerEvent);
			
			_easingTimer = new Timer(20);
			_easingTimer.stop();
			_easingTimer.addEventListener("timer", onEasingTimerEvent);
			
			_planetDragTimer = new Timer(20);
			_planetDragTimer.stop();
			_planetDragTimer.addEventListener("timer", onPlanetDragTimerEvent);
			
			_easer = new CubicEaser(_planetDistance);
			
			_zoomerSP.addEventListener("mouseDown", onZoomerMouseDown);
										   
										   
			drawBackgroundAndBorder();
			setPlanetDistance(2, false);
			setPlanetDraggable(true);
		}
		
		protected var _minZoomerScale:Number = 0.25;
		protected var _maxZoomerScale:Number = 25000;
		
		protected var _zoomerStartX:Number;
		protected var _zoomerFactor:Number = 1.3;
		protected var _zoomerTimer:Timer;
		protected var _zoomerDeadSpace:Number = 95;
		
		protected function onZoomerMouseDown(...ignored):void {
		
			if (_easingTimer.running) _easingTimer.stop();
			_easer.init(Math.log(_scale));
			setScale(_scale);
			
			_zoomerStartX = mouseX;
			_zoomerTimer.start();
			
			stage.addEventListener("mouseUp", onZoomerMouseUp);
		}
		
		protected function onZoomerTimerEvent(evt:TimerEvent):void {
			
			var u:Number;
			if (mouseX>_zoomerStartX) {
				u = (mouseX - (_zoomerStartX + _zoomerDeadSpace))/_w;
				if (u<0) u = 0;
				else if (u>1) u = 1;
			}
			else {
				u = (mouseX - (_zoomerStartX - _zoomerDeadSpace))/_w;
				if (u>0) u = 0;	
				else if (u<-1) u = -1;
			}
			
			var newScale:Number = _scale*Math.pow(_zoomerFactor, -u);
			if (newScale<_minZoomerScale) newScale = _minZoomerScale;
			else if (newScale>_maxZoomerScale) newScale = _maxZoomerScale;
			
			_easer.init(Math.log(newScale));
			setScale(newScale);
			
			evt.updateAfterEvent();			
		}
		
		protected function onZoomerMouseUp(...ignored):void {
			
			_zoomerTimer.stop();
			
			_planetTargetX = _w/2;
			var newScale:Number = (_planetTargetX - starX)/_planetDistance;
			easeToScale(newScale);
			
			stage.removeEventListener("mouseUp", onZoomerMouseUp);
		}
		
		
		public function setPlanetState(isDestroyed:Boolean, isTidallyLocked:Boolean, temperature:Number):void {
			_planet.setState(isDestroyed, isTidallyLocked, temperature);
		}			
		
		public function get scale():Number {
			return _scale;
		}
		
		override public function get width():Number {
			return _w;
		}
		
		override public function get height():Number {
			return _h;
		}
		
		public function get safeRadius():Number {
			return _safeRadius;
		}
		
		public function addRefOrbitsGroup(name:String, normalColor:uint=0, highlightColor:uint=0, baseOffset:Number=25):void {
			var og:SHZDiagramRefOrbits = new SHZDiagramRefOrbits(this, normalColor, highlightColor, baseOffset);
			og.name = name;
			_refOrbits.addChild(og);
		}
		
		public function setRefOrbitsGroup(name:String, list:Array):void {
			(_refOrbits.getChildByName(name) as SHZDiagramRefOrbits).setList(list);			
		}
		
		public function setShowRefOrbitsGroup(name:String, show:Boolean):void {
			_refOrbits.getChildByName(name).visible = show;						
			if (show && _refOrbits.visible) {
				(_refOrbits.getChildByName(name) as SHZDiagramRefOrbits).update();
			}			
		}
		
		public function setHighlightedRefOrbit(name:String, index:int):void {
			(_refOrbits.getChildByName(name) as SHZDiagramRefOrbits).highlightedOrbit = index;			
		}
		
		public function addZone(name:String, innerRadius:Number, outerRadius:Number):void {
			var zone:SHZDiagramZone = new SHZDiagramZone(this, name, innerRadius, outerRadius);
			_zonesSP.addChild(zone);
			_zoneLabelsSP.addChild(zone.label);
		}
		
		public function setZoneRange(name:String, innerRadius:Number, outerRadius:Number):void {
			for (var i:int = 0; i<_zonesSP.numChildren; i++) {
				if (_zonesSP.getChildAt(i).name == name) {
					var z:SHZDiagramZone = (_zonesSP.getChildAt(i) as SHZDiagramZone);
					z.innerRadius = innerRadius;
					z.outerRadius = outerRadius;
					z.update();
					break;
				}
			}
		}
		
		public function setPlanetDraggable(arg:Boolean):void {
			if (arg) {
				_planet.addEventListener("mouseDown", onPlanetMouseDown);
			}
			else {
				_planet.removeEventListener("mouseDown", onPlanetMouseDown);
			}
		}
		
		protected function onPlanetDragTimerEvent(evt:TimerEvent):void {
			
			// the diagram does not actually move the planet, one of the listeners needs to do it
			dispatchEvent(new SHZDiagramEvent("planetDragged", processMouse()));
			
			evt.updateAfterEvent();
		}
		
		protected function processMouse():Number {
			
			// two things restrict the range of the planet on the screen:
			//  - x (pixel) limits: the user can't drag the planet more than a certain amount left or right
			//  - distance limits: the limits in the value of the planet's distance from the star
			
			_planetDragX = mouseX + _planetDragXOffset;
			
			// enforce the drag limits
			if (_planetDragX<_planetDragMinX) _planetDragX = _planetDragMinX;
			else if (_planetDragX>_planetDragMaxX) _planetDragX = _planetDragMaxX;
			
			var newDist:Number = (_planetDragX - starX)/scale;
			
			// enforce the range limits
			// if the planet has reached a range limit set _planetDragX to -1; this causes the updatePlanet
			// function to reposition the planet according to the scale; otherwise, we want the planet to stay
			// where the user has dragged it (that is, _planetDragX)
			if (newDist>_planetDragMaxDistance) {
				newDist = _planetDragMaxDistance;
				_planetDragX = -1;
			}
			else if (newDist<_planetDragMinDistance) {
				newDist = _planetDragMinDistance;
				_planetDragX = -1;
			}
			
			return newDist;			
			
		}
		
		protected function onPlanetMouseDown(...ignored):void {
			_planetDragXOffset = _planet.x - mouseX;
			_planetDragX = starX + _planetDistance*_scale;
			stage.addEventListener("mouseUp", onPlanetMouseUp);
			_planetDragTimer.start();
		}
		
		protected function onPlanetMouseUp(...ignored):void {
			stage.removeEventListener("mouseUp", onPlanetMouseUp);
			_planetDragTimer.stop();
			
			dispatchEvent(new SHZDiagramEvent("planetDraggingStopped", processMouse()));
			
			// not that we're done dragging, we need to update the planet's position
			// according to its calculated position (on not that based on the mouse position)
			updatePlanet();
		}
		
		public function setPlanetDragLimits(min:Number, max:Number):void {			
			_planetDragMinDistance = min;
			_planetDragMaxDistance = max;
		}
		
		public function getPlanetDistance():Number {
			return _planetDistance;			
		}
		
		public function setPlanetDistance(arg:Number, useEasing:Boolean=true):void {
			// this function does not enforce distance limits, but does enforce the
			// zoom range limits when easing is enabled
			
			_planetDistance = arg;
			
			if (useEasing) {
				var newX:Number = _planetDistance*scale + starX;
				if (newX<_planetZoomMinX) {
					_planetTargetX = _planetZoomMinX;
				}
				else if (newX>_planetZoomMaxX) {
					_planetTargetX = _planetZoomMaxX;
				}
				else {
					// even if easing is enabled no easing is used if the planet position is in the inner region
					_planetTargetX = newX;
					useEasing = false;
				}
			}
			else {
				_planetTargetX = _w/2;
			}
			
			// now set the scale
			var newScale:Number = (_planetTargetX - starX)/_planetDistance;
			
			if (useEasing) {
				easeToScale(newScale);
			}
			else {
				if (_easingTimer.running) _easingTimer.stop();
				_easer.init(Math.log(newScale));
				setScale(newScale);
			}
		}
		
		public function setStarTemperature(temperature:Number):void {
			_star.temperature = temperature;
			_star.update();
		}		
		
		public function setStarRadiusAndTemperature(radius:Number, temperature:Number):void {
			_star.radius = radius;
			_star.temperature = temperature;
			_star.update();
		}
		
		public function setStarRadius(radius:Number):void {
			_star.radius = radius;
			_star.update();
		}
		
		protected function onEasingTimerEvent(evt:TimerEvent):void {
			var t:Number = getTimer();
			if (t>_easeStopTime) t = _easeStopTime;
			var s:Number = Math.exp(_easer.getValue(t));
			if (t>=_easeStopTime) {
				_easingTimer.stop();
				_easer.init(Math.log(s));
			}
			setScale(s);
			evt.updateAfterEvent();
		}
		
		protected function easeToScale(newScale:Number):void {
			if (newScale!=_scale) {
				var timeNow = getTimer();
				_easeStopTime = timeNow + _easingTime;
				_easer.setTarget(timeNow, Number.NaN, _easeStopTime, Math.log(newScale));
				if (!_easingTimer.running) _easingTimer.start();
			}
			else {
				if (_easingTimer.running) _easingTimer.stop();
				setScale(newScale);
			}
		}
		
		protected function setScale(arg:Number):void {
			_scale = arg;
			update();
		}
		
		public function update():void {
			if (_grid.visible) _grid.update();
			var i:int;
			if (_refOrbits.visible) {
				for (i=0; i<_refOrbits.numChildren; i++) {
					if (_refOrbits.getChildAt(i).visible) (_refOrbits.getChildAt(i) as SHZDiagramRefOrbits).update();
				}
			}
			_scalebar.update();
			for (i=0; i<_zonesSP.numChildren; i++) {
				(_zonesSP.getChildAt(i) as SHZDiagramZone).update();
			}
			_star.update();
			updatePlanet();
		}
		
		public function get planetBeingDragged():Boolean {
			return _planetDragTimer.running;
		}
		
		protected function updatePlanet():void {
			if (_planetDragTimer.running && _planetDragX>0) {
				_planet.x = _planetDragX;
			}
			else {
				_planet.x = starX + _planetDistance*_scale;
			}
			
			// when the planet is positioned left of its normal dragging range scale it down so 
			// that it doesn't look ridiculous next to the star
			_planet.scaleX = _planet.scaleY = (_planet.x>=_planetDragMinX) ? 1 : Math.pow((_planet.x-starX)/(_planetDragMinX-starX), 0.4);
		}
		
		public function get showZones():Boolean {
			return _zonesSP.visible;			
		}
		
		public function set showZones(arg:Boolean):void {
			_zoneLabelsSP.visible = arg;
			_zonesSP.visible = arg;			
		}
		
		public function get showStar():Boolean {
			return _star.visible;
		}
		
		public function set showStar(arg:Boolean):void {
			_star.visible = arg;
		}
		
		public function get showGrid():Boolean {
			return _grid.visible;
		}
		
		public function set showGrid(arg:Boolean):void {
			_grid.visible = arg;
			if (arg) _grid.update();
		}
		
		public function get showRefOrbits():Boolean {
			return _refOrbits.visible;
		}
		
		public function set showRefOrbits(arg:Boolean):void {
			_refOrbits.visible = arg;
			
			var i:int;
			if (_refOrbits.visible) {
				for (i=0; i<_refOrbits.numChildren; i++) {
					if (_refOrbits.getChildAt(i).visible) (_refOrbits.getChildAt(i) as SHZDiagramRefOrbits).update();
				}
			}
			
		}
		
		protected function drawBackgroundAndBorder():void {
			with (_backgroundSH.graphics) {
				clear();
				beginFill(backgroundColor, backgroundAlpha);
				drawRect(0, 0, _w, _h);
				endFill();
			}
			with (_zoomerSP.graphics) {
				clear();
				beginFill(0x00ff00, 0);
				drawRect(0, 0, _w, _h);
				endFill();
			}
			with (_maskSH.graphics) {
				clear();
				beginFill(0xff0000);
				drawRect(0, 0, _w, _h);
				endFill();
			}
			with (_borderSH.graphics) {
				clear();
				lineStyle(borderThickness, borderColor, borderAlpha);
				drawRect(0, 0, _w, _h);
			}			
		}
		
	}	
}

