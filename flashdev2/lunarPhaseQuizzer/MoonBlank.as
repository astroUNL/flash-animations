
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData
	
	public class MoonBlank extends Sprite {
		
//		protected var _mask:Shape;
//		protected var _lines:Shape;

		protected var _background:Shape;
				
//		protected var _lineColor:uint = 0xe8e8e8;
//		protected var _lineThickness:Number = 1;
//		protected var _lineAlpha:Number = 1;
//		protected var _lineSpacing:Number = 4;
//		protected var _lineRotation:Number = 0;
		
//		protected var _color1:uint = 0x606060;
//		protected var _color2:uint = 0x808080;
//		protected var _blockSize:int = 4;
		
		public function MoonBlank(radius:Number) {
			
			_background = new Shape();
			_background.graphics.beginFill(0x101010);
			_background.graphics.lineStyle(1, 0x606060);
			_background.graphics.drawCircle(0, 0, radius);
			_background.graphics.endFill();
			addChild(_background);
			
			// this block does lines
//			_lines = new Shape();
//			_lines.graphics.lineStyle(_lineThickness, _lineColor, _lineAlpha);
//			_lines.graphics.moveTo(-radius, 0);
//			_lines.graphics.lineTo(radius, 0);
//			var lineY:Number = _lineSpacing;
//			while (lineY<radius) {
//				_lines.graphics.moveTo(-radius, lineY);
//				_lines.graphics.lineTo(radius, lineY);
//				_lines.graphics.moveTo(-radius, -lineY);
//				_lines.graphics.lineTo(radius, -lineY);
//				lineY += _lineSpacing;
//			}
//			addChild(_lines);
//			_lines.rotation = _lineRotation;
//			_mask = new Shape();
//			_mask.graphics.beginFill(0xff0000);
//			_mask.graphics.drawCircle(0, 0, radius);
//			_mask.graphics.endFill();
//			addChild(_mask);			
//			_lines.mask = _mask;
			
			
			// this block does a checkered pattern
//			var tmp:Shape = new Shape();
//			tmp.graphics.beginFill(_color1);
//			tmp.graphics.drawRect(0, 0, _blockSize, _blockSize);
//			tmp.graphics.endFill();
//			tmp.graphics.beginFill(_color2);
//			tmp.graphics.drawRect(_blockSize, 0, _blockSize, _blockSize);
//			tmp.graphics.endFill();
//			tmp.graphics.beginFill(_color2);
//			tmp.graphics.drawRect(0, _blockSize, _blockSize, _blockSize);
//			tmp.graphics.endFill();
//			tmp.graphics.beginFill(_color1);
//			tmp.graphics.drawRect(_blockSize, _blockSize, _blockSize, _blockSize);
//			tmp.graphics.endFill();
//			var bmd:BitmapData = new BitmapData(2*_blockSize, 2*_blockSize, false);
//			bmd.draw(tmp);
//			_background.graphics.beginBitmapFill(bmd);
//			_background.graphics.drawCircle(0, 0, radius);
//			_background.graphics.endFill();
			
		}
		
	}
}

