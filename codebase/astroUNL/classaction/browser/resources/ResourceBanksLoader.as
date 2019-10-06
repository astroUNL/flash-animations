
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	public class ResourceBanksLoader {
		
		// this static class is used to load the resource banks static classes
		
		// all that's needed is to add a listener for the LOAD_FINISHED event
		// and call the start() function; when loading is finished the resource bank
		// classes will be filled with their data (if there was a failure the
		// loaded property of a resource bank will be false and the downloadState
		// property can be used to diagnose where the fault lies)
		
	
		public static const LOAD_FINISHED:String = "loadFinished";
		
		
		protected static var _dispatcherProxy:EventDispatcher;
		
		protected static var _questionsProxy:ResourceBanksLoaderProxy;
		protected static var _animationsProxy:ResourceBanksLoaderProxy;
		protected static var _imagesProxy:ResourceBanksLoaderProxy;
		protected static var _tablesProxy:ResourceBanksLoaderProxy;
		protected static var _outlinesProxy:ResourceBanksLoaderProxy;
		
		
		public function ResourceBanksLoader() {
			//
		}
		
		public static function start():void {
			if (_questionsProxy==null) {
								
				_questionsProxy = new ResourceBanksLoaderProxy(ResourceItem.QUESTION);
				_questionsProxy.addEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				Downloader.get(_questionsProxy);
				
				_animationsProxy = new ResourceBanksLoaderProxy(ResourceItem.ANIMATION);
				_animationsProxy.addEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				Downloader.get(_animationsProxy);
				
				_imagesProxy = new ResourceBanksLoaderProxy(ResourceItem.IMAGE);
				_imagesProxy.addEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				Downloader.get(_imagesProxy);
			
				_tablesProxy = new ResourceBanksLoaderProxy(ResourceItem.TABLE);
				_tablesProxy.addEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				Downloader.get(_tablesProxy);
				
				_outlinesProxy = new ResourceBanksLoaderProxy(ResourceItem.OUTLINE);
				_outlinesProxy.addEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				Downloader.get(_outlinesProxy);
				
				
				QuestionsBank.downloadState = _questionsProxy.downloadState;
				QuestionsBank.loaded = _questionsProxy.loaded;
				
				AnimationsBank.downloadState = _animationsProxy.downloadState;
				AnimationsBank.loaded = _animationsProxy.loaded;

				ImagesBank.downloadState = _imagesProxy.downloadState;
				ImagesBank.loaded = _imagesProxy.loaded;

				TablesBank.downloadState = _tablesProxy.downloadState;
				TablesBank.loaded = _tablesProxy.loaded;

				OutlinesBank.downloadState = _outlinesProxy.downloadState;
				OutlinesBank.loaded = _outlinesProxy.loaded;
				
			}	
		}
		
		protected static function onLoadFinished(evt:Event):void {			
			if (finished) {
				
				QuestionsBank.downloadState = _questionsProxy.downloadState;
				QuestionsBank.loaded = _questionsProxy.loaded;
				QuestionsBank.total = _questionsProxy.total;
				QuestionsBank.lookup = _questionsProxy.lookup;
				
				AnimationsBank.downloadState = _animationsProxy.downloadState;
				AnimationsBank.loaded = _animationsProxy.loaded;
				AnimationsBank.total = _animationsProxy.total;
				AnimationsBank.lookup = _animationsProxy.lookup;
	
				ImagesBank.downloadState = _imagesProxy.downloadState;
				ImagesBank.loaded = _imagesProxy.loaded;
				ImagesBank.total = _imagesProxy.total;
				ImagesBank.lookup = _imagesProxy.lookup;
	
				TablesBank.downloadState = _tablesProxy.downloadState;
				TablesBank.loaded = _tablesProxy.loaded;
				TablesBank.total = _tablesProxy.total;
				TablesBank.lookup = _tablesProxy.lookup;
	
				OutlinesBank.downloadState = _outlinesProxy.downloadState;
				OutlinesBank.loaded = _outlinesProxy.loaded;
				OutlinesBank.total = _outlinesProxy.total;
				OutlinesBank.lookup = _outlinesProxy.lookup;
				
				
				_questionsProxy.removeEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				_questionsProxy = null;
				
				_animationsProxy.removeEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				_animationsProxy = null;
				
				_imagesProxy.removeEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				_imagesProxy = null;
				
				_tablesProxy.removeEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				_tablesProxy = null;
				
				_outlinesProxy.removeEventListener(ResourceBanksLoader.LOAD_FINISHED, onLoadFinished);
				_outlinesProxy = null;
				
				
				if (_dispatcherProxy!=null) _dispatcherProxy.dispatchEvent(new Event(ResourceBanksLoader.LOAD_FINISHED));
			}
		}
		
		public static function get finished():Boolean {
			if (_questionsProxy==null) return false;
			else return (_questionsProxy.loadFinished && _animationsProxy.loadFinished && _imagesProxy.loadFinished && _tablesProxy.loadFinished && _outlinesProxy.loadFinished);			
		}
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			if (_dispatcherProxy==null) _dispatcherProxy = new EventDispatcher();
			_dispatcherProxy.addEventListener(type, listener, useCapture, priority, useWeakReference);			
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			if (_dispatcherProxy==null) return;
			_dispatcherProxy.removeEventListener(type, listener, useCapture);			
		}

		
	}
	
}

