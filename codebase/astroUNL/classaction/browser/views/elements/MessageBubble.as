
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	
	public class MessageBubble extends Sprite {
		
		
		public function MessageBubble() {
			
			_background = new Shape();
			addChild(_background);
			
			_format = new TextFormat("Verdana", 14, 0x0, false);
			_format.align = "center";
			
			_field = new TextField();
			_field.embedFonts = true;
			_field.autoSize = "center";
			_field.selectable = false;
			_field.defaultTextFormat = _format;
			addChild(_field);
			
		}
		
		protected var _background:Shape;
		protected var _field:TextField;
		protected var _format:TextFormat;
		
		
		public function setMessage(str:String):void {
			_field.width = 0;
			_field.height = 0;
			_field.htmlText = str;
			
			_background.graphics.clear();
			_background.graphics.moveTo(_field.x, _field.y);
			_background.graphics.beginFill(0xffa0a0);
			_background.graphics.lineTo(_field.x+_field.width, _field.y);
			_background.graphics.lineTo(_field.x+_field.width, _field.y+_field.height);
			_background.graphics.lineTo(_field.x, _field.y+_field.height);
			_background.graphics.lineTo(_field.x, _field.y);
			_background.graphics.endFill();
		}
				
	}
}

