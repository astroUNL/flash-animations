
package {
	
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class BisectingPlanesForSphere {
		
		protected var _scene:Scene3D;
		
		public var color1:uint = 0xffa000;
		public var alpha1:Number = 0.5;
		public var show1:Boolean = true;
		
		public var color2:uint = 0x00a0ff;
		public var alpha2:Number = 0.5;
		public var show2:Boolean = true;
		
		public var angle1:Number = 0;
		public var angle2:Number = 0;
		
		public var centerX:Number = 0;
		public var centerY:Number = 0;
		public var centerZ:Number = 0;
		public var innerRadius:Number = 0.5;
		public var outerSize:Number = 1;
		
		public var showPlane1:Boolean = true;
		public var showPlane2:Boolean = true;
				
		protected var _fragmentsList:Array = [];
		protected var _centerShim:BisectingPlaneFragment;
		
		public function BisectingPlanesForSphere(scene:Scene3D) {
			_scene = scene;
			_scene.addEventListener("preUpdate", onPreUpdate);
			_scene.addEventListener("postUpdate", onPostUpdate);
			
			for (var i:int = 0; i<8; i++) {
				_fragmentsList[i] = new BisectingPlaneFragment();
				_scene.addObject(_fragmentsList[i]);
			}
			
			_centerShim = new BisectingPlaneFragment();
			_scene.addObject(_centerShim);
			_centerShim.worldX = centerX;
			_centerShim.worldY = centerY;
			_centerShim.worldZ = centerZ;
		}
		
		public function setCenter(cx:Number, cy:Number, cz:Number):void {
			centerX = cx;
			centerY = cy;
			centerZ = cz;
			_centerShim.worldX = centerX;
			_centerShim.worldY = centerY;
			_centerShim.worldZ = centerZ;
		}
		
		protected function onPreUpdate(...ignored):void {
			// position the planes' fragments so they are z-stacked correctly
			_fragmentIndex = 0;			
			positionPlane(-angle1*Math.PI/180);
			positionPlane(-angle2*Math.PI/180);
		}
		
		public function onPostUpdate(...ignored):void {
			// now draw the planes
			for (var i:int = 0; i<8; i++) _fragmentsList[i].graphics.clear();
			_fragmentIndex = 0;
			if (showPlane1) drawPlane(-angle1*Math.PI/180, color1, alpha1, 0.8);
			if (showPlane2) drawPlane(-angle2*Math.PI/180, color2, alpha2, 0.8);
		}		
		
		protected function positionPlane(angle:Number):void {
			
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
			
			if (_scene.viewerPhi==0) anglesList = [0, Math.PI];
			else anglesList = [Math.PI/2, 3*Math.PI/2, angle, ((angle+Math.PI)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)];
			anglesList.sort(Array.NUMERIC);
			
			for (i=0; i<anglesList.length; i++) {
				uAngle = anglesList[i];
				vAngle = anglesList[(i+1)%anglesList.length];
				
				// midAngle is halfway between the two angles that define this particular fragment
				if (vAngle>uAngle) midAngle = uAngle + (vAngle - uAngle)/2;
				else midAngle = uAngle + (vAngle - uAngle + 2*Math.PI)/2;
				sinMidAngle = Math.sin(midAngle);
				cosMidAngle = Math.cos(midAngle);
				
				// position the fragment
				fragment = _fragmentsList[_fragmentIndex++];
				fragment.worldX = centerX + cosAlpha*cosMidAngle;
				fragment.worldY = centerY + -sinAlpha*cosMidAngle;
				fragment.worldZ = centerZ + sinMidAngle;
			}
		}
		
		
		
		protected var _fragmentIndex:int;
		
		protected function drawPlane(angle:Number, color:uint, alpha:Number, lineAlpha:Number):void {
			
			var i:int, j:int;
			
			var anglesList:Array;
			var uAngle:Number, vAngle:Number;
			var ux:Number, uz:Number, vx:Number, vz:Number;
			var sx:Number, sy:Number;
			var u:int, v:int;
			var numCorners:int;
			var midAngle:Number, cosMidAngle:Number, sinMidAngle:Number;
			var fragment:BisectingPlaneFragment;
			var pt:Object;
			var arcPtsList:Array;
			var g:Graphics;
			
			var cosAlpha:Number = Math.cos(angle);
			var sinAlpha:Number = Math.sin(angle);
			
			// constants a0-a8 take a point in the plane's plane and project it to screen space
			var a0:Number = _scene.t0*cosAlpha - _scene.t1*sinAlpha;
			var a1:Number = _scene.t0*sinAlpha + _scene.t1*cosAlpha;
			var a2:Number = _scene.t2;
			var a3:Number = _scene.t3*cosAlpha - _scene.t4*sinAlpha;
			var a4:Number = _scene.t3*sinAlpha + _scene.t4*cosAlpha;
			var a5:Number = _scene.t5;
			var a6:Number = _scene.t6*cosAlpha - _scene.t7*sinAlpha;
			var a7:Number = _scene.t6*sinAlpha + _scene.t7*cosAlpha;
			var a8:Number = _scene.t8;
			
			var cornersList:Array = [{x: Math.SQRT2*outerSize*Math.cos(7*Math.PI/4), z: Math.SQRT2*outerSize*Math.sin(7*Math.PI/4)},
									 {x: Math.SQRT2*outerSize*Math.cos(Math.PI/4), z: Math.SQRT2*outerSize*Math.sin(Math.PI/4)},
									 {x: Math.SQRT2*outerSize*Math.cos(3*Math.PI/4), z: Math.SQRT2*outerSize*Math.sin(3*Math.PI/4)},
									 {x: Math.SQRT2*outerSize*Math.cos(5*Math.PI/4), z: Math.SQRT2*outerSize*Math.sin(5*Math.PI/4)}];
			
			// angle is the angle that defines where the parameterized circle goes from being in front of the
			// sphere to being behind it
			angle = ((-Math.atan2(a6, a8))%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			
			if (_scene.viewerPhi==0) anglesList = [0, Math.PI];
			else anglesList = [Math.PI/2, 3*Math.PI/2, angle, ((angle+Math.PI)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)];
			anglesList.sort(Array.NUMERIC);
			
			// the screen coordinates of the center of the planes
			var csx:Number = _centerShim.x;
			var csy:Number = _centerShim.y;
			
			for (i=0; i<anglesList.length; i++) {
				// plane 1
				
				uAngle = anglesList[i];
				vAngle = anglesList[(i+1)%anglesList.length];
				
				// midAngle is halfway between the two angles that define this particular fragment
				if (vAngle>uAngle) midAngle = uAngle + (vAngle - uAngle)/2;
				else midAngle = uAngle + (vAngle - uAngle + 2*Math.PI)/2;
				sinMidAngle = Math.sin(midAngle);
				cosMidAngle = Math.cos(midAngle);
				
				// undo the x and y positioning of the fragment (done by the scene renderer) since we will
				// draw on those fragments using the projected points 
				fragment = _fragmentsList[_fragmentIndex++];
				fragment.x = 0;
				fragment.y = 0;
				
				arcPtsList = getArcPoints(0, 0, innerRadius, uAngle, vAngle);
				
				// the sides of the plane are numbered: 0 at right, 1 at top, 2 at left, and 3 at bottom
				// the integers u and v specify which sides the starting and ending lines intersect, from
				// which we can calculate what those intersection points are
				
				v = Math.floor((vAngle + (Math.PI/4))/(Math.PI/2))%4;
				
				if (v==1) {
					vx = outerSize/Math.tan(vAngle);
					vz = outerSize;					
				}
				else if (v==2) {
					vx = -outerSize;
					vz = -outerSize*Math.tan(vAngle);		
				}
				else if (v==3) {
					vx = -outerSize/Math.tan(vAngle);
					vz = -outerSize;
				}
				else {
					vx = outerSize;
					vz = outerSize*Math.tan(vAngle);
				}
				
				u = Math.floor((uAngle + (Math.PI/4))/(Math.PI/2))%4;
				
				if (u==1) {
					ux = outerSize/Math.tan(uAngle);
					uz = outerSize;					
				}
				else if (u==2) {
					ux = -outerSize;
					uz = -outerSize*Math.tan(uAngle);		
				}
				else if (u==3) {
					ux = -outerSize/Math.tan(uAngle);
					uz = -outerSize;
				}
				else {
					ux = outerSize;
					uz = outerSize*Math.tan(uAngle);
				}
				
				numCorners = ((v-u)%4 + 4)%4;
				
				// the starting point
				pt = arcPtsList[0];
				sx = csx+a0*pt.ax+a2*pt.az;
				sy = csy+a3*pt.ax+a5*pt.az;
				
				g = fragment.graphics;
				g.moveTo(sx, sy);
				g.lineStyle(1, color, lineAlpha);
				g.beginFill(color, alpha);				
				for (j=1; j<arcPtsList.length; j++) {
					pt = arcPtsList[j];
					g.curveTo(csx+a0*pt.cx+a2*pt.cz, csy+a3*pt.cx+a5*pt.cz, csx+a0*pt.ax+a2*pt.az, csy+a3*pt.ax+a5*pt.az);					
				}
				g.lineStyle();
				g.lineTo(csx+a0*vx+a2*vz, csy+a3*vx+a5*vz);
				g.lineStyle(1, color, lineAlpha);
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
			var n:int = Math.ceil(range/0.4); // the denominator is the max arc step in radius
			var step:Number = range/n;
			var half:Number = step/2;
			var cr:Number = r/Math.cos(half);
			var aAngle:Number = startAngle;
			var cAngle:Number = startAngle - half;
			
			arr.push({ax: cx + r*Math.cos(startAngle), az: cy + r*Math.sin(startAngle)});
			for (var i:int = 0; i<n; i++) {
				aAngle += step;
				cAngle += step;
				//g.curveTo(cx + cr*Math.cos(cAngle), cy - cr*Math.sin(cAngle), cx + r*Math.cos(aAngle), cy - r*Math.sin(aAngle));
				arr.push({cx: cx + cr*Math.cos(cAngle), cz: cy + cr*Math.sin(cAngle), ax: cx + r*Math.cos(aAngle), az: cy + r*Math.sin(aAngle)});
			}
			
			return arr;
		}
		
		/*
		protected function drawArc(g:Graphics, cx:Number, cy:Number, r:Number, startAngle:Number=0, endAngle:Number=2*Math.PI) {
			startAngle = (startAngle%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			endAngle = (endAngle%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			var range:Number = endAngle - startAngle;
			if (range<0) range = (2*Math.PI) + range;
			var n:int = Math.ceil(range/0.4); // the denominator is the max arc step in radius
			var step:Number = range/n;
			var half:Number = step/2;
			var cr:Number = r/Math.cos(half);
			var aAngle:Number = startAngle;
			var cAngle:Number = startAngle - half;
			g.moveTo(cx + r*Math.cos(startAngle), cy - r*Math.sin(startAngle));
			for (var i:int = 0; i<n; i++) {
				aAngle += step;
				cAngle += step;
				g.curveTo(cx + cr*Math.cos(cAngle), cy - cr*Math.sin(cAngle), cx + r*Math.cos(aAngle), cy - r*Math.sin(aAngle));
			}
		}
		*/
			
	}
}

