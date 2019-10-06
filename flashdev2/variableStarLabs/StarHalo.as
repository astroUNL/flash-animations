
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	public class StarHalo extends Sprite {
		
		private var _index:uint;
		private var _haloSP:Sprite;
		private var _radius:Number;
			
		public function StarHalo(dataObj):void {
			x = dataObj.x;
			y = dataObj.y;
			
			_index = dataObj.index;
			_radius = dataObj.radius;
			
			graphics.clear();
			graphics.beginFill(0xff0000, 0);
			graphics.drawCircle(0.5, 0.5, _radius);
			graphics.endFill();
			
			_haloSP = new Sprite();
			addChild(_haloSP);
			
			addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDownFunc);
		}
		
		public function get index():uint {
			return _index;			
		}
		
		public function drawHalo(thickness:Number, color:uint, alpha:Number, shape:String):void {
			if (shape=="circle") {
				_haloSP.graphics.clear();
				_haloSP.graphics.lineStyle(thickness, color, alpha);
				_haloSP.graphics.drawCircle(0.5, 0.5, _radius);
			}
			else if (shape=="square") {
				_haloSP.graphics.clear();
				_haloSP.graphics.lineStyle(thickness, color, alpha);
				_haloSP.graphics.moveTo(-_radius, -_radius);
				_haloSP.graphics.lineTo(-_radius, _radius);
				_haloSP.graphics.lineTo(_radius, _radius);
				_haloSP.graphics.lineTo(_radius, -_radius);
				_haloSP.graphics.lineTo(-_radius, -_radius);
			}
		}
		
		private function onMouseDownFunc(...ignored):void {
			dispatchEvent(new Event("haloClicked"));
		}
	}
	
}
