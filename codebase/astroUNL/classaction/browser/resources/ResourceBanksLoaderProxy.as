
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat
	
	
	public class ResourceBanksLoaderProxy extends EventDispatcher implements IDownloadable {
		
		protected var _type:String;
		protected var _downloadState:int = Downloader.NOT_QUEUED;
		protected var _fractionLoaded:Number = 0;
		protected var _total:uint = 0;
		protected var _loaded:Boolean = false;
		protected var _loadFinished:Boolean = false;
		
		public var lookup:Object = {};
		
		
		public function ResourceBanksLoaderProxy(type:String) {
			_type = type;
		}	
		
		public function get downloadURL():String {
			return _type + "s/" + _type + "s.xml";
		}		
		
		public function get downloadFormat():String {
			return URLLoaderDataFormat.TEXT;
		}
		
 		public function get downloadPriority():int {
			return 2000002;
		}
		
		public function get downloadState():int {
			return _downloadState;
		}
		
		public function get downloadNoCache():Boolean {
			return true;
		}
		
		public function onDownloadProgress(bytesLoaded:uint, bytesTotal:uint):void {
			_fractionLoaded = bytesLoaded/bytesTotal;
		}
		
 		public function onDownloadStateChanged(state:int, data:*=null):void {
			_downloadState = state;
			if (_downloadState==Downloader.DONE_SUCCESS) {
				_fractionLoaded = 1;
				parseData(data);
			}
			if (_downloadState==Downloader.DONE_SUCCESS || _downloadState==Downloader.DONE_FAILURE) {
				_loadFinished = true;
				dispatchEvent(new Event(ResourceBanksLoader.LOAD_FINISHED));
			}
		}
		
		protected function parseData(data:String):void {
			try {
				var bank:XML = new XML(data);
				var itemXML:XML;
				
				_total = 0;
				
				if (_type==ResourceItem.QUESTION) {
					var question:Question;
					for each (itemXML in bank.elements()) {
						question = new Question(itemXML);
						if (question.id.slice(0, 11)=="ca_divider_") continue;
						if (lookup[question.id]!=undefined) Logger.report("duplicate id in ResourceBanksLoaderProxy, id: "+question.id+" ("+_type+")");
						else _total++;
						lookup[question.id] = question;
					}						
				}
				else {
					var item:ResourceItem;
					for each (itemXML in bank.elements()) {
						item = new ResourceItem(_type, itemXML);
						if (lookup[item.id]!=undefined) Logger.report("duplicate id in ResourceBanksLoaderProxy, id: "+item.id+" ("+_type+")");
						else _total++;
						lookup[item.id] = item;
					}
				}
				
				_loaded = true;
			}
			catch (err:Error) {
				//
			}
		}
		
		public function get total():uint {
			return _total;
		}
		
		// the loaded property will be true once the resource bank is loaded and successfully parsed
		public function get loaded():Boolean {
			return _loaded;
		}
		
		// the loadFinished property is true once the process of loading and parsing the xml file
		// is over, even if that process ended in failure
		public function get loadFinished():Boolean {
			return _loadFinished;
		}
		
	}	
}

