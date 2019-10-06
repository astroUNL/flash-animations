
package astroUNL.classaction.browser.events {
	
	// this event is dispatched by navigational elements (nav buttons, breadcrumbs, etc.)
	// to request that the Main controller change the state
	
	import flash.events.Event;
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	
	
	public class StateChangeRequestEvent extends Event {
		
		public static const STATE_CHANGE_REQUESTED:String = "stateChangeRequested";
		
		public var module:Module;
		public var question:Question;
		
		public function StateChangeRequestEvent(module:Module=null, question:Question=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(StateChangeRequestEvent.STATE_CHANGE_REQUESTED, bubbles, cancelable);
			this.module = module;
			this.question = question;
		}
		
		override public function clone():Event {
			return new StateChangeRequestEvent(module, question, bubbles, cancelable);
		}
		
		override public function toString():String {
			return formatToString("StateChangeRequestEvent", "module", "question", "bubbles", "cancelable", "eventPhase"); 
		}
			
	}	
}

