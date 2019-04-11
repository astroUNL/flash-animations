
package {
	
	import flash.display.Sprite;
	
	public class PlaneRotator extends Sprite {
		
		protected var _theta:Number = 0;
		protected var _phi:Number = 0;
		
		
		public var _front:Sprite;
		protected var _frontWrapper:Sprite;
		
		protected var _useSeparateBack:Boolean = false;
		
		public function PlaneRotator(clipClass:Class) {
			
			_frontWrapper = new Sprite();
			
			_front = new clipClass();
			
			addChild(_frontWrapper);
				
			_frontWrapper.addChild(_front);
			
		}
	
		public function get phi():Number {
			return _phi;
		}
		
		public function set phi(arg:Number):void {
			_phi = ((arg+180)%360 + 360)%360 - 180;
			_frontWrapper.scaleY = Math.sin(_phi*(Math.PI/180));
		}
		
		public function get theta():Number {
			return _theta;
		}
		public function set theta(arg:Number):void {
			_theta = (arg%360 + 360)%360;
			_front.rotation = _theta;
		}
	}	
	
}
