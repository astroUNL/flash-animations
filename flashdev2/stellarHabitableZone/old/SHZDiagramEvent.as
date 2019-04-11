
package {
	
	import flash.events.Event;
	
	public class SHZDiagramEvent extends Event {
		
		public var param:* = null;
		public var message:String;
		
		public function SHZDiagramEvent(message:String, param:*=null) {
			super(message);
			this.param = param;			
			this.message = message;
		}
		
		public override function clone():Event {
			return new SHZDiagramEvent(message, param);
		}
	}
	
}
