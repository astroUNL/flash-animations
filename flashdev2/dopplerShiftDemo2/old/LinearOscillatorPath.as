
package {
	
	import flash.display.Sprite;
	
	public class LinearOscillatorPath extends Sprite {
		
		
		protected var _startX:Number;
		protected var _startY:Number;
		protected var _endX:Number;
		protected var _endY:Number;
		
		public function LinearOscillatorPath() {
			
			
			
		}
		
		
		public function update():void {
			
			
			
			graphics.clear();
			graphics.lineStyle(2, 0xff8080);
			graphics.moveTo(_startX, _startY);
			graphics.lineTo(_endX, _endY);
		}		
		
	}	
	
}
