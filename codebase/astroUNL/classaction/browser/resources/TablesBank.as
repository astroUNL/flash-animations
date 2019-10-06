
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.utils.logger.Logger;
	
	public class TablesBank {
	
		public static var lookup:Object = {};
		public static var downloadState:int = Downloader.NOT_QUEUED;
		public static var total:uint = 0;
		public static var loaded:Boolean = false;
		
		public static function add(resource:ResourceItem):void {
			if (lookup[resource.id]!=undefined) Logger.report("duplicate id in resource bank add(), id: "+resource.id+" ("+resource.type+")");
			else total++;
			lookup[resource.id] = resource;
		}		
		
	}	
}
