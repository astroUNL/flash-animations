
package astroUNL.classaction.browser.download {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.Security;
	
	
	public class Downloader {
		
		// these are the recognized download states
		// note: it is assumed elsewhere that all "done" states occur numerically after DONE_SUCCESS
		public static const NOT_QUEUED:int = -1;
		public static const QUEUED:int = 0;
		public static const IN_PROGRESS:int = 1;
		public static const DONE_SUCCESS:int = 2;
		public static const DONE_FAILURE:int = 3;
		
        protected static var _queue:Vector.<IDownloadable> = new Vector.<IDownloadable>();
		protected static var _numLoaders:int = 4;
		protected static var _loaders:Array = [];
		
		public static var baseURL:String = "";
		
		
		public function Downloader() {
			trace("Downloader not meant to be instantiated");
		}
		
		public static function init(baseURL:String=""):void {
			// create the loaders and establish their listeners
			Downloader.baseURL = baseURL;
			var loader:URLLoader;
			for (var i:int = 0; i<_numLoaders; i++) {
				loader = new URLLoader();
				loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.addEventListener(Event.COMPLETE, onComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_loaders[i] = {loader: loader, request: new URLRequest(), item: null, idle: true};
			}
		}		
		
		public static function get(arg:*):void {
			if (arg is IDownloadable) {
				// adds an item to the queue
				if (arg.downloadState!=Downloader.NOT_QUEUED) {
					trace("Warning, attempting to get an item that's already been queued in Downloader");
					return;
				}
				_queue.push(arg);
				arg.onDownloadStateChanged(Downloader.QUEUED);
				keepBusy();
			}
			else if (arg is Array) {
				var item:IDownloadable;
				// add a list of items to the queue
				for (var i:int = 0; i<arg.length; i++) {
					item = (arg[i] as IDownloadable);
					if (item==null) {
						trace("non-IDownloadable passed to Downloader.get");
						continue;
					}
					if (item.downloadState!=Downloader.NOT_QUEUED) continue;
					_queue.push(item);
					item.onDownloadStateChanged(Downloader.QUEUED);
				}
				keepBusy();				
			}
			
		}
		
		public static function cancel(priority:int=0):void {
			// removes all items from the queue with priority less than or equal to the given priority
			for (var i:int = _queue.length-1; i>=0; i--) {
				if (_queue[i].downloadPriority<=priority) {
					_queue[i].onDownloadStateChanged(Downloader.NOT_QUEUED);
					_queue.splice(i, 1);
				}
			}
		}
		
		public static function get queueLength():int {
			return _queue.length;
		}
		
		protected static function onProgress(evt:ProgressEvent):void {
			getLoaderInfoObj(evt.target as URLLoader).item.onDownloadProgress(evt.bytesLoaded, evt.bytesTotal);
		}		
		
		protected static function onComplete(evt:Event):void {
			var loader:URLLoader = evt.target as URLLoader;
			var z:Object = getLoaderInfoObj(loader);
			z.item.onDownloadStateChanged(Downloader.DONE_SUCCESS, loader.data);
			z.item = null;
			z.idle = true;			
			keepBusy();
		}
		
		protected static function onIOError(evt:IOErrorEvent):void {
			var loader:URLLoader = evt.target as URLLoader;
			var z:Object = getLoaderInfoObj(loader);
			z.item.onDownloadStateChanged(Downloader.DONE_FAILURE);
			z.item = null;
			z.idle = true;			
			keepBusy();
		}
		
		protected static function onSecurityError(evt:SecurityErrorEvent):void {
			var loader:URLLoader = evt.target as URLLoader;
			var z:Object = getLoaderInfoObj(loader);
			z.item.onDownloadStateChanged(Downloader.DONE_FAILURE);
			z.item = null;
			z.idle = true;			
			keepBusy();
		}
		
		protected static function keepBusy():void {
			// this function looks to see if any of the loaders are idle
			// if there is an idle loader it then finds the highest priority download
			// and assigns it to that loader
			
			if (_queue.length==0) return;
			
			var sorted:Boolean = false;
			var z:Object;
			
			for (var i:int = 0; i<_numLoaders; i++) {
				
				z = _loaders[i];
				
				if (z.idle) {
					
					z.idle = false;
										
					// if we haven't yet sorted the queue by priority, do so now
					if (!sorted) {
						_queue.sort(Downloader.sortOnPriority);
						sorted = true;
					}
					
					z.item = _queue.shift();
					z.loader.dataFormat = z.item.downloadFormat;
					z.request.url = baseURL + z.item.downloadURL;
					if (z.item.downloadNoCache && Security.sandboxType==Security.REMOTE) {
						z.request.url += "?nocache=" + Math.floor((1e9*Math.random())).toString();
					}
					z.loader.load(z.request);
					z.item.onDownloadStateChanged(Downloader.IN_PROGRESS);
				}
				
				if (_queue.length==0) {
					return;
				}
			}			
		}
		
		protected static function sortOnPriority(x:IDownloadable, y:IDownloadable):Number {
			return (y.downloadPriority - x.downloadPriority);
		}
				
		protected static function getLoaderInfoObj(loader:URLLoader):Object {
			// returns the complete entry in the loaders list associated with the given loader
			var i:int;
			for (i=0; i<_numLoaders; i++) {
				if (loader==_loaders[i].loader) return _loaders[i];				
			}
			return null;
		}
		
	}
}

