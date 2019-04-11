
package {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class BisectingPlaneFragment extends Sprite implements IScene3DObject {
		
		protected var _worldX:Number = 0;
		protected var _worldY:Number = 0;
		protected var _worldZ:Number = 0;
		protected var _screenX:Number = 0;
		protected var _screenY:Number = 0;
		protected var _screenZ:Number = 0;
		
		public function get displayObj():DisplayObject {
			return this;
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
				
	}	
}

