
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	
	import flash.events.MouseEvent;
	
	public class Spectrum extends Sprite {
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _background:Shape;
		protected var _content:Sprite;
		protected var _mask:Shape;
		protected var _border:Shape;
		
		protected var _data:Array;
		
		protected const _minF:Number = 0;
		protected var _minW:Number, _maxW:Number, _maxF:Number;
		
		public function Spectrum(w:Number, h:Number, data:Array, minW:Number, maxW:Number, maxF:Number) {
			
			_width = w;
			_height = h;
			_data = data;
			_minW = minW;
			_maxW = maxW;
			_maxF = maxF;
			
			_background = new Shape();
			addChild(_background);
			
			_content = new Sprite();
			addChild(_content);
			
			_mask = new Shape();
			addChild(_mask);
			
			_border = new Shape();
			addChild(_border);
			
			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc);
			
			_content.mask = _mask;			
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {
			var w:Number = _minW + mouseX*(_maxW - _minW)/_width;
		}
		
		protected var _backgroundColor:uint = 0xffffff;
		protected var _backgroundAlpha:Number = 1;
		protected var _borderThickness:Number = 1;
		protected var _borderColor:uint = 0x000000;
		protected var _borderAlpha:Number = 1;
		
		protected var _redshift:Number = 0;
		
		public function get redshift():Number { 
			return _redshift;		
		}
		
		public function set redshift(arg:Number):void {
			_redshift = arg;
			redraw();			
		}
		
		public function redraw():void {
			
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_background.graphics.drawRect(0, -_height, _width, _height);
			_background.graphics.endFill();
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(0, -_height, _width, _height);
			_mask.graphics.endFill();
			
			_border.graphics.clear();
			_border.graphics.lineStyle(_borderThickness, _borderColor, _borderAlpha);
			_border.graphics.drawRect(0, -_height, _width, _height);
		}
		
		
	}	
}
