
package {
	
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Graphics;
	
	public class SHZSystemHistoryTag extends Sprite {
		
		
		public var color:uint = 0x303030;
		public var text:String = "";
		
		public var delta:Number = 3;
		public var margin:Number = 1;
		
		protected var _position:String = "below";
		
		protected var _tf:TextFormat;
		
		protected var _arrow:Sprite;
		protected var _text:TextField;
		
		public function SHZSystemHistoryTag(position:String="below", text:String="", color:uint=0x303030) {
			_position = position;
			
			this.text = text;
			this.color = color;
			
			_arrow = new Sprite();
			addChild(_arrow);
			
			_tf = new TextFormat("Verdana", 10, color);
			_tf.align = "center";
			
			_text = new TextField();
			_text.selectable = false;
			_text.autoSize = "center";
			_text.embedFonts = true;
			_text.multiline = true;
			//_text.border = true;
			addChild(_text);
			
			update();			
		}
		
		public function update():void {
			
			_text.text = "";
			_text.defaultTextFormat = _tf;
			_text.width = 0;
			_text.height = 0;
			_text.text = text;
			
			
			
			var g:Graphics = _arrow.graphics;
			g.clear();
			g.moveTo(0, 0);
			g.beginFill(color);
			if (_position=="above") {
				g.lineTo(delta, -delta);
				g.lineTo(-delta, -delta);
				
				_text.y = -_text.height - delta - margin;
			}
			else {
				g.lineTo(-delta, delta);
				g.lineTo(delta, delta);
				
				_text.y = delta + margin - 2;
			}
			g.lineTo(0, 0);
			g.endFill();
			
			offsetText(0);
		}	
		
		
		public function offsetText(offset:Number):void {
			_text.x = offset - _text.width/2;
//			if (offset<0) {
//				_tf.align = "right";
//			}
//			else if (offset>0) {
//				_tf.align = "left";
//			}
//			else {
//				_tf.align = "center";
//			}
//			_text.setTextFormat(_tf);
		}
	}
	
}

