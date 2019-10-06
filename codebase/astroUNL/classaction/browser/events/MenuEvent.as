
package astroUNL.classaction.browser.events {
	
	import flash.events.Event;
	
	public class MenuEvent extends Event {
		
		public var data:*;
		
		public function MenuEvent(type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event {
			return new MenuEvent(type, data, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "MenuEvent, type: "+type;
		}
			
	}	
}

