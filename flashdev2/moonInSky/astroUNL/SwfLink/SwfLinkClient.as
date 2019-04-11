
package astroUNL.SwfLink {
		
	import flash.display.MovieClip;
	
	public class SwfLinkClient {
		
		protected var _swfLink:SwfLink;
		protected var _readyHandler:Function;
		
		public function SwfLinkClient(swfLink:SwfLink, readyHandler:Function) {
			_swfLink = swfLink;
			_readyHandler = readyHandler;
		}
		
		public function onReady():void {
			_readyHandler();
		}
		
		public function onActionDone(resultObj:Object):void {
			_swfLink.doNextAction();
			if (resultObj.action.eventName!=null && resultObj.action.eventName.length>0) {
				_swfLink.dispatchEvent(new SwfLinkEvent(resultObj.action.eventName, false, false, resultObj.value, resultObj.action.type));
			}			
		}
		
		public function onDispatchEvent(type:String, value:*):void {
			_swfLink.dispatchEvent(new SwfLinkEvent(type, false, false, value, "event"));
		}		
	}	
}
