
package {
	
	import flash.display.Sprite;
	
	public class planerotatortest extends Sprite {
		
		protected var _theta:Number = 0;
		protected var _phi:Number = 0;
		
		
		protected var _front:Sprite;
		protected var _back:Sprite;
		protected var _frontWrapper:Sprite;
		protected var _backWrapper:Sprite;
		
		protected var _useSeparateBack:Boolean = false;
		
		public function planerotatortest() {
			
			_frontWrapper = new Sprite();
			_backWrapper = new Sprite();
			
			_front = new testplane();
			_back = new testplane();
			
			addChild(_frontWrapper);
			addChild(_backWrapper);
				
			_frontWrapper.addChild(_front);
			_backWrapper.addChild(_back);
			
			
		}
		

		
		public function get phi():Number {
			return _phi;
		}
		public function set phi(arg:Number):void {
			_phi = ((arg+180)%360 + 360)%360 - 180;
			
			if (_phi>=0) {
				_frontWrapper.visible = true;
				_backWrapper.visible = false;
				_frontWrapper.scaleY = Math.sin(_phi*(Math.PI/180));
			}
			else {
				_frontWrapper.visible = false;
				_backWrapper.visible = true;
				_backWrapper.scaleY = Math.sin(_phi*(Math.PI/180));
			}
		}
		
		public function get theta():Number {
			return _theta;
		}
		public function set theta(arg:Number):void {
			_theta = (arg%360 + 360)%360;
			_front.rotation = _theta;
			_back.rotation = _theta;			
		}
	}	
	
}
