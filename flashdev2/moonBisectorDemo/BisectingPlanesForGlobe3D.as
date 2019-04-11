
package {
	
	import flash.display.Graphics;
	
	public class BisectingPlanesForGlobe3D {
		
		public var color1:uint = 0xffa000;
		public var alpha1:Number = 0.5;
		public var thickness1:Number = 1;
		
		public var color2:uint = 0x00a0ff;
		public var alpha2:Number = 0.5;
		public var thickness2:Number = 1;
		
		public var angle1:Number = 0;
		public var angle2:Number = 0;
		
		public var size1:Number = 1.4;
		public var size2:Number = 1.4;
		
		public var lineAlpha1:Number = 0.8;
		public var lineAlpha2:Number = 0.8;
		
		public var show1:Boolean = true;
		public var show2:Boolean = true;
		
		protected var _globe:Globe3D;
		protected var _scene:Scene3D;
		
		protected var _fragmentIndex:int;
		protected var _fragmentsList:Array = [];
		
		protected var _anglesList1:Array;
		protected var _anglesList2:Array;
		
		public function BisectingPlanesForGlobe3D(globe:Globe3D) {
			_globe = globe;
			
			_scene = globe.scene;
			_scene.addEventListener("preUpdate", onPreUpdate);
			_scene.addEventListener("postUpdate", onPostUpdate);
			
			for (var i:int = 0; i<12; i++) {
				_fragmentsList[i] = new BisectingPlaneFragment();
				_scene.addObject(_fragmentsList[i]);
			}
		}
		
		protected function onPreUpdate(...ignored):void {
			
			if (angle1==angle2) angle1 += 1e-6;
			
			// position the planes' fragments so they are z-stacked correctly
			_fragmentIndex = 0;
			_anglesList1 = positionPlane(-angle1*Math.PI/180);
			_anglesList2 = positionPlane(-angle2*Math.PI/180);
		}
		
		protected function onPostUpdate(...ignored):void {
			redraw();
		}		
		
		public function redraw(...ignored):void {
			// now draw the planes
			for (var i:int = 0; i<_fragmentsList.length; i++) _fragmentsList[i].graphics.clear();
			if (show1) drawPlane(-angle1*Math.PI/180, _anglesList1, size1, color1, alpha1, thickness1, lineAlpha1);
			if (show2) drawPlane(-angle2*Math.PI/180, _anglesList2, size2, color2, alpha2, thickness2, lineAlpha2);			
		}
		
		protected function positionPlane(angle:Number):Array {
			// this function returns an array of objects with angle and fragment properties
			// angle refers to the angle in the plane's plane where the fragment parameterization starts
			// fragment is a reference to the object that is associated with this fragment
			
			var i:int;
			var anglesList:Array;
			var uAngle:Number, vAngle:Number;
			var midAngle:Number, cosMidAngle:Number, sinMidAngle:Number;
			var fragment:BisectingPlaneFragment;
			
			var cosAlpha:Number = Math.cos(angle);
			var sinAlpha:Number = Math.sin(angle);
			
			var a6:Number = _scene.t6*cosAlpha - _scene.t7*sinAlpha;
			var a8:Number = _scene.t8;
			
			// angle is the angle that defines where the parameterized circle goes from being in front of the
			// sphere to being behind it
			angle = ((-Math.atan2(a6, a8))%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			
			if (_scene.viewerPhi==0) anglesList = [{angle: 0}, {angle: Math.PI/2}, {angle: Math.PI}, {angle: 3*Math.PI/2}];
			else anglesList = [{angle: 0}, {angle: Math.PI/2}, {angle: Math.PI}, {angle: 3*Math.PI/2}, {angle: angle}, {angle: ((angle+Math.PI)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)}];
			anglesList.sortOn("angle", Array.NUMERIC);
			
			for (i=0; i<anglesList.length; i++) {
				uAngle = anglesList[i].angle;
				vAngle = anglesList[(i+1)%anglesList.length].angle;
				
				// midAngle is halfway between the two angles that define this particular fragment
				// we use this midpoint of the arc to position the plane fragment
				if (vAngle>uAngle) midAngle = uAngle + (vAngle - uAngle)/2;
				else midAngle = uAngle + (vAngle - uAngle + 2*Math.PI)/2;
				sinMidAngle = Math.sin(midAngle);
				cosMidAngle = Math.cos(midAngle);
				
				// position the fragment
				fragment = _fragmentsList[_fragmentIndex++];
				fragment.worldX = _globe.worldX + _globe.radius*cosAlpha*cosMidAngle;
				fragment.worldY = _globe.worldY + -_globe.radius*sinAlpha*cosMidAngle;
				fragment.worldZ = _globe.worldZ + _globe.radius*sinMidAngle;
				
				anglesList[i].fragment = fragment;
			}
			
			return anglesList;
		}
		
		protected function drawPlane(angle:Number, anglesList:Array, size:Number, color:uint, alpha:Number, thickness:Number, lineAlpha:Number):void {
			
			var i:int, j:int;
			var uAngle:Number, vAngle:Number;
			var ux:Number, uz:Number, vx:Number, vz:Number;
			var sx:Number, sy:Number;
			var u:int, v:int;
			var numCorners:int;
			var fragment:BisectingPlaneFragment;
			var pt:Object;
			var arcPtsList:Array;
			var g:Graphics;
			
			var cosAlpha:Number = Math.cos(angle);
			var sinAlpha:Number = Math.sin(angle);
			
			var outersize = size*_globe.radius;
			
			// constants a0-a8 take a point in the plane's plane and project it to screen space
			var a0:Number = _scene.t0*cosAlpha - _scene.t1*sinAlpha;
			var a2:Number = _scene.t2;
			var a3:Number = _scene.t3*cosAlpha - _scene.t4*sinAlpha;
			var a5:Number = _scene.t5;
			var a6:Number = _scene.t6*cosAlpha - _scene.t7*sinAlpha;
			var a8:Number = _scene.t8;
			
			var cornersList:Array = [{x: Math.SQRT2*outersize*Math.cos(7*Math.PI/4), z: Math.SQRT2*outersize*Math.sin(7*Math.PI/4)},
									 {x: Math.SQRT2*outersize*Math.cos(Math.PI/4), z: Math.SQRT2*outersize*Math.sin(Math.PI/4)},
									 {x: Math.SQRT2*outersize*Math.cos(3*Math.PI/4), z: Math.SQRT2*outersize*Math.sin(3*Math.PI/4)},
									 {x: Math.SQRT2*outersize*Math.cos(5*Math.PI/4), z: Math.SQRT2*outersize*Math.sin(5*Math.PI/4)}];
			
			// the screen coordinates of the center of the planes
			var csx:Number = _globe.x;
			var csy:Number = _globe.y;
			
			for (i=0; i<anglesList.length; i++) {
				// plane 1
				
				uAngle = anglesList[i].angle;
				vAngle = anglesList[(i+1)%anglesList.length].angle;
				
				// undo the x and y positioning of the fragment (done by the scene renderer) since we will
				// draw on those fragments using the projected points 
				fragment = anglesList[i].fragment;//_fragmentsList[_fragmentIndex++];
				fragment.x = 0;
				fragment.y = 0;
				
				arcPtsList = getArcPoints(0, 0, _globe.radius, uAngle, vAngle);
				
				// the sides of the plane are numbered: 0 at right, 1 at top, 2 at left, and 3 at bottom
				// the integers u and v specify which sides the starting and ending lines intersect, from
				// which we can calculate what those intersection points are
				
				v = Math.floor((vAngle + (Math.PI/4))/(Math.PI/2))%4;
				
				if (v==1) {
					vx = outersize/Math.tan(vAngle);
					vz = outersize;					
				}
				else if (v==2) {
					vx = -outersize;
					vz = -outersize*Math.tan(vAngle);		
				}
				else if (v==3) {
					vx = -outersize/Math.tan(vAngle);
					vz = -outersize;
				}
				else {
					vx = outersize;
					vz = outersize*Math.tan(vAngle);
				}
				
				u = Math.floor((uAngle + (Math.PI/4))/(Math.PI/2))%4;
				
				if (u==1) {
					ux = outersize/Math.tan(uAngle);
					uz = outersize;					
				}
				else if (u==2) {
					ux = -outersize;
					uz = -outersize*Math.tan(uAngle);		
				}
				else if (u==3) {
					ux = -outersize/Math.tan(uAngle);
					uz = -outersize;
				}
				else {
					ux = outersize;
					uz = outersize*Math.tan(uAngle);
				}
				
				numCorners = ((v-u)%4 + 4)%4;
				
				// the starting point
				pt = arcPtsList[0];
				sx = csx+a0*pt.ax+a2*pt.az;
				sy = csy+a3*pt.ax+a5*pt.az;
				
				g = fragment.graphics;
				g.moveTo(sx, sy);
				g.lineStyle(thickness, color, lineAlpha);
				g.beginFill(color, alpha);				
				for (j=1; j<arcPtsList.length; j++) {
					pt = arcPtsList[j];
					g.curveTo(csx+a0*pt.cx+a2*pt.cz, csy+a3*pt.cx+a5*pt.cz, csx+a0*pt.ax+a2*pt.az, csy+a3*pt.ax+a5*pt.az);					
				}
				g.lineStyle();
				g.lineTo(csx+a0*vx+a2*vz, csy+a3*vx+a5*vz);
				g.lineStyle(thickness, color, lineAlpha);
				for (j=0; j<numCorners; j++) {
					pt = cornersList[((v-j)%4+4)%4];
					g.lineTo(csx+a0*pt.x+a2*pt.z, csy+a3*pt.x+a5*pt.z);
				}
				g.lineTo(csx+a0*ux+a2*uz, csy+a3*ux+a5*uz);
				g.lineStyle();				
				g.lineTo(sx, sy);
				g.endFill();
			}
		}
		
		protected function getArcPoints(cx:Number, cy:Number, r:Number, startAngle:Number, endAngle:Number):Array {
			var arr:Array = [];
			startAngle = (startAngle%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			endAngle = (endAngle%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			var range:Number = endAngle - startAngle;
			if (range<0) range = (2*Math.PI) + range;
			var n:int = Math.ceil(range/0.4); // the denominator is the max arc step in radians
			var step:Number = range/n;
			var half:Number = step/2;
			var cr:Number = r/Math.cos(half);
			var aAngle:Number = startAngle;
			var cAngle:Number = startAngle - half;
			arr.push({ax: cx + r*Math.cos(startAngle), az: cy + r*Math.sin(startAngle)});
			for (var i:int = 0; i<n; i++) {
				aAngle += step;
				cAngle += step;
				arr.push({cx: cx + cr*Math.cos(cAngle), cz: cy + cr*Math.sin(cAngle), ax: cx + r*Math.cos(aAngle), az: cy + r*Math.sin(aAngle)});
			}
			return arr;
		}
		
	}
}

