
package astroUNL.SwfLink {
	
	import flash.events.Event;
	
	public class SwfLinkEvent extends Event {
		
		/**
		* actionReady is dispatched when an action performed by the child swf is done.
		* For example, calling a function or getting a value.
		*/
		public static const ACTION_DONE:String = "actionDone";
		
		/**
		* actionFail is dispatched when a process that would normally dispatch actionReady
		* has been aborted. 
		*/
		public static const ACTION_FAIL:String = "actionFail";
		
		/**
		* couldNotConnect is dispatched when the connection could not be established.
		*/
		public static const COULD_NOT_CONNECT:String = "couldNotConnect";
		
		/**
		* connected is dispatched when the connection has been established and is ready.
		*/
		public static const READY:String = "ready";
		
		/**
		* connectionFailed is dispatched when the connection has unexpectedly failed.
		*/
		public static const CONNECTION_FAILED:String = "connectionFailed";
		
		/**
		* disconnected is dispatched when the connection has closed normally.
		*/
		public static const DISCONNECTED:String = "disconnected";
		
		public function SwfLinkEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, value:*=null, actionType:String="") {
			super(type, bubbles, cancelable);
			_actionType = actionType;
			_value = value;
			_name = name;
			_requestID = requestID;
		}
		
		protected var _value:* = null;
		protected var _actionType:String = null;
		protected var _name:String = null;
		protected var _requestID:* = null;
		
		public function get actionType():String {
			return _actionType;
		}
		
		public function get value():* {
			return _value;
		}
		
		public function get name():String {
			return _name;			
		}
		
		public function get requestID():* {
			return _requestID;			
		}
		
		override public function toString():String {
			return "SwfLinkEvent, actionType: "+_actionType+", value: "+_value+", type: "+type;
		}

		override public function clone():Event {
			return new SwfLinkEvent(type, bubbles, cancelable, _value, _actionType);
		}		
	}
}
