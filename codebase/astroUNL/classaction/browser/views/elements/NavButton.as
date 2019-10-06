
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class NavButton extends MovieClip {
		
		protected var _enabled:Boolean = true;
		protected var _mouseOver:Boolean = false;
		
		public function NavButton() {
			
			stop();
			
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			tabEnabled = true;
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		}
		
		protected function onClick(evt:MouseEvent):void {
			if (!_enabled) evt.stopImmediatePropagation();
		}
		
		protected function onMouseOut(evt:MouseEvent):void {
			_mouseOver = false;
			refresh();		
		}
		
		protected function onMouseOver(evt:MouseEvent):void {
			_mouseOver = true;
			refresh();			
		}
		
		override public function get enabled():Boolean {
			return _enabled;
		}
		
		override public function set enabled(arg:Boolean):void {
			_enabled = arg;
			buttonMode = _enabled;
			useHandCursor = _enabled;
			refresh();
		}
		
		protected function refresh():void {			
			if (_enabled && _mouseOver) gotoAndStop("enabledMouseOver");
			else if (_enabled) gotoAndStop("enabledMouseOut");
			else gotoAndStop("disabled");			
		}
		
		
	}
	
}

