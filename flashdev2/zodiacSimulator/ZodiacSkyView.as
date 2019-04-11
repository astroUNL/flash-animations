
// the projection used here is Lambert azimuthal equal-area projection
// http://en.wikipedia.org/wiki/Lambert_azimuthal_equal-area_projection

// note _constellationsData is defined in a separate file due to size (the include is at the bottom of this class)

package {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
			
	import flash.geom.Point;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.geom.PerspectiveProjection;
			
	import flash.geom.Matrix;
	
	public class ZodiacSkyView extends Sprite {
		
		private var _size:Number = 300;
		
		private const _eclipticThickness:Number = 2;
		private const _celestialEquatorThickness:Number = 2;
		
		private const _eclipticColor:uint = 0xfff0a0;
		private const _celestialEquatorColor:uint = 0x8080ff;
		private const _gridColor:uint = 0xffffff;
			
		private const _normalGridAlpha:Number = 0.09;
		private const _centralMeridianAlpha:Number = 0.25;
		private const _celestialEquatorAlpha:Number = 0.5;
		private const _eclipticAlpha:Number = 0.5;
		
		private var _southLabel:SouthLabel;
		private var _eastLabel:EastLabel;
		private var _westLabel:WestLabel;
	
		private var _sky:Shape;
		private var _grid:Shape;
		private var _ecliptic:Shape;
		private var _constellations:Shape;
		private var _sun:Sun;
		private var _horizon:Shape;
		private var _horizonMask:Shape;

		private var _maskedContent:Sprite;
		private var _mask:Shape;
		
		private var _celestialEquatorLabel:CelestialEquatorLabel;
		private var _eclipticLabel:EclipticLabel;
		
		private var _constellationLabels:Sprite;
		
////		private var _graphics:Sprite;
		
		public function ZodiacSkyView(width:Number=300) {
			
			_mask = new Shape();
			addChild(_mask);
						
			_maskedContent = new Sprite();
			_maskedContent.mask = _mask;
			addChild(_maskedContent);
			
			
			_sky = new Shape();
			
			_maskedContent.addChild(_sky);
			
			_grid = new Shape();
			_maskedContent.addChild(_grid);
			
			_ecliptic = new Shape();
			_maskedContent.addChild(_ecliptic);
			
			var mc:MovieClip;
			
			var proj:PerspectiveProjection = new PerspectiveProjection();
			proj.projectionCenter = new Point(0, 0);
			proj.fieldOfView = 1;
			
			_celestialEquatorLabel = new CelestialEquatorLabel();
			_celestialEquatorLabel.transform.perspectiveProjection = proj;
			_celestialEquatorLabel.transform.matrix3D = new Matrix3D();			
			_maskedContent.addChild(_celestialEquatorLabel);
			
			_eclipticLabel = new EclipticLabel();
			_eclipticLabel.transform.perspectiveProjection = proj;
			_eclipticLabel.transform.matrix3D = new Matrix3D();			
			_maskedContent.addChild(_eclipticLabel);
			
			
////			_graphics = new Sprite();
////			for each (var c:Object in zodiacGraphics) {
////				mc = new (getDefinitionByName(c.name+"GraphicNoStars") as Class);
////				mc.transform.perspectiveProjection = proj;
////				mc.transform.matrix3D = new Matrix3D();
////				_graphics.addChild(mc);
////				c.mc = mc;
////			}
////			_maskedContent.addChild(_graphics);
			
			_constellations = new Shape();
			_maskedContent.addChild(_constellations);
			
			_constellationLabels = new Sprite();
			_maskedContent.addChild(_constellationLabels);			

			var label:ConstellationLabel;
			for each (var cObj:Object in _constellationsData) {
				label = new ConstellationLabel();
				label.labelField.text = cObj.name;
				cObj.label = label;
				_constellationLabels.addChild(label);
			}			 
				 
			_sun = new Sun();
			_sun.transform.perspectiveProjection = proj;
			_sun.transform.matrix3D = new Matrix3D();
			_maskedContent.addChild(_sun);
			
			_horizonMask = new Shape();
			_maskedContent.addChild(_horizonMask);
			
			_horizon = new Shape();
			_horizon.mask = _horizonMask;
			_maskedContent.addChild(_horizon);
			
			_southLabel = new SouthLabel();
			_southLabel.transform.perspectiveProjection = proj;
			_southLabel.transform.matrix3D = new Matrix3D();
			_maskedContent.addChild(_southLabel);
			
			_eastLabel = new EastLabel();
			_eastLabel.transform.perspectiveProjection = proj;
			_eastLabel.transform.matrix3D = new Matrix3D();
			_maskedContent.addChild(_eastLabel);
			
			_westLabel = new WestLabel();
			_westLabel.transform.perspectiveProjection = proj;
			_westLabel.transform.matrix3D = new Matrix3D();
			_maskedContent.addChild(_westLabel);
			
			setWidth(width);
			init();
		}
		
		// changing center or latitude may produce unintended consequences
		private const _centerAzimuth:Number = Math.PI;
		private const _centerAltitude:Number = -0.1;			
		private const _latitude:Number = 41*Math.PI/180;
		
		private var _siderealTime:Number = 0;
		private var _ySouth:Number = 0;
		private var _sunAltitude:Number = 0;
		private const _twilightRange:Number = 7*Math.PI/180;
		
		public function get showEclipticLabel():Boolean {
			return _eclipticLabel.visible;			
		}
		
		public function set showEclipticLabel(show:Boolean):void {
			_eclipticLabel.visible = show;				
		}
		
		public function get showCelestialEquatorLabel():Boolean {
			return _celestialEquatorLabel.visible;			
		}
		
		public function set showCelestialEquatorLabel(show:Boolean):void {
			_celestialEquatorLabel.visible = show;				
		}
		
		public function get showConstellationLabels():Boolean {
			return _constellationLabels.getChildAt(0).visible;			
		}
		
		public function set showConstellationLabels(show:Boolean):void {
			for (var i:int = 0; i<_constellationLabels.numChildren; i++) {
				_constellationLabels.getChildAt(i).visible = show;				
			}			
		}
		
		public function setSiderealTime(st:Number):void {
			_siderealTime = (st%1)*2*Math.PI;
			updateConstants();
			update();
		}		
		
		override public function set width(w:Number):void {
			setWidth(w);
		}
		
		override public function set height(h:Number):void {
			// no
		}
		
		override public function get width():Number {
			return _width;
		}
		
		override public function get height():Number {
			return _height;
		}
		
		private var _width:int, _height:int, _offset:int;
		
		public function setWidth(width:int):void {
			_width = width;
			
			_height = 0.54*_width;
			_offset = 0.49*_width;
			_size = 1.07*_width;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(-_width/2, -_offset, _width, _height);
			_mask.graphics.endFill();
			
			_mask.x = _maskedContent.x = _width/2;
			_mask.y = _maskedContent.y = _offset;
			
			updateConstants();
			update();
		}
		
		
		private var _locked:Boolean = false;
		
		public function lock():void {
			_locked = true;
		}
		
		public function unlock():void {
			_locked = false;
			if (!_locked) update();
		}
		
		
		private function updateConstellations():void {
			
			var i:int;
			var op:Object;
			var wx:Number, wy:Number, wz:Number;
			var k:Number;
			var cwx:Number, cwy:Number, cwz:Number;
			var ck:Number;
			var cc:CelestialCoord = new CelestialCoord();
			var alt:Number;
			
			var g:Graphics = _constellations.graphics;
			g.clear();
			
			for each (var cObj:Object in _constellationsData) {
				
				// verify that the constellation is potentially in view
				cc.ra = cObj.ra;
				cc.dec = cObj.dec;
				alt = getAltitudeFromCelestialCoord(cc);
				if (alt<(-cObj.r)) continue;

//var i:int;
//var n:int = 500;
//var step:Number = 2*Math.PI/n;
				
				for (i=0; i<cObj.ops.length; i++) {
					op = cObj.ops[i];
					switch (op.t) {
						case 0:
							// moveTo
							wx = _ctw0*op.x + _ctw1*op.y + _ctw2*op.z;
							wy = _ctw3*op.x + _ctw4*op.y + _ctw5*op.z;
							wz = _ctw6*op.x + _ctw7*op.y + _ctw8*op.z;
							k = _scaleFactor*Math.sqrt(2/(1+wx));
							g.moveTo(-k*wy, -k*wz);
							break;
						case 1:
							// lineTo
							wx = _ctw0*op.x + _ctw1*op.y + _ctw2*op.z;
							wy = _ctw3*op.x + _ctw4*op.y + _ctw5*op.z;
							wz = _ctw6*op.x + _ctw7*op.y + _ctw8*op.z;
							k = _scaleFactor*Math.sqrt(2/(1+wx));
							g.lineTo(-k*wy, -k*wz);
							break;
						case 2:
							// curveTo
							wx = _ctw0*op.x + _ctw1*op.y + _ctw2*op.z;
							wy = _ctw3*op.x + _ctw4*op.y + _ctw5*op.z;
							wz = _ctw6*op.x + _ctw7*op.y + _ctw8*op.z;
							k = _scaleFactor*Math.sqrt(2/(1+wx));
							cwx = _ctw0*op.cx + _ctw1*op.cy + _ctw2*op.cz;
							cwy = _ctw3*op.cx + _ctw4*op.cy + _ctw5*op.cz;
							cwz = _ctw6*op.cx + _ctw7*op.cy + _ctw8*op.cz;
							ck = _scaleFactor*Math.sqrt(2/(1+cwx));
							g.curveTo(-ck*cwy, -ck*cwz, -k*wy, -k*wz);
							break;
						case 3:
							// beginFill
							g.beginFill(op.c);
							break;
						case 4:
							// endFill
							g.endFill();
							break;
						case 5:
							// lineStyle
							g.lineStyle(1, op.c);
							break;
						case 6:
							// lineStyle()
							g.lineStyle();	
							break;
					}				
				}
			}
		}
		
		private function update():void {
			var startTimer:Number = getTimer();
			if (_locked) return;
			updateSun(); // must come first
			updateSky();
			updateHorizon();
			updateEcliptic();
////			updateGraphics();
			updateConstellations();
			updateConstellationLabels();
			updateCelestialEquatorAndEclipticLabels();
			trace("update: "+(getTimer()-startTimer));
		}
		
		private function updateCelestialEquatorAndEclipticLabels():void {
			
			var cc:CelestialCoord = new CelestialCoord();
			var sc:ScreenCoord = new ScreenCoord();
			
			var offset:Number = 0.6;
			
			cc.ra = _siderealTime - offset;
			cc.dec = 0.04;
			_celestialEquatorLabel.transform.matrix3D.identity();
			projectDisplayObject(_celestialEquatorLabel, cc, false);
			
			cc.ra = _siderealTime + offset;
			cc.dec = 0.06 + (23.5*Math.PI/180)*Math.sin(_siderealTime+offset); // approx
			_eclipticLabel.transform.matrix3D.identity();
			projectDisplayObject(_eclipticLabel, cc, false);
			_eclipticLabel.rotation += 18*Math.cos(_siderealTime+offset); // arbitrary
		}
		
		private function updateHorizon():void {
			
			var topColor:uint = getInterpolatedColor(_horizonNightTop, _horizonDayTop, _twilightIntensity);
			var bottomColor:uint = getInterpolatedColor(_horizonNightBottom, _horizonDayBottom, _twilightIntensity);
			drawGradientBox(_horizon.graphics, -_width/2, _ySouth, _width, _height-_offset-_ySouth, topColor, bottomColor);
			return;
			
//			// these are the color components that define the horizon
//			// variable naming code:
//			//  n, d - night or day
//			//  t, b - top or bottom
//			//  r, g, b - red, green, or blue component			
//			var ntr:uint = 0x16;
//			var ntg:uint = 0x1f;
//			var ntb:uint = 0x14;
//			var nbr:uint = 0x35;
//			var nbg:uint = 0x47;
//			var nbb:uint = 0x30;
//			var dtr:uint = 0x5a;
//			var dtg:uint = 0x7a;
//			var dtb:uint = 0x52;
//			var dbr:uint = 0x77;
//			var dbg:uint = 0x97;
//			var dbb:uint = 0x68;
//			
//			// u: 0 = full night, 0..1 = twilight, 1 = full day
//			var u:Number = (_twilightRange+_sunAltitude)/_twilightRange;
//			if (u>1) u = 1;
//			else if (u<0) u = 0;
//			
//			var tr:uint = ntr + u*(dtr-ntr);
//			var tg:uint = ntg + u*(dtg-ntg);
//			var tb:uint = ntb + u*(dtb-ntb);
//			var br:uint = nbr + u*(dbr-nbr);
//			var bg:uint = nbg + u*(dbg-nbg);
//			var bb:uint = nbb + u*(dbb-nbb);
//			
//			var g:Graphics = _horizon.graphics;
//			g.clear();
//			var colors:Array = [(br<<16)|(bg<<8)|bb, (tr<<16)|(tg<<8)|tb];
//			var alphas:Array = [1, 1];
//			var ratios:Array = [0x00, 0xff];
//			var matrix:Matrix = new Matrix();
//			var h:Number = _height-_offset-_ySouth;
//			matrix.createGradientBox(_width, h, -Math.PI/2, -_width/2, _ySouth);
//			g.beginGradientFill("linear", colors, alphas, ratios, matrix);
//			g.drawRect(-_width/2, _ySouth, _width, h);
//			g.endFill();
		}
		
		// twilightIntensity: 0 = full night, 0..1 = twilight, 1 = full day
		private var _twilightIntensity:Number = 0;
		
		private const _horizonNightTop:RGB = new RGB(0x16, 0x1f, 0x14);
		private const _horizonNightBottom:RGB = new RGB(0x35, 0x47, 0x30);
		private const _horizonDayTop:RGB = new RGB(0x5a, 0x7a, 0x52);
		private const _horizonDayBottom:RGB = new RGB(0x77, 0x97, 0x68);		
		
		private const _skyNightTop:RGB = new RGB(0x00, 0x00, 0x00);
		private const _skyNightBottom:RGB = new RGB(0x30, 0x35, 0x47);
		private const _skyDayTop:RGB = new RGB(0x7d, 0xac, 0xf0);
		private const _skyDayBottom:RGB = new RGB(0xaf, 0xbc, 0xd8);
		
		private function getInterpolatedColor(color0:RGB, color1:RGB, u:Number):uint {
			var r:uint = color0.r + u*(color1.r-color0.r);
			var g:uint = color0.g + u*(color1.g-color0.g);
			var b:uint = color0.b + u*(color1.b-color0.b);
			return (r<<16)|(g<<8)|b;			
		}
		
		private function drawGradientBox(g:Graphics, x:Number, y:Number, w:Number, h:Number, topColor:uint, bottomColor:uint):void {
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(w, h, -Math.PI/2, x, y);
			g.clear();
			g.beginGradientFill("linear", [bottomColor, topColor], [1, 1], [0x00, 0xff], matrix);
			g.drawRect(x, y, w, h);
			g.endFill();
		}
		
		private function updateSky():void {
			var topColor:uint = getInterpolatedColor(_skyNightTop, _skyDayTop, _twilightIntensity);
			var bottomColor:uint = getInterpolatedColor(_skyNightBottom, _skyDayBottom, _twilightIntensity);
			drawGradientBox(_sky.graphics, -_width/2, -_offset, _width, _height, topColor, bottomColor);
		}		
		
		
		private function updateEcliptic():void {
			
			var i:int, j:int, n:int, m:int;
			
			var cc:CelestialCoord = new CelestialCoord();
			var sc:ScreenCoord = new ScreenCoord();
			
			var g:Graphics = _ecliptic.graphics;
			g.clear();
			g.lineStyle(_eclipticThickness, _eclipticColor, _eclipticAlpha);
			
			// ecliptic
			n = 500;
			var longStep:Number = 2*Math.PI/n;
			var long:Number = 0;
			var sl:Number;
			sl = Math.sin(long);
			cc.dec = Math.asin(sl*_sinObliquity);
			cc.ra = Math.atan2(sl*_cosObliquity, Math.cos(long));
			projectCelestialToScreen(cc, sc);
			g.moveTo(sc.x, sc.y);
			long += longStep;
			for (i=0; i<n; i++) {
				sl = Math.sin(long);
				cc.dec = Math.asin(sl*_sinObliquity);
				cc.ra = Math.atan2(sl*_cosObliquity, Math.cos(long));
				projectCelestialToScreen(cc, sc);
				g.lineTo(sc.x, sc.y);
				long += longStep;
			}
			
//			// sun altitude check
//			var azStep:Number, altStep:Number;			
//			var hc:HorizonCoord = new HorizonCoord();
//			n = 12;
//			m = 500;
//			azStep = 2*Math.PI/m;
//			altStep = Math.PI/n;
//			hc.alt = _sunAltitude;
//			hc.az = 0;
//			projectHorizonToScreen(hc, sc);
//			g.moveTo(sc.x, sc.y);
//			hc.az += azStep;
//			for (j=0; j<m; j++) {
//				projectHorizonToScreen(hc, sc);
//				g.lineTo(sc.x, sc.y);
//				hc.az += azStep;
//			}
		}
		
////		private function updateGraphics():void {
////			// constellation graphics
////			var cObj:Object;
////			var cc:CelestialCoord = new CelestialCoord();
////			var s:Number;
////			for each (cObj in zodiacGraphics) {
////				cc.ra = cObj.ra;
////				cc.dec = cObj.dec;
////				s = _size*cObj.relativeScale/(2*Math.PI);
////				cObj.mc.transform.matrix3D.identity();
////				cObj.mc.transform.matrix3D.appendTranslation(-cObj.centerX, -cObj.centerY, 0);
////				cObj.mc.transform.matrix3D.appendScale(s, s, s);
////				cObj.mc.transform.matrix3D.appendRotation(cObj.rotation*180/Math.PI, Vector3D.Z_AXIS);
////				projectDisplayObject(cObj.mc, cc);
////			}
////		}
		
		private function init():void {
			initGrid();
			initHorizon();
			initDirections();
		}
		
		private function initGrid():void {
			// grid includes the az/alt grid and the celestial equator
			
			var i:int, j:int, n:int, m:int;
			var azStep:Number, altStep:Number;
			
			var sc:ScreenCoord = new ScreenCoord();
			var hc:HorizonCoord = new HorizonCoord();
			
			// do the grid
			var g:Graphics = _grid.graphics;
			g.clear();
			
			// semi-meridians of azimuth
			n = 24;
			m = 500;
			azStep = 2*Math.PI/n;
			altStep = Math.PI/m;
			// the az=0 meridian is special since it passes through the point that maps to the perimeter
			hc.alt = Math.PI/2;
			hc.az = 0;
			projectHorizonToScreen(hc, sc);
			g.moveTo(sc.x, sc.y);
			g.lineStyle(1, _gridColor, _normalGridAlpha);
			g.lineTo(0, -_size/2);			
			hc.az += azStep;
			for (i=1; i<n; i++) {
				hc.alt = -Math.PI/2;
				projectHorizonToScreen(hc, sc);
				g.moveTo(sc.x, sc.y);
				g.lineStyle(1, _gridColor, (i==(n/2)) ? _centralMeridianAlpha : _normalGridAlpha); // more solid central meridian
				hc.alt += altStep;
				for (j=1; j<m; j++) {
					projectHorizonToScreen(hc, sc);
					g.lineTo(sc.x, sc.y);
					hc.alt += altStep;
				}
				hc.az += azStep;
			}
			
			// parallels of altitude
			g.lineStyle(1, _gridColor, _normalGridAlpha);
			n = 12;
			m = 500;
			azStep = 2*Math.PI/m;
			altStep = Math.PI/n;
			hc.alt = altStep;
			for (i=0; i<(n/2)-1; i++) {
				hc.az = 0;
				projectHorizonToScreen(hc, sc);
				g.moveTo(sc.x, sc.y);
				hc.az += azStep;
				for (j=0; j<m; j++) {
					projectHorizonToScreen(hc, sc);
					g.lineTo(sc.x, sc.y);
					hc.az += azStep;
				}
				hc.alt += altStep;
			}
			
			var raStep:Number;
			var cc:CelestialCoord = new CelestialCoord();
			
			// celestial equator
			g.lineStyle(_celestialEquatorThickness, _celestialEquatorColor, _celestialEquatorAlpha);
			n = 500;
			raStep = 2*Math.PI/n;
			cc.dec = 0;
			cc.ra = 0;
			projectCelestialToScreen(cc, sc);
			g.moveTo(sc.x, sc.y);
			cc.ra += raStep;
			for (i=0; i<n; i++) {
				projectCelestialToScreen(cc, sc);
				g.lineTo(sc.x, sc.y);
				cc.ra += raStep;
			}
		}
		
		private function initHorizon():void {
			
			var i:int;
			var sc:ScreenCoord = new ScreenCoord();
			var hc:HorizonCoord = new HorizonCoord();		
			
			var n:int = 500;
			var azStep:Number = 2*Math.PI/n;
			
			hc.alt = 0;
			hc.az = Math.PI;
			projectHorizonToScreen(hc, sc);
			
			_ySouth = sc.y;
			
			var g:Graphics = _horizonMask.graphics;
			g.clear();
			g.beginFill(0xff00ff, 0.5);
			g.moveTo(sc.x, sc.y);
			hc.az += azStep;
			for (i=0; i<n; i++) {
				projectHorizonToScreen(hc, sc);
				g.lineTo(sc.x, sc.y);
				hc.az += azStep;
			}
			g.endFill();
		}
		
		private function initDirections():void {
			
			var hc:HorizonCoord = new HorizonCoord();		
			hc.alt = 5*Math.PI/180;
			
			hc.az = Math.PI;
			_southLabel.transform.matrix3D.identity();
			projectDisplayObject(_southLabel, hc, false);
			
		// arbitrary number, will need to change for different window sizes
			_southLabel.y += 30;
			
			hc.az = Math.PI/2;
			_eastLabel.transform.matrix3D.identity();
			projectDisplayObject(_eastLabel, hc, false);
			
			hc.az = 3*Math.PI/2;
			_westLabel.transform.matrix3D.identity();
			projectDisplayObject(_westLabel, hc, false);
			trace(_eastLabel.height);
			
		// arbitrary number, will need to change for different window sizes
			_eastLabel.y += 40;
			_westLabel.y += 40;
			
			_eastLabel.rotation += -5;
			_westLabel.rotation += 5;
		}
		
		
		
		/*******************************************/
		
		
		
		private const _obliquity:Number = 23.5*Math.PI/180;
		private const _sinObliquity:Number = Math.sin(_obliquity);
		private const _cosObliquity:Number = Math.cos(_obliquity);
		
		private function updateSun():void {
			
			var cc:CelestialCoord = new CelestialCoord();
			var sinLongitude:Number = Math.sin(_sunLongitude);
			cc.dec = Math.asin(sinLongitude*_sinObliquity);
			cc.ra = Math.atan2(sinLongitude*_cosObliquity, Math.cos(_sunLongitude));	
			_sun.transform.matrix3D.identity();
			projectDisplayObject(_sun, cc, false);
			
			_sunAltitude = getAltitudeFromCelestialCoord(cc);
			
			_twilightIntensity = (_twilightRange+_sunAltitude)/_twilightRange;
			if (_twilightIntensity>1) _twilightIntensity = 1;
			else if (_twilightIntensity<0) _twilightIntensity = 0;
		}
		
		/**
		* sunLongitude is the ecliptic longitude of the sun, in radians.
		*/
		public function set sunLongitude(longitude:Number):void {
			_sunLongitude = longitude;
			update();
		}
		
		private var _sunLongitude:Number = 0;

		
		private function projectDisplayObject(dObj:DisplayObject, coord:*, doScaling:Boolean=true):void {
			
			// any display object passed to this function must have the
			// transform.perspectiveProjection and transform.matrix3D properties defined
			
			// just as importantly, the transform.matrix3D.identity() function should be called before
			// passing to this function
			
			var sc:ScreenCoord = new ScreenCoord();
			var rsc:ScreenCoord = new ScreenCoord();
			var lsc:ScreenCoord = new ScreenCoord();
			var asc:ScreenCoord = new ScreenCoord();
			var bsc:ScreenCoord = new ScreenCoord();
			var xscale:Number, yscale:Number;
			var rot:Number;
			
			var delta:Number = 0.1*Math.PI/180;
			var u:Number = delta*_size/(2*Math.PI);
			
			if (coord is CelestialCoord) {
				
				var cc:CelestialCoord = coord as CelestialCoord;
				var ccDelta:CelestialCoord = new CelestialCoord();
				
				projectCelestialToScreen(cc, sc);
				
				// right
				ccDelta.ra = cc.ra - delta;
				ccDelta.dec = cc.dec;
				projectCelestialToScreen(ccDelta, rsc);
				
				// left
				ccDelta.ra = cc.ra + delta;
				ccDelta.dec = cc.dec;
				projectCelestialToScreen(ccDelta, lsc);
				
				// above
				ccDelta.ra = cc.ra;
				ccDelta.dec = cc.dec + delta;
				projectCelestialToScreen(ccDelta, asc);
				
				// below
				ccDelta.ra = cc.ra;
				ccDelta.dec = cc.dec - delta;
				projectCelestialToScreen(ccDelta, bsc);
			}
			else if (coord is HorizonCoord) {
				
				var hc:HorizonCoord = coord as HorizonCoord;
				var hcDelta:HorizonCoord = new HorizonCoord();
				
				projectHorizonToScreen(hc, sc);
				
				// right
				hcDelta.az = hc.az + delta;
				hcDelta.alt = hc.alt;
				projectHorizonToScreen(hcDelta, rsc);
				
				// left
				hcDelta.az = hc.az - delta;
				hcDelta.alt = hc.alt;
				projectHorizonToScreen(hcDelta, lsc);
				
				// above
				hcDelta.az = hc.az;
				hcDelta.alt = hc.alt + delta;
				projectHorizonToScreen(hcDelta, asc);
				
				// below
				hcDelta.az = hc.az;
				hcDelta.alt = hc.alt - delta;
				projectHorizonToScreen(hcDelta, bsc);
			}			
			else return;
			
			if (doScaling) {
				xscale = getScreenDistance(rsc, lsc)/(2*u);
				yscale = getScreenDistance(asc, bsc)/(2*u);	
				
				var fudge:Number = 1 - 0.45*Math.abs(sc.x/_size);
				dObj.transform.matrix3D.appendScale(fudge*xscale, fudge*yscale, 1);
			}
			
			rot = (180/Math.PI)*Math.atan2(rsc.y-sc.y, rsc.x-sc.x);				
			
			dObj.transform.matrix3D.appendRotation(rot, Vector3D.Z_AXIS);
			dObj.transform.matrix3D.appendTranslation(sc.x, sc.y, 0);
		}

		private function getScreenDistance(sc1:ScreenCoord, sc2:ScreenCoord):Number {
			return Math.sqrt((sc1.x-sc2.x)*(sc1.x-sc2.x) + (sc1.y-sc2.y)*(sc1.y-sc2.y));
		}
		
		private function updateConstellationLabels():void {
			var cc:CelestialCoord = new CelestialCoord();
			var sc:ScreenCoord = new ScreenCoord();
			for each (var cObj:Object in _constellationsData) {
				cc.ra = cObj.ra;
				cc.dec = cObj.dec;
				projectCelestialToScreen(cc, sc);
				cObj.label.x = sc.x;
				cObj.label.y = sc.y;
			}
		}
		
		private var _scaleFactor:Number;
		
		private var _htw0:Number, _htw1:Number, _htw2:Number,
					_htw3:Number, _htw4:Number, _htw5:Number,
					_htw6:Number, _htw7:Number, _htw8:Number;
		
		private var _ctw0:Number, _ctw1:Number, _ctw2:Number,
					_ctw3:Number, _ctw4:Number, _ctw5:Number,
					_ctw6:Number, _ctw7:Number, _ctw8:Number;
		
		private function updateConstants():void {
			
			var cp:Number = Math.cos(_centerAltitude);
			var sp:Number = Math.sin(_centerAltitude);
			var ct:Number = Math.cos(_centerAzimuth);
			var st:Number = Math.sin(_centerAzimuth);
			
			_htw0 = cp*ct;
			_htw1 = -cp*st;
			_htw2 = sp;
			_htw3 = st;
			_htw4 = ct;
			_htw5 = 0;
			_htw6 = -sp*ct;
			_htw7 = sp*st;
			_htw8 = cp;
			
			var beta:Number = _latitude - (Math.PI/2);
			var alpha:Number = -_siderealTime;
			
			var cb:Number = Math.cos(beta);
			var sb:Number = Math.sin(beta);
			var ca:Number = Math.cos(alpha);
			var sa:Number = Math.sin(alpha);
			
			var cth0:Number = -cb*ca;
			var cth1:Number = cb*sa;
			var cth2:Number = -sb;
			var cth3:Number = -sa;
			var cth4:Number = -ca;
			var cth5:Number = 0;
			var cth6:Number = -sb*ca;
			var cth7:Number = sb*sa;
			var cth8:Number = cb;
			
			_ctw0 = _htw0*cth0 + _htw1*cth3 + _htw2*cth6;
			_ctw1 = _htw0*cth1 + _htw1*cth4 + _htw2*cth7;
			_ctw2 = _htw0*cth2 + _htw1*cth5 + _htw2*cth8;
			_ctw3 = _htw3*cth0 + _htw4*cth3 + _htw5*cth6;
			_ctw4 = _htw3*cth1 + _htw4*cth4 + _htw5*cth7;
			_ctw5 = _htw3*cth2 + _htw4*cth5 + _htw5*cth8;
			_ctw6 = _htw6*cth0 + _htw7*cth3 + _htw8*cth6;
			_ctw7 = _htw6*cth1 + _htw7*cth4 + _htw8*cth7;
			_ctw8 = _htw6*cth2 + _htw7*cth5 + _htw8*cth8;
			
			_scaleFactor = _size/4;
		}
		
		private function projectCelestialToScreen(cc:CelestialCoord, sc:ScreenCoord):void {
			
			var cl:Number = Math.cos(cc.dec);
			var cx:Number = cl*Math.cos(cc.ra);
			var cy:Number = cl*Math.sin(cc.ra);
			var cz:Number = Math.sin(cc.dec);			
			
			var wx:Number = _ctw0*cx + _ctw1*cy + _ctw2*cz;
			var wy:Number = _ctw3*cx + _ctw4*cy + _ctw5*cz;
			var wz:Number = _ctw6*cx + _ctw7*cy + _ctw8*cz;
			
			if (wx>=1 || wx<=-1) {
				sc.x = Number.NaN;
				sc.y = Number.NaN;
				return;
			}
			
			var k:Number = _scaleFactor*Math.sqrt(2/(1+wx));
			sc.x = -k*wy;
			sc.y = -k*wz;
		}
		
		private function projectCelestialXYZToScreen(pt:Object, sc:ScreenCoord):void {
			var wx:Number = _ctw0*pt.x + _ctw1*pt.y + _ctw2*pt.z;
			var wy:Number = _ctw3*pt.x + _ctw4*pt.y + _ctw5*pt.z;
			var wz:Number = _ctw6*pt.x + _ctw7*pt.y + _ctw8*pt.z;
			
			if (wx>=1 || wx<=-1) {
				sc.x = Number.NaN;
				sc.y = Number.NaN;
				return;
			}
			
			var k:Number = _scaleFactor*Math.sqrt(2/(1+wx));
			sc.x = -k*wy;
			sc.y = -k*wz;
		}
		
		private function getAltitudeFromCelestialCoord(cc:CelestialCoord):Number {
			return Math.asin(Math.sin(cc.dec)*Math.sin(_latitude) + Math.cos(cc.dec)*Math.cos(_siderealTime - cc.ra)*Math.cos(_latitude));
		}
		
		private function projectHorizonToScreen(hc:HorizonCoord, sc:ScreenCoord):void {
			
			var hl:Number = Math.cos(hc.alt);
			var hx:Number = hl*Math.cos(hc.az);
			var hy:Number = -hl*Math.sin(hc.az);
			var hz:Number = Math.sin(hc.alt);
			
			var wx:Number = _htw0*hx + _htw1*hy + _htw2*hz;
			var wy:Number = _htw3*hx + _htw4*hy + _htw5*hz;
			var wz:Number = _htw6*hx + _htw7*hy + _htw8*hz;
			
			if (wx>=1 || wx<=-1) {
				sc.x = Number.NaN;
				sc.y = Number.NaN;
				return;
			}
			
			var k:Number = _scaleFactor*Math.sqrt(2/(1+wx));
			sc.x = -k*wy;
			sc.y = -k*wz;
		}
		
/*
		// zodiacGraphic and constellationsData are only used for testing
		// (note _constellationsData is used, and is in a separate file)
		
		// ra, dec - the approximate center of constellation, ie. the point where the constellation is attached
		// centerX, centerY - the coordinates in the graphic corresponding to the ra and dec point
		// rotation - the cw rotation (in radians) to apply to the graphic so that the ncp is up
		// relativeScale - the relative scale of the graphic, in radians per px
		private const zodiacGraphics:Array = [
							{name: "Leo", ra: 2.792527, dec: 0.286234, centerX: 384.4, centerY: 246.8, rotation: -6.161906, relativeScale: 0.0009997},
							{name: "Gemini", ra: 1.829105, dec: 0.397935, centerX: 345.8, centerY: 291.6, rotation: -1.027916, relativeScale: 0.0008589},
							{name: "Sagittarius", ra: 5.026548, dec: -0.537561, centerX: 515.6, centerY: 277.2, rotation: 0.156371, relativeScale: 0.001017},
							{name: "Capricorn", ra: 5.487315, dec: -0.279253, centerX: 389.5, centerY: 277.9, rotation: 0.322258, relativeScale: 0.0005769},
							{name: "Aries", ra: 0.649262, dec: 0.383972, centerX: 313.9, centerY: 306.2, rotation: 0.535498, relativeScale: 0.0008777},
							{name: "Cancer", ra: 2.247984, dec: 0.363028, centerX: 386.7, centerY: 187.8, rotation: -1.514086, relativeScale: 0.0007252},
							{name: "Virgo", ra: 3.525565, dec: -0.027925, centerX: 202.5, centerY: 260.0, rotation: 1.514994, relativeScale: 0.001780},
							{name: "Pisces", ra: 0.195477, dec: 0.167552, centerX: 326.1, centerY: 230.2, rotation: 1.178905, relativeScale: 0.001654},
							{name: "Scorpio", ra: 4.349360, dec: -0.523599, centerX: 348.3, centerY: 269.7, rotation: -0.836808, relativeScale: 0.0007465},
							{name: "Aquarius", ra: 5.815437, dec: -0.118682, centerX: 200.3, centerY: 328.1, rotation: 0.739613, relativeScale: 0.001631},
							{name: "Taurus", ra: 1.144936, dec: 0.265290, centerX: 338.4, centerY: 347.2, rotation: -0.367903, relativeScale: 0.0009337},
							{name: "Libra", ra: 4.000295, dec: -0.307178, centerX: 219.8, centerY: 305.0, rotation: 0.180040, relativeScale: 0.0006109}];

		private const constellationsData:Array = [	// leo	
							{path: [{m:3,b:0,e:9},{m:7,b:9,e:12},{m:9,b:12,e:13},{m:9,b:13,e:15},
									{m:13,b:0,e:1},{m:13,b:5,e:6},{m:13,b:15,e:16}],
							 stars: [{name: "epsilon", x: -0.7628, y: 0.5056, z: 0.4031},
									 {name: "lambda", x: -0.7347, y: 0.5549, z: 0.3902},
									 {name: "kappa", x: -0.6990, y: 0.5627, z: 0.4412},
									 {name: "mu", x: -0.7637, y: 0.4738, z: 0.4385},
									 {name: "zeta", x: -0.8260, y: 0.3998, z: 0.3974},
									 {name: "gamma1", x: -0.8551, y: 0.3988, z: 0.3312},
									 {name: "60", x: -0.9091, y: 0.2337, z: 0.3450},
									 {name: "delta", x: -0.9178, y: 0.1863, z: 0.3506},
									 {name: "beta", x: -0.9667, y: 0.0461, z: 0.2516},
									 {name: "theta", x: -0.9448, y: 0.1913, z: 0.2660},
									 {name: "iota", x: -0.9710, y: 0.1541, z: 0.1827},
									 {name: "sigma", x: -0.9802, y: 0.1679, z: 0.1050},
									 {name: "rho", x: -0.9163, y: 0.3664, z: 0.1617},
									 {name: "eta", x: -0.8441, y: 0.4520, z: 0.2884},
									 {name: "alpha", x: -0.8644, y: 0.4580, z: 0.2073},
									 {name: "omicron", x: -0.8098, y: 0.5610, z: 0.1718}]},
							// gemini
							{path: [{m:0,b:1,e:10},{m:7,b:10,e:12},{m:3,b:12,e:13},{m:4,b:13,e:14},
									{m:4,b:14,e:16},{m:6,b:16,e:17},{m:6,b:17,e:18}],
							 stars: [{name: "1", x: -0.0166, y: 0.9186, z: 0.3950},
									 {name: "eta", x: -0.0599, y: 0.9219, z: 0.3828},
									 {name: "mu", x: -0.0925, y: 0.9191, z: 0.3829},
									 {name: "epsilon", x: -0.1724, y: 0.8888, z: 0.4247},
									 {name: "tau", x: -0.2639, y: 0.8226, z: 0.5037},
									 {name: "iota", x: -0.3233, y: 0.8234, z: 0.4664},
									 {name: "upsilon", x: -0.3625, y: 0.8148, z: 0.4524},
									 {name: "delta", x: -0.3175, y: 0.8712, z: 0.3743},
									 {name: "zeta", x: -0.2586, y: 0.8998, z: 0.3514},
									 {name: "gamma", x: -0.1573, y: 0.9463, z: 0.2823},
									 {name: "lambda", x: -0.3205, y: 0.9035, z: 0.2847},
									 {name: "xi", x: -0.1914, y: 0.9558, z: 0.2232},
									 {name: "nu", x: -0.1183, y: 0.9309, z: 0.3455},
									 {name: "theta", x: -0.1894, y: 0.8075, z: 0.5586},
									 {name: "rho", x: -0.3222, y: 0.7866, z: 0.5267},
									 {name: "alpha", x: -0.3407, y: 0.7777, z: 0.5283},
									 {name: "beta", x: -0.3915, y: 0.7912, z: 0.4699},
									 {name: "kappa", x: -0.4009, y: 0.8177, z: 0.4131}]},
							// sagittarius
							{path: [{m:5,b:0,e:11},{m:2,b:5,e:6},{m:11,b:8,e:9},{m:11,b:7,e:8},
									{m:15,b:12,e:17},{m:14,b:17,e:19},{m:7,b:12,e:13},{m:6,b:13,e:14}],
							 stars: [{name: "epsilon", x: 0.0869, y: -0.8207, z: -0.5648},
									 {name: "eta", x: 0.0616, y: -0.7988, z: -0.5985},
									 {name: "gamma2", x: 0.0219, y: -0.8620, z: -0.5064},
									 {name: "mu", x: 0.0559, y: -0.9315, z: -0.3593},
									 {name: "lambda", x: 0.1099, y: -0.8965, z: -0.4293},
									 {name: "delta", x: 0.0794, y: -0.8639, z: -0.4974},
									 {name: "phi", x: 0.1764, y: -0.8735, z: -0.4539},
									 {name: "sigma", x: 0.2141, y: -0.8706, z: -0.4430},
									 {name: "pi", x: 0.2798, y: -0.8905, z: -0.3588},
									 {name: "rho1", x: 0.3320, y: -0.8921, z: -0.3065},
									 {name: "upsilon", x: 0.3356, y: -0.9010, z: -0.2749},
									 {name: "xi2", x: 0.2325, y: -0.9035, z: -0.3601},
									 {name: "tau", x: 0.2551, y: -0.8481, z: -0.4644},
									 {name: "zeta", x: 0.2340, y: -0.8349, z: -0.4982},
									 {name: "alpha", x: 0.2717, y: -0.7088, z: -0.6510},
									 {name: "theta1", x: 0.4074, y: -0.7074, z: -0.5775},
									 {name: "iota", x: 0.3589, y: -0.6525, z: -0.6674},
									 {name: "beta1", x: 0.2518, y: -0.6679, z: -0.7004},
									 {name: "beta2", x: 0.2520, y: -0.6633, z: -0.7046}]},							 
							// capricornus
							{path: [{m:3,b:0,e:6},{m:2,b:6,e:10},{m:2,b:8,e:9},{m:6,b:10,e:11},{m:7,b:11,e:13}],
							 stars: [{name: "36", x: 0.7335, y: -0.5692, z: -0.3715},
									 {name: "zeta", x: 0.7251, y: -0.5735, z: -0.3812},
									 {name: "theta", x: 0.6926, y: -0.6576, z: -0.2963},
									 {name: "iota", x: 0.7392, y: -0.6080, z: -0.2896},
									 {name: "gamma", x: 0.7849, y: -0.5492, z: -0.2867},
									 {name: "delta", x: 0.8035, y: -0.5266, z: -0.2778},
									 {name: "eta", x: 0.6777, y: -0.6522, z: -0.3396},
									 {name: "rho", x: 0.5758, y: -0.7582, z: -0.3059},
									 {name: "beta", x: 0.5580, y: -0.7896, z: -0.2551},
									 {name: "alpha2", x: 0.5531, y: -0.8043, z: -0.2172},
									 {name: "24", x: 0.6605, y: -0.6206, z: -0.4227},
									 {name: "psi", x: 0.5994, y: -0.6771, z: -0.4269},
									 {name: "omega", x: 0.6076, y: -0.6525, z: -0.4527}]},
							// aries
							{path: [{m:2,b:0,e:6},{m:5,b:3,e:4},{m:3,b:7,e:8},{m:6,b:7,e:10},{m:8,b:0,e:1}],
							 stars: [{name: "41", x: 0.6554, y: 0.6005, z: 0.4580},
									 {name: "39", x: 0.6486, y: 0.5837, z: 0.4886},
									 {name: "35", x: 0.6696, y: 0.5792, z: 0.4650},
									 {name: "alpha", x: 0.7797, y: 0.4832, z: 0.3982},
									 {name: "lambda", x: 0.7977, y: 0.4511, z: 0.4003},
									 {name: "beta", x: 0.8202, y: 0.4484, z: 0.3552},
									 {name: "gamma2", x: 0.8304, y: 0.4486, z: 0.3304},
									 {name: "eta", x: 0.7801, y: 0.5104, z: 0.3618},
									 {name: "epsilon", x: 0.6609, y: 0.6564, z: 0.3639},
									 {name: "delta", x: 0.6310, y: 0.6985, z: 0.3375}]},
							// cancer
							{path: [{m:3,b:0,e:5},{m:2,b:5,e:6}],
							 stars: [{name: "zeta", x: -0.5198, y: 0.7987, z: 0.3032},
									 {name: "beta", x: -0.5538, y: 0.8172, z: 0.1596},
									 {name: "delta", x: -0.6256, y: 0.7152, z: 0.3116},
									 {name: "gamma", x: -0.6083, y: 0.7043, z: 0.3660},
									 {name: "iota", x: -0.5828, y: 0.6548, z: 0.4811},
									 {name: "alpha", x: -0.6875, y: 0.6965, z: 0.2055}]},
							// virgo
							{path: [{m:4,b:0,e:13},{m:8,b:14,e:15},{m:9,b:13,e:14},{m:10,b:6,e:7},{m:11,b:4,e:5}],
							 stars: [{name: "omicron", x: -0.9882, y: -0.0225, z: 0.1518},
									 {name: "nu", x: -0.9916, y: 0.0613, z: 0.1137},
									 {name: "beta", x: -0.9987, y: 0.0405, z: 0.0308},
									 {name: "eta", x: -0.9962, y: -0.0868, z: -0.0116},
									 {name: "gamma", x: -0.9832, y: -0.1806, z: -0.0253},
									 {name: "theta", x: -0.9493, y: -0.2991, z: -0.0965},
									 {name: "alpha", x: -0.9141, y: -0.3564, z: -0.1936},
									 {name: "kappa", x: -0.8231, y: -0.5391, z: -0.1784},
									 {name: "iota", x: -0.8244, y: -0.5562, z: -0.1045},
									 {name: "tau", x: -0.8620, y: -0.5062, z: 0.0269},
									 {name: "zeta", x: -0.9158, y: -0.4014, z: -0.0104},
									 {name: "delta", x: -0.9690, y: -0.2399, z: 0.0593},
									 {name: "epsilon", x: -0.9459, y: -0.2630, z: 0.1901},
									 {name: "109", x: -0.7478, y: -0.6631, z: 0.0330},
									 {name: "mu", x: -0.7536, y: -0.6498, z: -0.0986}]},
							// pisces
							{path: [{m:0,b:1,e:15},{m:14,b:10,e:11},{m:12,b:15,e:16}],
							 stars: [{name: "tau", x: 0.8233, y: 0.2661, z: 0.5014},
									 {name: "upsilon", x: 0.8360, y: 0.3020, z: 0.4581},
									 {name: "phi", x: 0.8627, y: 0.2876, z: 0.4160},
									 {name: "eta", x: 0.8885, y: 0.3749, z: 0.2646},
									 {name: "omicron", x: 0.8846, y: 0.4383, z: 0.1592},
									 {name: "alpha", x: 0.8605, y: 0.5071, z: 0.0482},
									 {name: "nu", x: 0.8995, y: 0.4264, z: 0.0956},
									 {name: "epsilon", x: 0.9534, y: 0.2686, z: 0.1373},
									 {name: "delta", x: 0.9690, y: 0.2089, z: 0.1320},
									 {name: "omega", x: 0.9928, y: -0.0029, z: 0.1195},
									 {name: "iota", x: 0.9914, y: -0.0869, z: 0.0980},
									 {name: "theta", x: 0.9841, y: -0.1385, z: 0.1111},
									 {name: "gamma", x: 0.9810, y: -0.1855, z: 0.0573},
									 {name: "kappa", x: 0.9894, y: -0.1437, z: 0.0219},
									 {name: "lambda", x: 0.9965, y: -0.0782, z: 0.0311},
									 {name: "beta", x: 0.9680, y: -0.2418, z: 0.0666}]},						
							// scorpius
							{path: [{m:0,b:1,e:17},{m:13,b:17,e:20}],
							 stars: [{name: "?1", x: -0.0349, y: -0.7973, z: -0.6025},
									 {name: "lambda", x: -0.0917, y: -0.7923, z: -0.6033},
									 {name: "upsilon", x: -0.1012, y: -0.7891, z: -0.6059},
									 {name: "?2", x: -0.0785, y: -0.7803, z: -0.6205},
									 {name: "kappa", x: -0.0593, y: -0.7745, z: -0.6297},
									 {name: "iota1", x: -0.0414, y: -0.7635, z: -0.6445},
									 {name: "theta", x: -0.0723, y: -0.7278, z: -0.6820},
									 {name: "eta", x: -0.1509, y: -0.7127, z: -0.6850},
									 {name: "zeta2", x: -0.2080, y: -0.7090, z: -0.6738},
									 {name: "mu1", x: -0.2308, y: -0.7529, z: -0.6163},
									 {name: "epsilon", x: -0.2479, y: -0.7881, z: -0.5634},
									 {name: "tau", x: -0.3162, y: -0.8225, z: -0.4728},
									 {name: "alpha", x: -0.3448, y: -0.8264, z: -0.4451},
									 {name: "sigma", x: -0.3769, y: -0.8193, z: -0.4320},
									 {name: "13", x: -0.4001, y: -0.7878, z: -0.4683},
									 {name: "rho", x: -0.4467, y: -0.7499, z: -0.4881},
									 {name: "pi", x: -0.4528, y: -0.7754, z: -0.4402},
									 {name: "nu", x: -0.4281, y: -0.8401, z: -0.3332},
									 {name: "beta1", x: -0.4509, y: -0.8258, z: -0.3388},
									 {name: "delta", x: -0.4603, y: -0.8001, z: -0.3846}]},
							// aquarius
							{path: [{m:8,b:0,e:14},{m:9,b:14,e:15}],
							 stars: [{name: "phi", x: 0.9748, y: -0.1968, z: -0.1054},
									 {name: "psi3", x: 0.9702, y: -0.1756, z: -0.1670},
									 {name: "omega2", x: 0.9652, y: -0.0729, z: -0.2511},
									 {name: "107", x: 0.9456, y: -0.0578, z: -0.3203},
									 {name: "99", x: 0.9255, y: -0.1382, z: -0.3525},
									 {name: "88", x: 0.9099, y: -0.2039, z: -0.3612},
									 {name: "delta", x: 0.9233, y: -0.2706, z: -0.2726},
									 {name: "tau2", x: 0.9265, y: -0.2938, z: -0.2350},
									 {name: "lambda", x: 0.9487, y: -0.2873, z: -0.1319},
									 {name: "zeta", x: 0.9220, y: -0.3873, z: -0.0003},
									 {name: "gamma", x: 0.9091, y: -0.4159, z: -0.0242},
									 {name: "omicron", x: 0.8725, y: -0.4871, z: -0.0376},
									 {name: "beta", x: 0.7937, y: -0.6005, z: -0.0971},
									 {name: "epsilon", x: 0.6590, y: -0.7338, z: -0.1650},
									 {name: "pi", x: 0.9155, y: -0.4016, z: 0.0240}]},
							// taurus
							{path: [{m:0,b:1,e:9},{m:5,b:9,e:12}],
							 stars: [{name: "beta", x: 0.1287, y: 0.8684, z: 0.4788},
									 {name: "tau", x: 0.3065, y: 0.8683, z: 0.3900},
									 {name: "epsilon", x: 0.3667, y: 0.8704, z: 0.3286},
									 {name: "delta3", x: 0.3813, y: 0.8717, z: 0.3078},
									 {name: "delta1", x: 0.3919, y: 0.8692, z: 0.3014},
									 {name: "gamma", x: 0.4078, y: 0.8724, z: 0.2694},
									 {name: "lambda", x: 0.4857, y: 0.8469, z: 0.2163},
									 {name: "xi", x: 0.6096, y: 0.7745, z: 0.1691},
									 {name: "omicron", x: 0.6187, y: 0.7698, z: 0.1569},
									 {name: "theta2", x: 0.3732, y: 0.8865, z: 0.2735},
									 {name: "alpha", x: 0.3438, y: 0.8950, z: 0.2842},
									 {name: "zeta", x: 0.0907, y: 0.9283, z: 0.3607}]},
							// libra
							{path: [{m:0,b:1,e:6},{m:2,b:4,e:5}],
							 stars: [{name: "tau", x: -0.5020, y: -0.7080, z: -0.4966},
									 {name: "upsilon", x: -0.5152, y: -0.7157, z: -0.4716},
									 {name: "gamma", x: -0.5700, y: -0.7810, z: -0.2553},
									 {name: "beta", x: -0.6441, y: -0.7474, z: -0.1630},
									 {name: "alpha2", x: -0.7061, y: -0.6520, z: -0.2763},
									 {name: "sigma", x: -0.6279, y: -0.6507, z: -0.4271}]}				
						];
*/

include "constellationsData.as"
		
	}
}

internal class RGB {
	public var r:uint = 0;
	public var g:uint = 0;
	public var b:uint = 0;
	public function RGB(r:uint=0, g:uint=0, b:uint=0) {
		this.r = r;
		this.g = g;
		this.b = b;
	}
}

internal class ScreenCoord {
	public var x:Number = 0;
	public var y:Number = 0;	
}

internal class HorizonCoord {
	public var az:Number = 0;
	public var alt:Number = 0;
}

internal class CelestialCoord {
	public var ra:Number = 0;
	public var dec:Number = 0;
}


