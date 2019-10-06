
package astroUNL.utils.logger {
	
	public class Logger {
		
		public function Logger() {
			trace("Logger not meant to be instantiated");			
		}
		
		public static function report(error:String):void {
			trace("LOGGER: "+error);
			
		}
		
	}
}
