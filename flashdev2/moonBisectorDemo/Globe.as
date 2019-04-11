
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	import flash.utils.getTimer;
	
	public class Globe extends Sprite {
		
		protected var _baseSP:Sprite;
		protected var _containerSP:Sprite;
		protected var _shadingSP:Sprite;
		protected var _containerMaskSP:Sprite;
		
		public var _layersList:Array = [];
		
		public var _baseColor:uint = 0xb7c2f6;
		public var _baseAlpha:Number = 1.0;
		
		
		protected var _showShading:Boolean = false;
		
		
		public function Globe() {
			
			_containerMaskSP = new Sprite();
			addChild(_containerMaskSP);
			
			_baseSP = new Sprite();
			addChild(_baseSP);
			_containerSP = new Sprite();
			_containerSP.mask = _containerMaskSP;
			addChild(_containerSP);
			
			_shadingSP = new Sprite();
			addChild(_shadingSP);
			
			var i:int;
			var j:int;
			
			var layer:GlobeLayer = new GlobeLayer();
			layer.color = 0xb89763;
			
			var fill:GlobeLayerFill;
			
			var poly:Array;
			
			layer.fillsList = [];
			
			var sh:Shape;
			
			for (i=0; i<_shoreData.length; i++) {
				poly = _shoreData[i];
				fill = new GlobeLayerFill();
				fill.pointsList = [];
				for (j=0; j<poly.length; j++) fill.pointsList.push(new Point3D(poly[j].x, poly[j].y, poly[j].z));
				layer.fillsList.push(fill);
			}
			
			_layersList = [layer];
			
			mouseEnabled = false;
			
			setSunDirection(0, 0);
			
			calculateBConstants();
			calculatePConstants();		
			calculateRConstants();
			calculateQConstants();
			
			update();
		}
		
		
		
		
		protected var _initMouseX:Number;
		protected var _initMouseY:Number;
		protected var _initTheta:Number;
		protected var _initPhi:Number;
		
		protected function onMouseDownFunc(...ignored):void {
			_initMouseX = mouseX;
			_initMouseY = mouseY;
			_initTheta = _viewerTheta;
			_initPhi = _viewerPhi;
			stage.addEventListener("mouseUp", onMouseUpFunc);
			stage.addEventListener("mouseMove", onMouseMoveFunc);
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {
			var theta:Number = (180/Math.PI)*(_initTheta - (mouseX - _initMouseX)/_radius) - 180;
			var phi:Number = (180/Math.PI)*(_initPhi + (mouseY - _initMouseY)/_radius);
			setViewerThetaAndPhi(theta, phi);
			evt.updateAfterEvent();
		}
		
		protected function onMouseUpFunc(...ignored):void {
			stage.removeEventListener("mouseUp", onMouseUpFunc);
			stage.removeEventListener("mouseMove", onMouseMoveFunc);
		}
		
		
		
		protected var _radius:Number = 100;
		protected var _viewerPhi:Number = 0;
		protected var _viewerTheta:Number = 0;
		protected var _rotationAngle:Number = 0;
		protected var _precession:Number = 0;
							
		public function get precession():Number {
			return _precession*(180/Math.PI);
		}
		
		public function set precession(arg:Number):void {
			_precession = ((arg%360 + 360)%360)*(Math.PI/180);
			calculatePConstants();
			calculateQConstants();
			update();
		}
							
		public function get rotationAngle():Number {
			return _rotationAngle*(180/Math.PI);
		}
		
		public function set rotationAngle(arg:Number):void {
			_rotationAngle = ((arg%360 + 360)%360)*(Math.PI/180);
			calculateRConstants();	
			calculateQConstants();
			update();
		}
		
		public function get radius():Number {
			return _radius;		
		}
		
		public function set radius(arg:Number):void {
			_radius = arg;			
			calculateBConstants();
			update();
		}				
		
		public function update():void {
			updateLayers();
			updateShading();
		}
		
		
		protected var _sunTheta:Number = 0;
		protected var _sunPhi:Number = 0;
		protected var _sunX:Number;
		protected var _sunY:Number;
		protected var _sunZ:Number;
	
		public var shadingColor:uint = 0x000000;
		public var shadingAlpha:Number = 0.6;
		
		public function setSunDirection(sunTheta:Number, sunPhi:Number):void {
			_sunTheta = sunTheta*Math.PI/180;
			_sunPhi = sunPhi*Math.PI/180;
			_sunX = Math.cos(_sunPhi)*Math.cos(_sunTheta);
			_sunY = Math.cos(_sunPhi)*Math.sin(_sunTheta);
			_sunZ = Math.sin(_sunPhi);
			updateShading();
		}
		
		public function updateShading():void {
			var g:Graphics = _shadingSP.graphics;
			
			g.clear();
			
			if (!_showShading) return;
			
			var spx:Number = _sunX*_b0 + _sunY*_b1 + _sunZ*_b2;
			var spy:Number = _sunX*_b3 + _sunY*_b4 + _sunZ*_b5;
			var spz:Number = _sunX*_b6 + _sunY*_b7 + _sunZ*_b8;
			
			_shadingSP.rotation = (180/Math.PI)*Math.atan2(spx, -spy);
			
			var s:Number = -spz/Math.sqrt(spx*spx + spy*spy + spz*spz);
			var hnp:int = 4;
			var step:Number = Math.PI/hnp;
			var halfStep:Number = step/2;
			var r:Number = _radius + 0.25; // the extra 0.25px reduces slivers of unshaded areas at the perimeter due to differences in circle approximations
			var cr:Number = r/Math.cos(halfStep);
			
			g.moveTo(r, 0);
			g.beginFill(shadingColor, shadingAlpha);
			
			var aAngle:Number = step;
			var cAngle:Number = step - halfStep;
			
			var ax:Number, ay:Number, cx:Number, cy:Number;
			var i:int;
			
			for (i=0; i<hnp; i++) {
				ax = r*Math.cos(aAngle);
				ay = r*Math.sin(aAngle);
				cx = cr*Math.cos(cAngle);
				cy = cr*Math.sin(cAngle);
				g.curveTo(cx, cy, ax, ay);
				aAngle += step;
				cAngle += step;
			}
					
			for (i=0; i<hnp; i++) {
				ax = r*Math.cos(aAngle);
				ay = s*r*Math.sin(aAngle);
				cx = cr*Math.cos(cAngle);
				cy = s*cr*Math.sin(cAngle);
				g.curveTo(cx, cy, ax, ay);
				aAngle += step;
				cAngle += step;
			}
			
			g.endFill();
	
		}

		
		public var lineThickness:Number = 0;
		public var lineColor:uint = 0xffffff;
		public var lineAlpha:Number = 0;

		
		
		public function updateLayers():void {
			var startTimer:Number = getTimer();
			
			var k0:Number = _b0*_q0 + _b1*_q3 + _b2*_q6;
			var k1:Number = _b0*_q1 + _b1*_q4 + _b2*_q7;
			var k2:Number = _b0*_q2 + _b1*_q5 + _b2*_q8;
			var k3:Number = _b3*_q0 + _b4*_q3 + _b5*_q6;
			var k4:Number = _b3*_q1 + _b4*_q4 + _b5*_q7;
			var k5:Number = _b3*_q2 + _b4*_q5 + _b5*_q8;
			var k6:Number = _b6*_q0 + _b7*_q3 + _b8*_q6;
			var k7:Number = _b6*_q1 + _b7*_q4 + _b8*_q7;
			var k8:Number = _b6*_q2 + _b7*_q5 + _b8*_q8;
			
			// draw the base fill
			_baseSP.graphics.clear();
			_baseSP.graphics.beginFill(_baseColor, _baseAlpha);
			_baseSP.graphics.drawCircle(0, 0, _radius);
			_baseSP.graphics.endFill();
			
			_containerMaskSP.graphics.clear();
			_containerMaskSP.graphics.beginFill(0xff0000);
			_containerMaskSP.graphics.drawCircle(0, 0, _radius);
			_containerMaskSP.graphics.endFill();
			
			var d:Number = 1.5*_radius;
			var minStep:Number = 2*Math.acos(0.7);
					
			
			
			
			var g:Graphics;
			
			
			for (i=0; i<_layersList.length; i++) {
				try {
					(_containerSP.getChildAt(i) as Shape).graphics.clear();
				}
				catch (err:Error) {
					_containerSP.addChildAt(new Shape(), i);
				}
				
				(_containerSP.getChildAt(i) as Shape).graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			}
			
			
			
			var i:int;
			var j:int;
			var k:int;
			var kOff:int;
			var m:int;
			
			var color:uint;
			var alpha:Number;
			
			//var g:Graphics;
			var fillsList:Array;
			var ptsList:Array;
			var ptsLen:int;
			var pt:Point3D;
			
			var sx:Number;
			var sy:Number;
			var angle:Number;
			var angleNow:Number;
			var angleLast:Number;
			var arc:Number;
			var n:int;
			var step:Number;
			
			var lastInFront:Boolean;
			var ibNow:Boolean;
			var ibLast:Boolean;
			
			
//			trace("");
//			trace("numChildren: "+_containerSP.numChildren);
			
			for (i=0; i<_layersList.length; i++) {
				fillsList = _layersList[i].fillsList;
				//g = _layersList[i].graphics;
				color = _layersList[i].color;
				alpha = _layersList[i].alpha;
				
//				trace("i: "+i+", color: "+color.toString(16));

				g = (_containerSP.getChildAt(i) as Shape).graphics;
				
				
				//_containerSP.removeChildAt(i);
				
	//			_containerSP.getChildAt(i)
//				try {
				//if (i==0) (_containerSP.getChildAt(i) as Shape).visible = false;
//				}
//				catch (err:Error) {
//					_containerSP.addChildAt(new Shape(), i);
//					g = (_containerSP.getChildAt(i) as Shape).graphics;
//				}
				
//				sh = new Shape();
//				g = sh.graphics;
//				_containerSP.addChildAt(sh, i);
				
				for (j=0; j<fillsList.length; j++) {
					ptsList = fillsList[j].pointsList;
					ptsLen = ptsList.length;
					lastInFront = false;
					
					
					for (kOff=0; kOff<ptsLen; kOff++) {
						pt = ptsList[kOff];
						if ((pt.x*k6+pt.y*k7+pt.z*k8)>0) {
							if (lastInFront) {
								g.moveTo(pt.x*k0+pt.y*k1+pt.z*k2, pt.x*k3+pt.y*k4+pt.z*k5);
								break;								
							}
							else lastInFront = true;
						}
						else lastInFront = false;
					}
					
					if (kOff==ptsLen) continue;
					
					
					ibLast = false;
					g.beginFill(color, alpha);
					for (k=1; k<ptsLen; k++) {
						pt = ptsList[(k+kOff)%ptsLen];
						ibNow = (pt.x*k6+pt.y*k7+pt.z*k8)<0;
						if (!ibNow) {
							if (ibLast) {
								sx = pt.x*k0+pt.y*k1+pt.z*k2;
								sy = pt.x*k3+pt.y*k4+pt.z*k5;
								angleNow = Math.atan2(sy, sx);
								arc = ((angleNow-angleLast)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
								if (arc>Math.PI) {
									arc = (2*Math.PI)-arc;
									n = Math.ceil(arc/minStep);
									step = -arc/n;
								}
								else {
									n = Math.ceil(arc/minStep);
									step = arc/n;
								}
								for (m=1; m<=n; m++) {
									angle = angleLast + step*m;
									g.lineTo(d*Math.cos(angle), d*Math.sin(angle));						
								}
								g.lineTo(sx, sy);
							}
							else g.lineTo(pt.x*k0+pt.y*k1+pt.z*k2, pt.x*k3+pt.y*k4+pt.z*k5);
						}
						else if (!ibLast) {
							angleLast = Math.atan2(pt.x*k3+pt.y*k4+pt.z*k5, pt.x*k0+pt.y*k1+pt.z*k2);
							g.lineTo(d*Math.cos(angleLast), d*Math.sin(angleLast));
						}
						ibLast = ibNow;
					}
					g.endFill();
					
					
				}
			}
			
			//trace("updateLayers: "+(getTimer()-startTimer));
		}
		
		
		
		
		public function setViewerThetaAndPhi(theta:Number, phi:Number):void {
			
			_viewerTheta = (theta + 180)*Math.PI/180;
			_viewerPhi = phi*Math.PI/180;
			
			if (_viewerPhi>(Math.PI/2)) _viewerPhi = Math.PI/2;
			else if (_viewerPhi<(-Math.PI/2)) _viewerPhi = -Math.PI/2;
			
			calculateBConstants();
			update();
		}
			
		
		protected var _b0:Number, _b1:Number, _b2:Number, _b3:Number, _b4:Number, _b5:Number, _b6:Number, _b7:Number, _b8:Number;
		protected var _r0:Number, _r1:Number, _r2:Number, _r3:Number, _r4:Number, _r5:Number, _r6:Number, _r7:Number, _r8:Number;
		protected var _q0:Number, _q1:Number, _q2:Number, _q3:Number, _q4:Number, _q5:Number, _q6:Number, _q7:Number, _q8:Number;
		protected var _p0:Number, _p1:Number, _p2:Number, _p3:Number, _p4:Number, _p5:Number, _p6:Number, _p7:Number, _p8:Number;
			
			
			
		public function calculateBConstants():void {
			var ct:Number = Math.cos(_viewerTheta);
			var st:Number = Math.sin(_viewerTheta);
			var cp:Number = Math.cos(_viewerPhi);
			var sp:Number = Math.sin(_viewerPhi);
			_b0 = _radius*st;
			_b1 = -_radius*ct;
			_b2 = 0;
			_b3 = -_radius*ct*sp;
			_b4 = -_radius*st*sp;
			_b5 = -_radius*cp;
			_b6 = -_radius*ct*cp;
			_b7 = -_radius*st*cp;
			_b8 = _radius*sp;			
		}
		
		public function calculatePConstants():void {
			var cp:Number = Math.cos(_precession);
			var sp:Number = Math.sin(_precession);
			_p0 = cp;
			_p1 = -sp;
			_p3 = sp*0.91706;
			_p4 = cp*0.91706;
			_p5 = -0.39875;
			_p6 = sp*0.39875;
			_p7 = cp*0.39875;
			_p8 = 0.91706;
		}
		
		public function calculateRConstants():void {
			// see note below
			var cr:Number = Math.cos(_rotationAngle);
			var sr:Number = Math.sin(_rotationAngle);
			_r0 = cr;
			_r1 = -sr;
			_r3 = sr*0.91706;
			_r4 = cr*0.91706;
			_r5 = 0.39875;
			_r6 = -sr*0.39875;
			_r7 = -cr*0.39875;
			_r8 = 0.91706;
		}
		
		public function calculateQConstants():void {
			// see note below
			_q0 = _p0*_r0 + _p1*_r3;
			_q1 = _p0*_r1 + _p1*_r4;
			_q2 = _p1*_r5;
			_q3 = _p3*_r0 + _p4*_r3 + _p5*_r6;
			_q4 = _p3*_r1 + _p4*_r4 + _p5*_r7;
			_q5 = _p4*_r5 + _p5*_r8;
			_q6 = _p6*_r0 + _p7*_r3 + _p8*_r6;
			_q7 = _p6*_r1 + _p7*_r4 + _p8*_r7;
			_q8 = _p7*_r5 + _p8*_r8;
		}
		
		public function get showShading():Boolean {
			return _showShading;
		}
		public function set showShading(arg:Boolean):void {
			_showShading = arg;
			updateShading();
		}
		
						
/*			
			
p.getViewerDirection = function() {
	var vDir = {};
	vDir.theta = (((this._viewerTheta*180/Math.PI) - 180)%360 + 360)%360;
	vDir.phi = this._viewerPhi*180/Math.PI;
	return vDir;
};

p.setViewerDirection = function(arg, callChangeHandler) {
	if (this.isStandalone) {
		this._viewerTheta = (arg.theta + 180)*Math.PI/180;
		this._viewerPhi = arg.phi*Math.PI/180;
		if (this._viewerPhi>(Math.PI/2)) this._viewerPhi = Math.PI/2;
		else if (this._viewerPhi<(-Math.PI/2)) this._viewerPhi = -Math.PI/2;
		this.calculateBConstants();
		this.update();
		if (callChangeHandler) this._parent[this.viewerDirectionChangeHandler]();
	}
};

p.setSunPosition = function(arg) {
	this._sunPos = {};
	if (this.isStandalone) {
		this._sunTheta = arg.theta*Math.PI/180;
		this._sunPhi = arg.phi*Math.PI/180;
		this._sunPos.x = Math.cos(this._sunPhi)*Math.cos(this._sunTheta);
		this._sunPos.y = Math.cos(this._sunPhi)*Math.sin(this._sunTheta);
		this._sunPos.z = Math.sin(this._sunPhi);
	}
	else {
		this._sphere.parsePointInput(arg, this._sunPos);
	}
	this.updateShading();
};

p.getShowShading = function() {
	return this._showShading;	
};
p.setShowShading = function(arg) {
	this._showShading = Boolean(arg);
	this.shadingMC._visible = this._showShading;
	this.updateShading();
};
p.addProperty("showShading", p.getShowShading, p.setShowShading);

p.setShadingStyle = function(color, alpha) {
	this.shadingColor = color;
	this.shadingAlpha = alpha;
	this.updateShading();
};

p.getShowAxis = function() {
	return this._showAxis;	
};
p.setShowAxis = function(arg) {
	this._showAxis = Boolean(arg);
	this.frontAxisMC._visible = this._showAxis;
	this.backAxisMC._visible = this._showAxis;
	if (!this._showAxis && !this.isStandalone) {
		// note: we don't need to set the visibility of the lines of the celestial sphere
		// to true if showAxis is true since the updateAxis function will do that anyway
		this._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = false;
		this._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = false;
	}
	this.updateAxis();
};
p.addProperty("showAxis", p.getShowAxis, p.setShowAxis);

p.setAxisStyle = function(thickness, color, alpha) {
	this.axisThickness = thickness;
	this.axisColor = color;
	this.axisAlpha = alpha;
	if (!this.isStandalone) {
		this._sphere.__PrecessingGlobeV2SouthPoleAxis.setStyle(this.axisThickness, this.axisColor, this.axisAlpha);
		this._sphere.__PrecessingGlobeV2NorthPoleAxis.setStyle(this.axisThickness, this.axisColor, this.axisAlpha);
	}
	this.updateAxis();
};

p.getAxisLength = function() {
	return this._axisLength;
};
p.setAxisLength = function(arg) {
	this._axisLength = arg;
	this.updateAxis();
};
p.addProperty("axisLength", p.getAxisLength, p.setAxisLength);


p.getRotation = function() {
	return this._rotationAngle*(180/Math.PI);
};
p.setRotation = function (arg) {
	this._rotationAngle = ((arg%360 + 360)%360)*(Math.PI/180);
	this.calculateRConstants();	
	this.calculateQConstants();
	this.updateGlobe();
};
p.addProperty("rotation", p.getRotation, p.setRotation);

p.getSize = function() {
	return this._size;	
};
p.setSize = function(arg) {
	this._size = arg;
	if (this.isStandalone) {
		this.mouseAreaMC._xscale = this.mouseAreaMC._yscale =
			this.globeMC._xscale = this.globeMC._yscale =
			this.shadingMC._xscale = this.shadingMC._yscale = this._size;
		this.calculateBConstants();
	}
	else {
		if (this._size>1) this._size = 1;
		this.refreshScaling();
	}
	this.updateAxis();
};
p.addProperty("size", p.getSize, p.setSize);

p.refreshScaling = function() {
	this.mouseAreaMC._xscale = this.mouseAreaMC._yscale =
		this.globeMC._xscale = this.globeMC._yscale =
		this.shadingMC._xscale = this.shadingMC._yscale = 2*this._sphere._c.r*this._size;
};

p.calculateBConstants = function() {
	// see note below
	var r = this._size/2;
	var ct = Math.cos(this._viewerTheta);
	var st = Math.sin(this._viewerTheta);
	var cp = Math.cos(this._viewerPhi);
	var sp = Math.sin(this._viewerPhi);
	var pc = {};
	pc.r = r;
	pc.r2 = r*r;
	pc.b0 = r*st;
	pc.b1 = -r*ct;
	pc.b2 = 0;
	pc.b3 = -r*ct*sp;
	pc.b4 = -r*st*sp;
	pc.b5 = -r*cp;
	pc.b6 = -r*ct*cp;
	pc.b7 = -r*st*cp;
	pc.b8 = r*sp;
	this._pc = pc;
};

p.calculateRConstants = function() {
	// see note below
	if (this.isStandalone) var angle = this._rotationAngle;
	else var angle = this._sphere._sTime + this._rotationAngle;
	var cr = Math.cos(angle);
	var sr = Math.sin(angle);
	var c = this._c;
	c.r0 = cr;
	c.r1 = -sr;
	c.r3 = sr*0.91706;
	c.r4 = cr*0.91706;
	c.r5 = 0.39875;
	c.r6 = -sr*0.39875;
	c.r7 = -cr*0.39875;
	c.r8 = 0.91706;
};

p.calculateQConstants = function() {
	// see note below
	var c = this._c;
	c.q0 = c.p0*c.r0 + c.p1*c.r3;
	c.q1 = c.p0*c.r1 + c.p1*c.r4;
	c.q2 = c.p1*c.r5;
	c.q3 = c.p3*c.r0 + c.p4*c.r3 + c.p5*c.r6;
	c.q4 = c.p3*c.r1 + c.p4*c.r4 + c.p5*c.r7;
	c.q5 = c.p4*c.r5 + c.p5*c.r8;
	c.q6 = c.p6*c.r0 + c.p7*c.r3 + c.p8*c.r6;
	c.q7 = c.p6*c.r1 + c.p7*c.r4 + c.p8*c.r7;
	c.q8 = c.p7*c.r5 + c.p8*c.r8;
};
*/

/*
	A note on the geometry transformations:
	
	Begin with a point in global coordinates, where the +z axis points in the direction of the
	the north pole and the x-axis is aligned with the prime meridian. The point's celestial
	coordinates are given by the following transformations.
				1: rotate about z by rotation angle (the diurnal motion of the earth)
				2: rotate about x by -obliquity
				3: rotate about z by precession angle
				4: rotate about x by obliquity
	The constants r0-r8 do the first two transfomations and the constants p0-p8 do the second two
	transformations. Combining them gives the constants q0-q8.
	
	After doing the q-matrix transformation, doing the b-matrix transformation (using the constants
	on the celestial sphere or in this component if in standalone mode) takes the point to the
	screen coordinate system.
	
	In computing the rotation angle we take into account the sidereal time so that the globe
	stays fixed even as the sidereal time changes. This means the constants have to be recalculated
	when the sidereal time changes (hence the watcher function).
*/

/*
p.sphereConstantsWatcher = function(id, oldVal, newVal, globeInstance) {
	// this function watches the _bVer property of the celestial sphere, which will change when
	// any of the theta, phi, size, latitude, or siderealTime properties of the sphere change
	// (it is this watcher that removes the burden on the component user of having to manually 
	// update the globe when dragging the sphere orientation, for example)
	globeInstance.refreshScaling();
	globeInstance.calculateRConstants();	
	globeInstance.calculateQConstants();
	globeInstance.update();
	return newVal;	
};
			
			*/
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		protected var _shoreData:Array = [[
		{x:-0.3346,y:0.0459,z:0.9413},{x:-0.3416,y:0.0996,z:0.9346},
		{x:-0.2114,y:0.2266,z:0.9508},{x:-0.0960,y:0.2606,z:0.9607},

		{x:-0.0754,y:0.2221,z:0.9721},{x:0.1858,y:0.3188,z:0.9294},
		{x:0.2601,y:0.2689,z:0.9274},{x:0.3333,y:0.1093,z:0.9365},
		{x:0.5148,y:0.0304,z:0.8568},{x:0.5205,y:0.0699,z:0.8510},
		{x:0.4949,y:0.0935,z:0.8639},{x:0.5415,y:0.1316,z:0.8304},
		{x:0.4746,y:0.1559,z:0.8663},{x:0.4533,y:0.1428,z:0.8798},
		{x:0.3811,y:0.1820,z:0.9064},{x:0.5518,y:0.1955,z:0.8107},
		{x:0.5657,y:0.1123,z:0.8169},{x:0.5325,y:0.0913,z:0.8415},
		{x:0.5788,y:0.0726,z:0.8123},{x:0.6521,y:0.0005,z:0.7582},
		{x:0.6599,y:-0.0552,z:0.7494},{x:0.6902,y:-0.0128,z:0.7235},
		{x:0.7263,y:-0.0199,z:0.6871},{x:0.7223,y:-0.1168,z:0.6817},
		{x:0.7875,y:-0.1261,z:0.6033},{x:0.8049,y:-0.0790,z:0.5882},
		{x:0.7916,y:-0.0099,z:0.6110},{x:0.7267,y:0.0424,z:0.6856},
		{x:0.7059,y:0.1082,z:0.7000},{x:0.7406,y:0.2044,z:0.6401},
		{x:0.7610,y:0.2109,z:0.6135},{x:0.7249,y:0.2418,z:0.6450},
		{x:0.7003,y:0.1548,z:0.6969},{x:0.6782,y:0.1634,z:0.7165},
		{x:0.7010,y:0.2505,z:0.6677},{x:0.7398,y:0.3160,z:0.5939},
		{x:0.7024,y:0.2932,z:0.6486},{x:0.6614,y:0.3481,z:0.6644},
		{x:0.5977,y:0.3465,z:0.7230},{x:0.5499,y:0.4863,z:0.6790},
		{x:0.6837,y:0.3491,z:0.6408},{x:0.7121,y:0.3693,z:0.5971},
		{x:0.6462,y:0.4721,z:0.5996},{x:0.7063,y:0.4790,z:0.5213},
		{x:0.7515,y:0.4162,z:0.5118},{x:0.7804,y:0.3107,z:0.5427},
		{x:0.8160,y:0.2808,z:0.5053},{x:0.8186,y:0.1474,z:0.5552},
		{x:0.7832,y:0.1514,z:0.6031},{x:0.8072,y:-0.0792,z:0.5849},
		{x:0.8913,y:-0.2764,z:0.3594},{x:0.9222,y:-0.2913,z:0.2545},
		{x:0.9680,y:-0.2156,z:0.1285},{x:0.9960,y:-0.0345,z:0.0829},
		{x:0.9910,y:0.0669,z:0.1160},{x:0.9841,y:0.1734,z:0.0387},
		{x:0.9529,y:0.2358,z:-0.1910},{x:0.9216,y:0.1990,z:-0.3334},
		{x:0.7843,y:0.2596,z:-0.5635},{x:0.7424,y:0.3784,z:-0.5528},
		{x:0.7432,y:0.5300,z:-0.4084},{x:0.7742,y:0.5361,z:-0.3363},
		{x:0.7322,y:0.6312,z:-0.2559},{x:0.7731,y:0.6290,z:-0.0816},
		{x:0.6711,y:0.7371,z:0.0794},{x:0.6185,y:0.7582,z:0.2064},
		{x:0.7094,y:0.6835,z:0.1720},{x:0.7425,y:0.6167,z:0.2616},
		{x:0.7323,y:0.4634,z:0.4990},{x:0.7047,y:0.6485,z:0.2880},
		{x:0.7090,y:0.6702,z:0.2195},{x:0.5470,y:0.7839,z:0.2936},
		{x:0.4669,y:0.7999,z:0.3771},{x:0.5075,y:0.7499,z:0.4244},
		{x:0.5708,y:0.7106,z:0.4113},{x:0.5873,y:0.6439,z:0.4903},
		{x:0.5637,y:0.6524,z:0.5065},{x:0.4562,y:0.7854,z:0.4183},
		{x:0.2850,y:0.8918,z:0.3513},{x:0.2137,y:0.9667,z:0.1405},
		{x:0.1742,y:0.9683,z:0.1790},{x:0.1617,y:0.9492,z:0.2701},
		{x:-0.0245,y:0.9218,z:0.3868},{x:-0.0724,y:0.9584,z:0.2760},
		{x:-0.1291,y:0.9498,z:0.2851},{x:-0.1512,y:0.9825,z:0.1087},
		{x:-0.2453,y:0.9692,z:0.0240},{x:-0.2253,y:0.9697,z:0.0943},
		{x:-0.1620,y:0.9742,z:0.1569},{x:-0.1693,y:0.9583,z:0.2302},
		{x:-0.2604,y:0.9534,z:0.1521},{x:-0.3240,y:0.9204,z:0.2189},
		{x:-0.2558,y:0.9105,z:0.3249},{x:-0.4007,y:0.8273,z:0.3937},
		{x:-0.4610,y:0.7336,z:0.4994},{x:-0.4007,y:0.7145,z:0.5736},
		{x:-0.4280,y:0.6691,z:0.6076},{x:-0.3850,y:0.6794,z:0.6247},
		{x:-0.4476,y:0.6263,z:0.6383},{x:-0.4855,y:0.6630,z:0.5698},
		{x:-0.5161,y:0.6355,z:0.5743},{x:-0.4692,y:0.6094,z:0.6391},
		{x:-0.5192,y:0.5174,z:0.6803},{x:-0.5026,y:0.4055,z:0.7635},
		{x:-0.4193,y:0.3708,z:0.8287},{x:-0.4622,y:0.1663,z:0.8710},
		{x:-0.5025,y:0.2226,z:0.8355},{x:-0.5765,y:0.2476,z:0.7787},
		{x:-0.5338,y:0.1583,z:0.8306},{x:-0.4863,y:0.1283,z:0.8643},
		{x:-0.4672,y:0.0074,z:0.8841},{x:-0.4180,y:0.0021,z:0.9084},
		{x:-0.4004,y:-0.0720,z:0.9135}],[{x:0.2060,y:-0.5678,z:-0.7970},
		{x:0.3392,y:-0.6758,z:-0.6544},{x:0.5784,y:-0.6598,z:-0.4797},
		{x:0.5974,y:-0.6792,z:-0.4264},{x:0.6996,y:-0.6096,z:-0.3727},
		{x:0.7597,y:-0.6120,z:-0.2200},{x:0.8105,y:-0.5663,z:-0.1498},
		{x:0.8141,y:-0.5728,z:-0.0954},{x:0.6662,y:-0.7455,z:0.0175},
		{x:0.6302,y:-0.7670,z:0.1205},{x:0.3556,y:-0.9081,z:0.2212},
		{x:0.2267,y:-0.9645,z:0.1355},{x:0.1876,y:-0.9681,z:0.1662},
		{x:0.1322,y:-0.9786,z:0.1575},{x:0.1114,y:-0.9592,z:0.2597},
		{x:0.0201,y:-0.9619,z:0.2728},{x:0.0499,y:-0.9301,z:0.3639},
		{x:-0.0045,y:-0.9324,z:0.3614},{x:-0.0268,y:-0.9479,z:0.3173},
		{x:-0.1023,y:-0.9327,z:0.3458},{x:-0.1250,y:-0.8816,z:0.4551},
		{x:-0.0824,y:-0.8601,z:0.5034},{x:0.0953,y:-0.8597,z:0.5018},
		{x:0.1497,y:-0.8938,z:0.4228},{x:0.1263,y:-0.8453,z:0.5192},
		{x:0.1937,y:-0.7964,z:0.5729},{x:0.2105,y:-0.7227,z:0.6583},
		{x:0.2559,y:-0.7013,z:0.6653},{x:0.2381,y:-0.6877,z:0.6859},
		{x:0.2978,y:-0.6315,z:0.7159},{x:0.3001,y:-0.6601,z:0.6886},
		{x:0.3373,y:-0.6187,z:0.7096},{x:0.2658,y:-0.6144,z:0.7428},
		{x:0.2193,y:-0.6474,z:0.7299},{x:0.2561,y:-0.5848,z:0.7697},
		{x:0.3205,y:-0.5532,z:0.7689},{x:0.3322,y:-0.4862,z:0.8082},
		{x:0.2840,y:-0.4991,z:0.8187},{x:0.2136,y:-0.4479,z:0.8682},
		{x:0.1950,y:-0.4938,z:0.8474},{x:0.1718,y:-0.4534,z:0.8746},
		{x:0.0976,y:-0.4563,z:0.8845},{x:0.1089,y:-0.6066,z:0.7875},
		{x:0.0729,y:-0.5727,z:0.8165},{x:-0.0263,y:-0.5471,z:0.8366},
		{x:-0.0364,y:-0.4856,z:0.8734},{x:0.0594,y:-0.3827,z:0.9220},
		{x:0.0520,y:-0.3518,z:0.9346},{x:0.0091,y:-0.3760,z:0.9266},
		{x:-0.0262,y:-0.3095,z:0.9505},{x:-0.0904,y:-0.3650,z:0.9266},
		{x:-0.2194,y:-0.2788,z:0.9349},{x:-0.2931,y:-0.1264,z:0.9477},
		{x:-0.3515,y:-0.0852,z:0.9323},{x:-0.3753,y:-0.1338,z:0.9172},
		{x:-0.4070,y:-0.0856,z:0.9094},{x:-0.4060,y:-0.1419,z:0.9028},
		{x:-0.4614,y:-0.1161,z:0.8795},{x:-0.4954,y:-0.1572,z:0.8543},
		{x:-0.4735,y:-0.2013,z:0.8575},{x:-0.5529,y:-0.1680,z:0.8162},
		{x:-0.4737,y:-0.2264,z:0.8511},{x:-0.4053,y:-0.2586,z:0.8768},
		{x:-0.3598,y:-0.3663,z:0.8581},{x:-0.3688,y:-0.5542,z:0.7462},
		{x:-0.4330,y:-0.6465,z:0.6282},{x:-0.3806,y:-0.7794,z:0.4977},
		{x:-0.3212,y:-0.8604,z:0.3956},{x:-0.3576,y:-0.7715,z:0.5262},
		{x:-0.2197,y:-0.9240,z:0.3130},{x:0.0463,y:-0.9711,z:0.2343},
		{x:0.1108,y:-0.9829,z:0.1468},{x:0.1636,y:-0.9786,z:0.1250},
		{x:0.1918,y:-0.9704,z:0.1470},{x:0.2199,y:-0.9734,z:0.0637},
		{x:0.1579,y:-0.9849,z:-0.0705},{x:0.2319,y:-0.9390,z:-0.2540},
		{x:0.3228,y:-0.8834,z:-0.3398},{x:0.2626,y:-0.7902,z:-0.5538},
		{x:0.2245,y:-0.7628,z:-0.6064},{x:0.1743,y:-0.5802,z:-0.7956}
		],[{x:0.2884,y:-0.1690,z:0.9425},{x:0.2580,y:-0.1350,z:0.9567},
		{x:0.2665,y:-0.0991,z:0.9587},{x:0.1582,y:-0.0467,z:0.9863},
		{x:0.0767,y:-0.1085,z:0.9911},{x:0.0709,y:-0.1896,z:0.9793},
		{x:0.2796,y:-0.3484,z:0.8947},{x:0.3541,y:-0.3522,z:0.8663}
		],[{x:-0.6199,y:0.4769,z:-0.6232},{x:-0.7027,y:0.3948,z:-0.5919},
		{x:-0.8027,y:0.4056,z:-0.4373},{x:-0.7799,y:0.5977,z:-0.1855},
		{x:-0.7366,y:0.6049,z:-0.3026},{x:-0.6881,y:0.6783,z:-0.2577},
		{x:-0.7106,y:0.6728,z:-0.2059},{x:-0.6562,y:0.7295,z:-0.1930},
		{x:-0.6152,y:0.7435,z:-0.2623},{x:-0.5707,y:0.7852,z:-0.2406},
		{x:-0.4870,y:0.8068,z:-0.3345},{x:-0.3773,y:0.8479,z:-0.3725},
		{x:-0.3439,y:0.7982,z:-0.4946},{x:-0.4027,y:0.7092,z:-0.5787},
		{x:-0.5375,y:0.6569,z:-0.5288},{x:-0.6160,y:0.5528,z:-0.5612}
		],[{x:0.1950,y:-0.4301,z:0.8815},{x:0.1489,y:-0.3678,z:0.9179},
		{x:0.1884,y:-0.3839,z:0.9039},{x:0.1903,y:-0.3474,z:0.9182},
		{x:0.0234,y:-0.2860,z:0.9579},{x:0.0282,y:-0.3259,z:0.9450},
		{x:0.1146,y:-0.3675,z:0.9229},{x:0.1043,y:-0.4110,z:0.9056}
		],[{x:0.3616,y:0.0008,z:-0.9323},{x:0.2757,y:-0.0950,z:-0.9565},
		{x:0.1623,y:-0.1217,z:-0.9792},{x:0.1207,y:-0.2253,z:-0.9668},
		{x:0.2426,y:-0.3770,z:-0.8939},{x:0.0849,y:-0.3383,z:-0.9372},
		{x:0.0888,y:-0.2744,z:-0.9575},{x:-0.0569,y:-0.3062,z:-0.9503},
		{x:-0.1779,y:-0.2219,z:-0.9587},{x:-0.2086,y:0.0366,z:-0.9773},
		{x:-0.3158,y:0.0556,z:-0.9472},{x:-0.2925,y:0.2905,z:-0.9111},
		{x:-0.0938,y:0.4102,z:-0.9072},{x:0.0560,y:0.4063,z:-0.9120},
		{x:0.0955,y:0.3336,z:-0.9379},{x:0.2419,y:0.3294,z:-0.9127},
		{x:0.3116,y:0.1986,z:-0.9292},{x:0.3043,y:0.1373,z:-0.9426}
		],[{x:-0.8538,y:0.5009,z:-0.1421},{x:-0.7416,y:0.6703,z:-0.0256},
		{x:-0.7090,y:0.7032,z:-0.0528},{x:-0.6683,y:0.7438,z:-0.0045},
		{x:-0.6686,y:0.7410,z:-0.0628},{x:-0.7400,y:0.6658,z:-0.0956},
		{x:-0.7476,y:0.6484,z:-0.1438},{x:-0.7854,y:0.5973,z:-0.1622},
		{x:-0.8088,y:0.5738,z:-0.1290}],[{x:0.4120,y:-0.5346,z:0.7379},
		{x:0.3479,y:-0.5141,z:0.7840},{x:0.3439,y:-0.5681,z:0.7477},
		{x:0.3846,y:-0.5658,z:0.7293}],[{x:-0.4760,y:0.8794,z:0.0094},
		{x:-0.4487,y:0.8918,z:0.0578},{x:-0.4865,y:0.8683,z:0.0968},
		{x:-0.4544,y:0.8824,z:0.1219},{x:-0.3257,y:0.9452,z:0.0238},
		{x:-0.3543,y:0.9338,z:-0.0508},{x:-0.4199,y:0.9043,z:-0.0771}
		],[{x:0.6229,y:-0.0015,z:0.7823},{x:0.5351,y:-0.0161,z:0.8447},
		{x:0.5191,y:-0.0450,z:0.8535},{x:0.5664,y:-0.0540,z:0.8224},
		{x:0.6044,y:-0.0332,z:0.7960},{x:0.6377,y:-0.0634,z:0.7677}
		],[{x:-0.6002,y:0.5602,z:0.5709},{x:-0.6300,y:0.5126,z:0.5834},
		{x:-0.5865,y:0.4671,z:0.6617},{x:-0.5851,y:0.5637,z:0.5830},
		{x:-0.5406,y:0.6248,z:0.5634},{x:-0.5876,y:0.6030,z:0.5395}
		],[{x:0.6170,y:0.6640,z:-0.4225},{x:0.6136,y:0.7434,z:-0.2664},
		{x:0.6383,y:0.7414,z:-0.2071},{x:0.6869,y:0.6617,z:-0.3006},
		{x:0.6624,y:0.6263,z:-0.4111}],[{x:-0.5157,y:0.8519,z:-0.0911},
		{x:-0.5141,y:0.8570,z:-0.0346},{x:-0.5742,y:0.8181,z:0.0314},
		{x:-0.5062,y:0.8623,z:0.0162},{x:-0.4805,y:0.8757,z:-0.0484}
		],[{x:0.4193,y:-0.1148,z:0.9006},{x:0.3867,y:-0.0987,z:0.9169},
		{x:0.3781,y:-0.1507,z:0.9134},{x:0.4088,y:-0.1714,z:0.8964}
		],[{x:0.6119,y:-0.0864,z:0.7862},{x:0.5713,y:-0.0666,z:0.8180},
		{x:0.5764,y:-0.1031,z:0.8107},{x:0.6050,y:-0.1146,z:0.7879}
		],[{x:-0.7522,y:0.0451,z:-0.6574},{x:-0.8171,y:0.0431,z:-0.5749},
		{x:-0.8274,y:0.0859,z:-0.5550},{x:-0.7623,y:0.0812,z:-0.6421}
		],[{x:-0.2696,y:0.9580,z:-0.0974},{x:-0.2767,y:0.9593,z:-0.0563},
		{x:-0.2353,y:0.9719,z:0.0031},{x:-0.0907,y:0.9911,z:0.0973}
		],[{x:0.2428,y:-0.9068,z:0.3446},{x:0.1414,y:-0.9078,z:0.3949},
		{x:0.0949,y:-0.9173,z:0.3867},{x:0.1925,y:-0.9144,z:0.3562},
		{x:0.2009,y:-0.9193,z:0.3384}],[{x:0.0223,y:-0.7332,z:0.6796},
		{x:0.0589,y:-0.6836,z:0.7275},{x:-0.0229,y:-0.6822,z:0.7308},
		{x:0.0178,y:-0.6568,z:0.7539},{x:0.1038,y:-0.6978,z:0.7087},
		{x:0.0942,y:-0.7242,z:0.6831},{x:0.0629,y:-0.6980,z:0.7134},
		{x:0.0448,y:-0.7453,z:0.6652}],[{x:0.4824,y:0.5331,z:0.6951},
		{x:0.4116,y:0.5444,z:0.7309},{x:0.4499,y:0.5682,z:0.6890},
		{x:0.4702,y:0.6478,z:0.5994},{x:0.5210,y:0.5986,z:0.6085}
		],[{x:0.3431,y:-0.8806,z:0.3269},{x:0.2745,y:-0.8987,z:0.3421},
		{x:0.2662,y:-0.9088,z:0.3212},{x:0.3042,y:-0.8984,z:0.3167}
		],[{x:-0.5955,y:0.4446,z:0.6691},{x:-0.6012,y:0.4083,z:0.6869},
		{x:-0.5515,y:0.4322,z:0.7135},{x:-0.5679,y:0.4685,z:0.6767},
		{x:-0.5955,y:0.4446,z:0.6691},{x:-0.5955,y:0.4446,z:0.6691}
		]];
		
	}
}
/*


import flash.display.Graphics;


internal class Point3D {
	public var x:Number = 0;
	public var y:Number = 0;
	public var z:Number = 0;
	public function Point3D(x:Number=0, y:Number=0, z:Number=0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
}

internal class Layer {
	public var fillsList:Array = [];
	public var color:uint = 0xffffff;
	public var graphics:Graphics;
}

internal class Fill {
	public var pointsList:Array = [];
}
			*/


/*


if (!this.isStandalone && this._object._sys!=1) {
	// we want users to be able to attach the globe component without explicitly adding it to the origin 
	// of the celestial sphere (it should happen automatically)
	// due to the order in which code is executed in the celestial sphere component, it is not possible
	// to make this assignment in the globe's initialization function, but by putting the code on the frame
	// it will be executed afterwards when the object is ready
	this._object.setPosition({x: 0, y: 0, z: 0, system: "celestial"});
	this._object.visible = true;
	this._sphere.updateObjects();
}

this.stop();


#initclip

function GlobeComponentV2Class() {
	this.createEmptyMovieClip("backAxisMC", 0);
	this.createEmptyMovieClip("mouseAreaMC", 5);
	this.createEmptyMovieClip("globeMC", 10);
	this.createEmptyMovieClip("shadingMC", 15);
	this.createEmptyMovieClip("frontAxisMC", 20);
	this.globeMC.createEmptyMovieClip("maskMC", 30);
	
	if (this.isStandalone==undefined) this.isStandalone = !(this._sphere!=undefined && this._sphere==this._parent._parent && this._object!=undefined);	
	
	if (this.isStandalone) {
		if (this.initSunPosition==undefined) this.initSunPosition = {theta: 0, phi: 0};
		if (this.initSize==undefined) this.initSize = this._width;
	}
	else {
		if (this.initSunPosition==undefined) this.initSunPosition = {ra: 0, dec: 0};
		if (this.initSize==undefined) this.initSize = 0.2;
		this._sphere.watch("_bVer", this.sphereConstantsWatcher, this);
		this._sphere.showHorizonPlane = false;
		this._sphere.addLine("__PrecessingGlobeV2SouthPoleAxis", {thickness: 2, color: 0x0000FF, alpha: 100},
								{az: 0, alt: 0, r: 0}, {az: 0, alt: 0, r: 1.5});
		this._sphere.addLine("__PrecessingGlobeV2NorthPoleAxis", {thickness: 2, color: 0xFF0000, alpha: 100},
								{az: 0, alt: 0, r: 0}, {az: 0, alt: 0, r: 1.5});
	}
	
	this.placeholderMC._visible = false;
	this._xscale = 100;
	this._yscale = 100;
	
	this.mouseAreaMC.useHandCursor = false;
	this.mouseAreaMC.tabEnabled = false;
	this.mouseAreaMC.clear();
	this.mouseAreaMC.beginFill(0xff0000, 0);
	this.drawCircle(this.mouseAreaMC, 0, 0, 50);
	this.mouseAreaMC.endFill();
	
	this._c = {};
	
	if (this.initRotation==undefined) this.initRotation = 0;
	if (this.initPrecession==undefined) this.initPrecession = 0;
	if (this.initViewerTheta==undefined) this.initViewerTheta = 0;
	if (this.initViewerPhi==undefined) this.initViewerPhi = 30;
	if (this.initIsDraggable==undefined) this.initIsDraggable = true;
	if (this.initShowAxis==undefined) this.initShowAxis = true;
	if (this.initAxisLength==undefined) this.initAxisLength = 1.4;
	if (this.initAxisThickness==undefined) this.initAxisThickness = 1;
	if (this.initAxisColor==undefined) this.initAxisColor = 0x000000;
	if (this.initAxisAlpha==undefined) this.initAxisAlpha = 100;
	if (this.initShowShading==undefined) this.initShowShading = false;
	if (this.initSunTheta!=undefined) this.initSunPosition.theta = this.initSunTheta;
	if (this.initSunPhi!=undefined) this.initSunPosition.phi = this.initSunPhi;
	if (this.initShadingColor==undefined) this.initShadingColor = 0x000000;
	if (this.initShadingAlpha==undefined) this.initShadingAlpha = 40;
	if (this.initWaterLinkageName==undefined) this.initWaterLinkageName = "Globe Component v2 Water";
	if (this.initLandLinkageName==undefined) this.initLandLinkageName = "Globe Component v2 Land";
	
	this.updateAxis = function() {};
	this.updateGlobe = function() {};
	this.updateShading = function() {};
	
	this.setLandLinkageName(this.initLandLinkageName);
	this.setWaterLinkageName(this.initWaterLinkageName);
	
	this.setAxisStyle(this.initAxisThickness, this.initAxisColor, this.initAxisAlpha);
	this.setShadingStyle(this.initShadingColor, this.initShadingAlpha);
	
	this.setSunPosition(this.initSunPosition);
	this.setViewerDirection({theta: this.initViewerTheta, phi: this.initViewerPhi});
	
	this.size = this.initSize;
	this.rotation = this.initRotation;
	this.precession = this.initPrecession;
	this.axisLength = this.initAxisLength;
	this.showAxis = this.initShowAxis;
	this.showShading = this.initShowShading;
	this.isDraggable = this.initIsDraggable;
	
	delete this.updateAxis;
	delete this.updateGlobe;
	delete this.updateShading;
	
	this.updateAxis();
	this.updateGlobe();
	this.updateShading();
}

var p = GlobeComponentV2Class.prototype = new MovieClip();
Object.registerClass("Globe Component v2", GlobeComponentV2Class);

p.updateShading = function() {
	if (!this._showShading) return;
	
	var mc = this.shadingMC;
	mc.clear();
	
	var sd = this._sunPos;
	var sp = {};
	if (this.isStandalone) {
		var pc = this._pc;
		sp.x = sd.x*pc.b0 + sd.y*pc.b1 + sd.z*pc.b2;
		sp.y = sd.x*pc.b3 + sd.y*pc.b4 + sd.z*pc.b5;
		sp.z = sd.x*pc.b6 + sd.y*pc.b7 + sd.z*pc.b8;
	}
	else {
		if (sd.sys==0 || sd.sys==-1) this._sphere.WtoSz(sd, sp);
		else if (sd.sys==1) this._sphere.CtoSz(sd, sp);
		else return;
	}

	mc._rotation = (180/Math.PI)*Math.atan2(sp.x, -sp.y);
	var s = -sp.z/Math.sqrt(sp.x*sp.x + sp.y*sp.y + sp.z*sp.z);
	
	var hnp = 4;
	var step = Math.PI/hnp;
	var halfStep = step/2;
	var cos = Math.cos;
	var sin = Math.sin;
	var r = 50;
	var cr = r/cos(halfStep);
	
	mc.moveTo(r, 0);
	mc.beginFill(this.shadingColor, this.shadingAlpha);
	
	var aAngle = step;
	var cAngle = step-halfStep;
	for (var i=0; i<hnp; i++) {
		var ax = r*cos(aAngle);
		var ay = r*sin(aAngle);
		var cx = cr*cos(cAngle);
		var cy = cr*sin(cAngle);
		mc.curveTo(cx, cy, ax, ay);
		aAngle += step;
		cAngle += step;
	}
	
	for (var i=0; i<hnp; i++) {
		var ax = r*cos(aAngle);
		var ay = s*r*sin(aAngle);
		var cx = cr*cos(cAngle);
		var cy = s*cr*sin(cAngle);
		mc.curveTo(cx, cy, ax, ay);
		aAngle += step;
		cAngle += step;
	}
	
	mc.endFill();
};

p.updateAxis = function() {
	if (!this._showAxis) return;
	
	var tc = this._c;
	
	if (this.isStandalone) {
		var pc = this._pc;
		var aLen = this._axisLength;
		if (aLen<1) aLen = 1;
		var s1 = 1;
		var s3 = aLen;
	}
	else {
		var aLen = this._axisLength;
		if (aLen<this._size) aLen = this._size;
		
		var pc = this._sphere._c;
		var s1 = this._size;
		var s2 = aLen/s1;
		if (aLen<1) var s3 = aLen/s1;
		else var s3 = 1/s1;
	}
	
	var k2 = s1*(pc.b0*tc.q2 + pc.b1*tc.q5 + pc.b2*tc.q8);
	var k5 = s1*(pc.b3*tc.q2 + pc.b4*tc.q5 + pc.b5*tc.q8);
	var k8 = s1*(pc.b6*tc.q2 + pc.b7*tc.q5 + pc.b8*tc.q8);
	
	if (k8>0) {
		var mc = this.frontAxisMC;
		mc.clear();
		mc.lineStyle(this.axisThickness, this.axisColor, this.axisAlpha);
		mc.moveTo(k2, k5);
		mc.lineTo(s3*k2, s3*k5);
		var mc = this.backAxisMC;
		mc.clear();
		mc.lineStyle(this.axisThickness, this.axisColor, this.axisAlpha);
		mc.moveTo(-k2, -k5);
		mc.lineTo(-s3*k2, -s3*k5);
	}
	else {
		var mc = this.backAxisMC;
		mc.clear();
		mc.lineStyle(this.axisThickness, this.axisColor, this.axisAlpha);
		mc.moveTo(k2, k5);
		mc.lineTo(s3*k2, s3*k5);
		var mc = this.frontAxisMC;
		mc.clear();
		mc.lineStyle(this.axisThickness, this.axisColor, this.axisAlpha);
		mc.moveTo(-k2, -k5);
		mc.lineTo(-s3*k2, -s3*k5);		
	}
	
	if (!this.isStandalone) {
		var x = (pc.a0*k2+pc.a3*k5+pc.a6*k8)/pc.r2;
		var y = (pc.a1*k2+pc.a4*k5+pc.a7*k8)/pc.r2;
		var z = (pc.a5*k5+pc.a8*k8)/pc.r2;

		if (aLen<1) {
			this._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = false;
			this._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = false;
		}
		else {
			// note: setting the visible property to true calls a line's update function
			this._sphere.__PrecessingGlobeV2NorthPoleAxis.setPoints({x: x/s1, y: y/s1, z: z/s1, system: "horizon"}, {x: x*s2, y: y*s2, z: z*s2, system: "horizon"});
			this._sphere.__PrecessingGlobeV2SouthPoleAxis.setPoints({x: -x/s1, y: -y/s1, z: -z/s1, system: "horizon"}, {x: -x*s2, y: -y*s2, z: -z*s2, system: "horizon"});
			this._sphere.__PrecessingGlobeV2NorthPoleAxis.visible = true;
			this._sphere.__PrecessingGlobeV2SouthPoleAxis.visible = true;
		}
	}
};

p.updateGlobe = function() {
	var tc = this._c;
	
	if (this.isStandalone) var pc = this._pc;
	else var pc = this._sphere._c;
	
	var sf = 50/pc.r;
	
	var k0 = sf*(pc.b0*tc.q0 + pc.b1*tc.q3 + pc.b2*tc.q6);
	var k1 = sf*(pc.b0*tc.q1 + pc.b1*tc.q4 + pc.b2*tc.q7);
	var k2 = sf*(pc.b0*tc.q2 + pc.b1*tc.q5 + pc.b2*tc.q8);
	var k3 = sf*(pc.b3*tc.q0 + pc.b4*tc.q3 + pc.b5*tc.q6);
	var k4 = sf*(pc.b3*tc.q1 + pc.b4*tc.q4 + pc.b5*tc.q7);
	var k5 = sf*(pc.b3*tc.q2 + pc.b4*tc.q5 + pc.b5*tc.q8);
	var k6 = sf*(pc.b6*tc.q0 + pc.b7*tc.q3 + pc.b8*tc.q6);
	var k7 = sf*(pc.b6*tc.q1 + pc.b7*tc.q4 + pc.b8*tc.q7);
	var k8 = sf*(pc.b6*tc.q2 + pc.b7*tc.q5 + pc.b8*tc.q8);
	
	var mc = this.globeMC.maskMC;
	mc.clear();
	
	var cos = Math.cos;
	var sin = Math.sin;
	var atan2 = Math.atan2;
	var ceil = Math.ceil;
	
	var s = this._shoreData;
	
	var r = 50;
	var d = 1.5*r;
	var minStep = 2*Math.acos(r*1.1/d);
	
	for (var i=0; i<s.length; i++) {
		var p = s[i];
		var pl = p.length;
		var lastInFront = false;
		for (var sj=0; sj<pl; sj++) {
			var pt = p[sj];
			if ((pt.x*k6+pt.y*k7+pt.z*k8)>0) {
				if (lastInFront) {
					mc.moveTo(pt.x*k0+pt.y*k1+pt.z*k2, pt.x*k3+pt.y*k4+pt.z*k5);
					break;
				}
				else lastInFront = true;
			}
			else lastInFront = false;
		}
		if (sj==pl) continue;
		var ibLast = false;
		mc.beginFill(0x000000);
		for (var j=1; j<pl; j++) {
			var pt = p[(sj+j)%pl];
			var ibNow = (pt.x*k6+pt.y*k7+pt.z*k8)<0;
			if (!ibNow) {
				if (ibLast) {
					var sx = pt.x*k0+pt.y*k1+pt.z*k2;
					var sy = pt.x*k3+pt.y*k4+pt.z*k5;
					var angleNow = atan2(sy, sx);
					var arc = ((angleNow-angleLast)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
					if (arc>Math.PI) {
						arc = (2*Math.PI)-arc;
						var n = ceil(arc/minStep);
						var step = -arc/n;
					}
					else {
						var n = ceil(arc/minStep);
						var step = arc/n;
					}
					for (var k=1; k<=n; k++) {
						var angle = angleLast + step*k;
						mc.lineTo(d*cos(angle), d*sin(angle));						
					}
					mc.lineTo(sx, sy);
				}
				else mc.lineTo(pt.x*k0+pt.y*k1+pt.z*k2, pt.x*k3+pt.y*k4+pt.z*k5);
			}
			else if (!ibLast) {
				var x = pt.x*k0+pt.y*k1+pt.z*k2;
				var y = pt.x*k3+pt.y*k4+pt.z*k5;
				var angleLast = atan2(y, x);
				mc.lineTo(d*cos(angleLast), d*sin(angleLast));
			}
			ibLast = ibNow;
		}
		mc.endFill();
	}
};

p.update = function() {
	this.updateShading();
	this.updateAxis();
	this.updateGlobe();
};

*/