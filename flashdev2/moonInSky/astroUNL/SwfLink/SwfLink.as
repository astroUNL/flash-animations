
package astroUNL.SwfLink {
	
	import flash.display.MovieClip;
	
	import flash.net.LocalConnection;
	import flash.display.Sprite;
	
	import flash.system.Capabilities;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	import flash.events.Event;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	
	import flash.events.IOErrorEvent;

	public class SwfLink extends Sprite {
		
		
		protected var _nextActionNum:uint = 0;
		
		public function SwfLink(url:String=null) {
			_actionsQueue = new Array();
			if (url!=null) load(url);
		}
		
		protected var _connected:Boolean = false;
		
		protected var _failedToEstablishConnection:Boolean = false;		
		protected var _connection:LocalConnection;
		protected var _connectionID:String = null;
		
		protected function onIOError(err:IOErrorEvent):void {
			dispatchEvent(new SwfLinkEvent(SwfLinkEvent.COULD_NOT_CONNECT));
			trace("onIOError, "+err.text+", "+err.target);
		}
		
		protected function onStatus(evt:StatusEvent):void {
			trace("onStatus, "+evt.level+", "+evt.code+", "+evt.target);
		}
		
		protected function onAsyncError(err:AsyncErrorEvent):void {
			trace("onAsyncError, "+err.error+", "+err.target);
		}
		
		protected function onSecurityError(err:SecurityErrorEvent):void {
			trace("onSecurityError, "+err.text+", "+err.target);
		}
		
		
		/**
		* Gets a property on the child swf asynchronously. This function will request a property
		* on the child swf but will exit without waiting for the value. When the value is ready
		* the SwfLink will dispatch an actionDone event. 
		*
		*/
		public function getProperty(propName:String, eventName:String="", extra:*=null):void {
			if (!_connected) {
				dispatchEvent(new SwfLinkEvent(SwfLinkEvent.ACTION_FAIL));
				return;
			}
			doAction({type: "get", propName: propName, eventName: eventName, extra: extra});			
		}
		
		/**
		* Sets a property on the child swf asynchronously. This function will request that the child
		* swf set the property without waiting to verify that it happens. If triggerEvent is true, the
		* SwfLink will dispatch an actionDone event when the property has been set.
		*/
		public function setProperty(propName:String, value:*, eventName:String="", extra:*=null):void {
			if (!_connected) {
				dispatchEvent(new SwfLinkEvent(SwfLinkEvent.ACTION_FAIL));
				return;
			}
			doAction({type: "set", propName: propName, value: value,  eventName: eventName, extra: extra});
		}
		
		/**
		* Calls a function on the child swf asynchronously. This function will request that the child
		* swf call a function, but won't wait for it to finish. If triggerEvent is true then the SwfLink
		* will dispatch an event when the function returns.
		*/
		public function callFunction(funcName:String, argsList:Array=null, eventName:String="", extra:*=null):void {
			if (!_connected) {
				dispatchEvent(new SwfLinkEvent(SwfLinkEvent.ACTION_FAIL));
				return;
			}
			doAction({type: "call", funcName: funcName, argsList: argsList, eventName: eventName, extra: extra});
		}
		
		
	
		
		// it's rather important that _waiting is not set outside of doAction and onActionDone,
		// at least not without carefully studying the possible consequences
		protected var _waiting:Boolean;
		
		protected var _actionsQueue:Array;		
		
		protected function doAction(action:Object):void {
			if (_waiting) {
				_actionsQueue.push(action);
			}
			else {
				_waiting = true;
				_connection.send(_childID, "doAction", action);
			}
		}
		
		public function doNextAction():void {
			_waiting = false;
			if (_actionsQueue.length>0) {
				doAction(_actionsQueue.shift());
			}
		}
		
		
//		public function onActionDone(resultObj:Object):void {
//			_waiting = false;
//			if (_actionsQueue.length>0) {
//				doAction(_actionsQueue.shift());
//			}			
//			if (resultObj.action.eventName!=null && resultObj.action.eventName!="") {
//				//for (var propName in resultObj) trace(" "+propName+": "+resultObj[propName]);
//				dispatchEvent(new SwfLinkEvent(resultObj.action.eventName, false, false, resultObj.value, resultObj.action.type, resultObj.action.name));
//			}
//		}
		
//		public function dispatchCustomEvent(value:*):void {
//			dispatchEvent(new SwfLinkEvent(SwfLinkEvent.CUSTOM_EVENT, false, false, value, null));
//		}
		
		// Communication between the two swfs occurs through LocalConnection channels. In order to
		// establish a one-to-one link between each SwfLink and its loaded swf the connection names
		// must be unique. These connection names have the following forms:
		//  "_SLP...N" - this is the connection opened by this class (the parent)
		//  "_SLC...N" - this is the connection opened by the loaded swf (the child)
		// The "..." part of the name is the group
		// name, consisting of random capital letters. This name is unique to the swf in which
		// the SwfLinks are instantiated. The "N" part of the name is an integer that identifies the
		// channel number, which is unique for each SwfLink instance. The channel number may be
		// more than one digit. Together, the "...N" part of the name forms the connection ID, which
		// is what both the parent SwfLink and child swf need to know in order communicate.
		// One last point: in order to verify that the group name is unique (and to keep other swfs
		// from adopting the same group name) the SwfLink class opens (and leaves open) a
		// LocalConnection channel with the name "_SLG...".
		
		protected var _tempClient:Object;
		
		protected var _childID:String;
		
		protected function onReady():void {
			_connected = true;
			_childID = "_SLC" + _connectionID;
			_connection.send(_childID, "onReady");
			dispatchEvent(new SwfLinkEvent(SwfLinkEvent.READY));
		}
		
		protected var _client:SwfLinkClient;
		protected var _loader:Loader;
		
		public function load(url:String = ""):void {
			
			// get a unique connection id
			if (_connectionID==null) _connectionID = getNewConnectionID();
			
			if (_connectionID==null) {
				// this means failure
				_failedToEstablishConnection = true;
				return;				
			}
			
			_failedToEstablishConnection = false;
			
			_client = new SwfLinkClient(this, onReady);
			
			_childID = null;
			_connected = false;
			
			_connection = new LocalConnection();
			_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			_connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_connection.addEventListener(StatusEvent.STATUS, onStatus);
			_connection.client = _client;
						
			try {
				_connection.connect("_SLP"+_connectionID);
			}
			catch (err:*) {
				_failedToEstablishConnection = true;
				trace(err);
				return;
			}
			
            var variables:URLVariables = new URLVariables();
			variables.SLConnectionID = _connectionID;
			
			var request:URLRequest = new URLRequest(url);
			request.method = "GET";
			if (!Capabilities.isDebugger) request.data = variables;
			
			if (_loader!=null) removeChild(_loader);
			_loader = new Loader();
			addChild(_loader);
			
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			try {
				_loader.load(request);
			}
			catch (err:*) {
				dispatchEvent(new SwfLinkEvent(SwfLinkEvent.COULD_NOT_CONNECT));
			}
		}
		
		static protected var _groupName:String = null;
		static protected var _nextChannelNum:uint = 1;
		static protected var _failedToEstablishGroupName:Boolean = false;
		static protected var _groupLCClient:Object;
		static protected var _groupLC:LocalConnection;
		
		static public function getNewConnectionID():String {
			
			if (_failedToEstablishGroupName) {
				trace("already failed to establish group name");
				return null;
			}
			
			if (_groupName==null) {
				// need to create a group name
				// this needs to be done only once for all instances of the class
				
				// create the test connection
				_groupLCClient = new Object();
				_groupLCClient.emptyFunc = function(...ignored):void {trace("inside empty func")};
				_groupLC = new LocalConnection();
				_groupLC.client = _groupLCClient;
				_groupLC.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _groupLCClient.emptyFunc);
				_groupLC.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _groupLCClient.emptyFunc);
				_groupLC.addEventListener(StatusEvent.STATUS, _groupLCClient.emptyFunc);
				
				var i:int;
				var attempt:int;
				var attemptsLimit:int = 100;
				
				if (Capabilities.isDebugger) _groupName = "debugger";
				else {
					for (attempt=0; attempt<attemptsLimit; attempt++) {
						
						// create a string of random capital letters
						_groupName = "";
						for (i=0; i<12; i++) _groupName += String.fromCharCode(65 + int(26*Math.random()));
						
						try {
							// open the test connection
							_groupLC.connect("_SLG"+_groupName);
							
							// success
							break;
						}
						catch (err:Error) {
							// collision, or other error, try again
						}
					}
				}
				
				if (attempt>=attemptsLimit) {
					// couldn't establish a group name
					// this is a fatal error
					
					_groupName = null;
					_failedToEstablishGroupName = true;
					
					trace("failed to establish group name");
					
					return null;
				}
			}
			
			return _groupName + String(_nextChannelNum++);
		}
		
	}	
}



