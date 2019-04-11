
package {
	
	import flash.display.Shape;
	
	public class OrbitalPlane {
		
		
		protected var _scene:Scene3D;
		protected var _globesList:Array = [];
		protected var _fragmentsList:Array = [];
		
		public var show1:Boolean = true;
		public var show2:Boolean = true;
		
//		public var centerX:Number = 0;
//		public var centerY:Number = 0;
//		public var centerZ:Number = 0;


		public var _planeRotatorsList:Array;
		
		public var _masksList:Array;
		
		public function OrbitalPlane(globe1:Globe3D, globe2:Globe3D, planeClass:Class) {
			_scene = globe1.scene;
			_scene.addEventListener("preUpdate", onPreUpdate);
			
			_scene.addEventListener("postUpdate", onPostUpdate);
			
			_globesList[0] = globe1;
			_globesList[1] = globe2;
			
			
			var i:int;
			
			_planeRotatorsList = [];
			_masksList = [];
			
			for (i=0; i<=2; i++) {
				_fragmentsList[i] = new BisectingPlaneFragment();
				
				_planeRotatorsList[i] = new PlaneRotator(planeClass);
				
				
				_masksList[i] = new Shape();
				
				
				
				_fragmentsList[i].addChild(_planeRotatorsList[i]);
				_fragmentsList[i].addChild(_masksList[i]);
				
				_planeRotatorsList[i].mask = _masksList[i];
				
				_scene.addObject(_fragmentsList[i]);
			}
		}
		
		public function passData(dataObj:Object):void {
			for (var i:int = 0; i<3; i++) {
				_planeRotatorsList[i]._front.receiveData(dataObj);				
			}
			
		}
		
		protected function onPreUpdate(...ignored):void {
			var i:int;
			var r:Number;
			var spt:Point3D = new Point3D();
			var wpt:Point3D;
			
			//trace("num fragments: "+_fragmentsList.length);
			//trace("num globes: "+_globesList.length);
			
			
			var g:Globe3D;
			var f:BisectingPlaneFragment;
			
			g = _globesList[0];
			
			spt.x = g.screenX;
			spt.y = g.screenY;
			spt.z = g.screenZ - g.screenRadius;
			
			wpt = _scene.getWorldPoint(spt);
			
			f = _fragmentsList[0];
			f.worldX = wpt.x;
			f.worldY = wpt.y;
			f.worldZ = wpt.z;
			
			
			
			var cosPhi:Number = Math.cos(_scene.viewerPhi*Math.PI/180);
			var sinPhi:Number = Math.sin(_scene.viewerPhi*Math.PI/180);
			
			for (i=0; i<_globesList.length; i++) {
				g = _globesList[i];
				
				spt.x = g.screenX;
				spt.y = g.screenY - g.screenRadius*sinPhi;
				spt.z = g.screenZ + g.screenRadius*cosPhi;
				
				wpt = _scene.getWorldPoint(spt);
				
				f = _fragmentsList[i+1];
				f.worldX = wpt.x;
				f.worldY = wpt.y;
				f.worldZ = wpt.z;				
			}
		}
		
		protected function onPostUpdate(...ignored):void {
			// now draw the planes
			var i:int;

			//trace("onPreUpdate");
			//trace(" globe0: "+_globesList[0].screenZ+", "+_globesList[0].screenRadius);
			//trace(" globe1: "+_globesList[1].screenZ+", "+_globesList[1].screenRadius);
			_globesList.sortOn("screenZ", Array.NUMERIC);
			//trace(" globe0: "+_globesList[0].screenZ+", "+_globesList[0].screenRadius);
			//trace(" globe1: "+_globesList[1].screenZ+", "+_globesList[1].screenRadius);
			
			//trace("onPostUpdate");
			
			var f:BisectingPlaneFragment;
			
			var hw:Number = (_scene.sceneWidth/2);
			var hh:Number = (_scene.sceneHeight/2);
			
			var yNow:Number;
			var yLast:Number;
			
			//trace(" _scene.viewerPhi: "+_scene.viewerPhi);
			
			if (_scene.viewerPhi>0) {
				yLast = -hh;
			}
			else {
				
				yLast = hh;
			}
			
			//trace(" hh: "+hh);
			//trace(" hw: "+hw);
			//trace(" globe0: "+_globesList[0].screenZ+", "+_globesList[0].screenRadius);
			//trace(" globe1: "+_globesList[1].screenZ+", "+_globesList[1].screenRadius);
			
			for (i=0; i<3; i++) {
				
				_planeRotatorsList[i].theta = _scene.viewerTheta;
				_planeRotatorsList[i].phi = _scene.viewerPhi;
			}
			
			
			for (i=0; i<2; i++) {
				f = _fragmentsList[i];
				
				yNow = _globesList[i].screenY;
				
				f.x = 0;
				f.y = 0;
				
				_masksList[i].graphics.clear();
				_masksList[i].graphics.moveTo(-hw, yLast);
				_masksList[i].graphics.beginFill(0xffffff*Math.random(), 0.6);
				_masksList[i].graphics.lineTo(hw, yLast);
				_masksList[i].graphics.lineTo(hw, yNow);
				_masksList[i].graphics.lineTo(-hw, yNow);
				_masksList[i].graphics.lineTo(-hw, yLast);
				_masksList[i].graphics.endFill();
				
				//trace(" yNow: "+yNow);
				//trace(" yLast: "+yLast);
				
				yLast = yNow;
				
				
			}
			

			if (_scene.viewerPhi>0) {
				yNow = hh;
			}
			else {
				yNow = -hh;
			}

			f = _fragmentsList[i];
			f.x = 0;
			f.y = 0;
			_masksList[i].graphics.clear();
			_masksList[i].graphics.moveTo(-hw, yLast);
			_masksList[i].graphics.beginFill(0xffffff*Math.random(), 0.6);
			_masksList[i].graphics.lineTo(hw, yLast);
			_masksList[i].graphics.lineTo(hw, yNow);
			_masksList[i].graphics.lineTo(-hw, yNow);
			_masksList[i].graphics.lineTo(-hw, yLast);
			_masksList[i].graphics.endFill();
			
			//trace(" yNow: "+yNow);
			//trace(" yLast: "+yLast);
			
				
		}		
		
		
		protected function drawMask():void {
			
			
		}
		
		
		
		
	}
	
	
}
