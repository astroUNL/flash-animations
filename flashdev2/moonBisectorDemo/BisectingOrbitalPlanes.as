
package {
	
	public class BisectingOrbitalPlanes {
		
		protected var _scene:Scene3D;
		protected var _globesList:Array = [];
		protected var _fragmentsList:Array = [];
		
		public var show1:Boolean = true;
		public var show2:Boolean = true;
		
//		public var centerX:Number = 0;
//		public var centerY:Number = 0;
//		public var centerZ:Number = 0;
		
		public function BisectingOrbitalPlanes(globe1:Globe3D, globe2:Globe3D) {
			_scene = globe1.scene;
			_scene.addEventListener("preUpdate", onPreUpdate);
			
			_scene.addEventListener("postUpdate", onPostUpdate);
			
			_globesList[0] = globe1;
			_globesList[1] = globe2;
			
			for (var i:int = 0; i<=_globesList.length; i++) {
				_fragmentsList[i] = new BisectingPlaneFragment();
				_scene.addObject(_fragmentsList[i]);
			}
		}
		
		protected function onPreUpdate(...ignored):void {
			var i:int;
			var r:Number;
			var spt:Point3D = new Point3D();
			var wpt:Point3D;
			
			trace("num fragments: "+_fragmentsList.length);
			trace("num globes: "+_globesList.length);
			
			_globesList.sortOn("screenZ", Array.NUMERIC);
			
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
			
			var f:BisectingPlaneFragment;
			
			var hw:Number = (_scene.sceneWidth/2);
			var hh:Number = (_scene.sceneHeight/2);
			
			var yNow:Number;
			var yLast:Number;
			
			
			if (_scene.viewerPhi>0) {
				yLast = -hh;
			}
			else {
				
				yLast = hh;
			}
			
			
			for (i=0; i<_globesList.length; i++) {
				f = _fragmentsList[i];
				
				yNow = _globesList[i].screenY;
				
				f.graphics.clear();
				f.x = 0;
				f.y = 0;
				f.graphics.moveTo(-hw, yLast);
				f.graphics.beginFill(0xffffff*Math.random(), 0.6);
				f.graphics.lineTo(hw, yLast);
				f.graphics.lineTo(hw, yNow);
				f.graphics.lineTo(-hw, yNow);
				f.graphics.lineTo(-hw, yLast);
				f.graphics.endFill();
				
				yLast = yNow;
				
			}

			if (_scene.viewerPhi>0) {
				yNow = hh;
			}
			else {
				yNow = -hh;
			}

			f = _fragmentsList[i];
			f.graphics.clear();
			f.x = 0;
			f.y = 0;
			f.graphics.moveTo(-hw, yLast);
			f.graphics.beginFill(0xffffff*Math.random(), 0.6);
			f.graphics.lineTo(hw, yLast);
			f.graphics.lineTo(hw, yNow);
			f.graphics.lineTo(-hw, yNow);
			f.graphics.lineTo(-hw, yLast);
			f.graphics.endFill();
				
				
//			for (i=0; i<_fragmentsList.length; i++) {
//				f = _fragmentsList[i];
//				
//				yNow = f.screenY;
//				
//				f.graphics.clear();
//				f.x = 0;
//				f.y = 0;
//				
//				f.graphics.moveTo(-hw, yLast);
//				f.graphics.beginFill(0xffffff*Math.random(), 0.3);
//				f.graphics.lineTo(hw, yLast);
//				f.graphics.lineTo(hw, yNow);
//				f.graphics.lineTo(-hw, yNow);
//				f.graphics.lineTo(-hw, yLast);
//				f.graphics.endFill();
//				
//				yLast = yNow;
//			}
			
			
	//		for (var i:int = 0; i<_fragmentsList.length; i++) _fragmentsList[i].graphics.clear();
			
			
			//if (show1) drawMask(-angle1*Math.PI/180, _anglesList1, size1, color1, alpha1, thickness1, 0.8);
		}		
		
		
		protected function drawMask():void {
			
			
		}
		
		
		
		
	}
	
	
}
