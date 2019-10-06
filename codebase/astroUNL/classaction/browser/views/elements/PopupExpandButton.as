
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	
	
	public class PopupExpandButton extends MovieClip {
		
		public static const EXPAND:String = "expand";
		public static const CONTRACT:String = "contract";
		
		protected var _state:String;
		protected var _symbol:Shape;
		protected var _symbolThickness:Number = 2;
		protected var _symbolColor:uint = 0x374040;
		protected var _symbolLength:Number = 9;
		
		public function PopupExpandButton(initState:String=PopupExpandButton.CONTRACT) {
			
			_symbol = new Shape();
			addChild(_symbol);
			
			_state = PopupExpandButton.CONTRACT;
			state = initState;
			
			buttonMode = true;
		}
		
		public function get state():String {
			return _state;
		}
		
		public function set state(arg:String):void {
			if ((arg==PopupExpandButton.EXPAND || arg==PopupExpandButton.CONTRACT) && arg!=_state) _state = arg;
			redraw();
		}
		
		protected function redraw():void {
			var k:Number = _symbolLength/2;			
			_symbol.graphics.clear();
			_symbol.graphics.lineStyle(_symbolThickness, _symbolColor);
			if (_state==PopupExpandButton.EXPAND) {
				// plus sign
				_symbol.graphics.moveTo(-k, 0);
				_symbol.graphics.lineTo(k, 0);
				_symbol.graphics.moveTo(0, -k);
				_symbol.graphics.lineTo(0, k);
			}
			else {
				// minus sign
				_symbol.graphics.moveTo(-k, 0);
				_symbol.graphics.lineTo(k, 0);				
			}
		}
		
	}
	
}
