
package astroUNL.utils.keylistener {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	public class KeyListener {
		
		public function KeyListener() {
			trace("use KeyListener.getListenerProxy() to instantiate the KeyListener");			
		}
		
		protected static var _proxy:Sprite;
		protected static var _keyTable:Vector.<Boolean>;

		public static function getListenerProxy():Sprite {
			if (_proxy==null) {
				_proxy = new Sprite();
				_proxy.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				_keyTable = new Vector.<Boolean>(256, true);
				reset();
			}
			return _proxy;
		}
		
		public static function reset():void {
			for (var i:int = 0; i<256; i++) _keyTable[i] = false;			
		}
		
		public static function isDown(keyCode:uint):Boolean {
			if (_keyTable==null || keyCode>255) return false;
			else return _keyTable[keyCode];			
		}
		
		protected static function onAddedToStage(evt:Event):void {
			_proxy.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpFunc);
			_proxy.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc);
		}
		
		protected static function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode<256) _keyTable[evt.keyCode] = true;
		}
		
		protected static function onKeyUpFunc(evt:KeyboardEvent):void {
			if (evt.keyCode<256) _keyTable[evt.keyCode] = false;
		}
		
	}	
}
