
package {
	
	import flash.display.Sprite;
	
	
	public class WavePlot extends Sprite {
		
		
		protected var _backgroundColor:uint = 0xffffff;
		protected var _backgroundAlpha:Number = 1;
		protected var _borderThickness:Number = 1;
		protected var _borderColor:uint = 0x808080;
		protected var _borderAlpha:Number = 1;
		
		protected var _plotWidth:Number = 400;
		protected var _plotHeight:Number = 80;
		
		protected var _backgroundSP:Sprite;
		protected var _borderSP:Sprite;
		
		public function WavePlot() {
			_backgroundSP = new Sprite();
			_borderSP = new Sprite();
			
			addChild(_backgroundSP);
			addChild(_borderSP);
			
			redraw();
		}
		
		
		public function redraw():void {
			
			_borderSP.graphics.clear();
			_borderSP.graphics.lineStyle(_borderThickness, _borderColor, _borderAlpha);
			_borderSP.graphics.moveTo(0, 0);
			_borderSP.graphics.lineTo(_plotWidth, 0);
			_borderSP.graphics.lineTo(_plotWidth, _plotHeight);
			_borderSP.graphics.lineTo(0, _plotHeight);
			_borderSP.graphics.lineTo(0, 0);
			
			
			_backgroundSP.graphics.clear();
			_backgroundSP.graphics.moveTo(0, 0);
			_backgroundSP.graphics.beginFill(0xfafafa);
			_backgroundSP.graphics.lineTo(_plotWidth, 0);
			_backgroundSP.graphics.lineTo(_plotWidth, _plotHeight);
			_backgroundSP.graphics.lineTo(0, _plotHeight);
			_backgroundSP.graphics.lineTo(0, 0);
			_backgroundSP.graphics.endFill();
			
		}
		
		
		
	}
	
	
}
