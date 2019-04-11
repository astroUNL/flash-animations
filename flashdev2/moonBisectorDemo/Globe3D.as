
package {
	
	import flash.display.DisplayObject;
	
	public class Globe3D extends Globe implements IScene3DObject {
		
		protected var _worldX:Number = 0;
		protected var _worldY:Number = 0;
		protected var _worldZ:Number = 0;
		protected var _screenX:Number = 0;
		protected var _screenY:Number = 0;
		protected var _screenZ:Number = 0;
		
		protected var _scene:Scene3D;
		
		public function Globe3D(scene:Scene3D) {
			_scene = scene;
			_scene.addEventListener("postUpdate", onPostUpdate);
			_scene.addObject(this);
			super();
		}
		
		public function get scene():Scene3D {
			return _scene;
		}
		
		protected var _lastViewerTheta:Number;
		protected var _lastViewerPhi:Number;
		
		
		public var earthBackHack:Boolean = false;
		
		protected function onPostUpdate(...ignored):void {
			if (earthBackHack) {
				//if (_scene.viewerTheta!=_lastViewerTheta || _scene.viewerPhi!=_lastViewerPhi) {
					setViewerThetaAndPhi(_scene.viewerTheta+180, -_scene.viewerPhi);
				//}
				//_lastViewerTheta = _scene.viewerTheta;
				//_lastViewerPhi = _scene.viewerPhi;
				scaleX = -1;
			}
			else {
				//if (_scene.viewerTheta!=_lastViewerTheta || _scene.viewerPhi!=_lastViewerPhi) {
					setViewerThetaAndPhi(_scene.viewerTheta, _scene.viewerPhi);
				//}
				//_lastViewerTheta = _scene.viewerTheta;
				//_lastViewerPhi = _scene.viewerPhi;
			}
		}
		
		protected var _sceneRadius:Number = 1;
		
		override public function get radius():Number {
			return _sceneRadius;			
		}
		
		override public function set radius(arg:Number):void {
			_sceneRadius = arg;			
		}
		
		public function get screenRadius():Number {
			return _sceneRadius*_scene.scale;
		}
		
		override public function update():void {
			var actualRadius = _sceneRadius*_scene.scale;
			if (actualRadius!=_radius) {
				_radius = actualRadius;
				calculateBConstants();
			}
			super.update();			
		}
		
		public function set worldX(arg:Number):void {
			_worldX = arg;
		}
		public function get worldX():Number {
			return _worldX;
		}
		public function set worldY(arg:Number):void {
			_worldY = arg;
		}
		public function get worldY():Number {
			return _worldY;
		}
		public function set worldZ(arg:Number):void {
			_worldZ = arg;
		}
		public function get worldZ():Number {
			return _worldZ;
		}
		public function set screenX(arg:Number):void {
			_screenX = arg;
		}
		public function get screenX():Number {
			return _screenX;
		}
		public function set screenY(arg:Number):void {
			_screenY = arg;
		}
		public function get screenY():Number {
			return _screenY;
		}
		public function set screenZ(arg:Number):void {
			_screenZ = arg;
		}
		public function get screenZ():Number {
			return _screenZ;
		}
			
		public function get displayObj():DisplayObject {
			return this;			
		}
	}	
	
}
