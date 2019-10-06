
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.utils.logger.Logger;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	
	public class ModulesList extends EventDispatcher implements IDownloadable {
		
		// loadFinished dispatched when the module has finished loading (not necessarily successfully, check the loaded property)
		public static const LOAD_FINISHED:String = "loadFinished";
		
		// the update event is dispatched when the modules list is changed after loading
		public static const UPDATE:String = "update";
		
		protected var _name:String = "";
		protected var _filename:String = "";
		protected var _fractionLoaded:Number = 0;
		protected var _downloadState:int = Downloader.NOT_QUEUED;
		protected var _listLoaded:Boolean = false;
		protected var _loadFinished:Boolean = false;
		
		public var modules:Array = [];
		
		public function ModulesList(filename:String) {
			_filename = filename;
			
			Downloader.get(this);			
		}
		
		public function hasModule(module:Module):Boolean {
			for each (var m:Module in modules) if (m==module) return true;
			return false;			
		}
		
		public function get downloadURL():String {
			return _filename;
		}
		
		public function get downloadFormat():String {
			return URLLoaderDataFormat.TEXT;
		}
		
		public function get downloadPriority():int {
			return 2000001;
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
			else if (_downloadState==Downloader.DONE_FAILURE) {
				_loadFinished = true;
				dispatchEvent(new Event(ModulesList.LOAD_FINISHED));
			}
		}
		
		public function removeModule(module:Module):Boolean {
			var success:Boolean = false;
			for (var i:int = 0; i<modules.length; i++) {
				if (modules[i]==module) {
					module.release();
					modules.splice(i, 1);
					success = true;
					break;
				}
			}
			if (success) {
				QuestionsBank.prune();
				dispatchEvent(new Event(ModulesList.UPDATE));
			}
			return success;
		}
		
		public function addModule(module:Module):void {
			modules.push(module);
			dispatchEvent(new Event(ModulesList.UPDATE));			
		}
		
		protected function parseData(data:String):void {
			try {
				
				var moduleFilenamesList:XML = new XML(data);
				
				var module:Module;
				var filename:XML;
				
				modules = [];
				
				for each (filename in moduleFilenamesList.elements()) {
					module = new Module(filename.toString());
					module.addEventListener(Module.LOAD_FINISHED, onModuleLoadFinished);					
					modules.push(module);
				}
				
				_listLoaded = true;
			}
			catch (err:Error) {
				_loadFinished = true;
				dispatchEvent(new Event(ModulesList.LOAD_FINISHED));
			}
		}
		
		protected function onModuleLoadFinished(evt:Event):void {
			var allDone:Boolean = true;
			var i:int;
			for (i=0; i<modules.length; i++) {
				if (!modules[i].loadFinished) {
					allDone = false;
					break;
				}				
			}
			if (allDone) {
								
				// now go through the list and weed out all modules that did not load
				for (i=modules.length-1; i>=0; i--) {
					if (!modules[i].loaded) {
						
						// report the error
						if (modules[i].downloadState==Downloader.DONE_FAILURE) Logger.report(modules[i].downloadURL+" could not be loaded.");
						else Logger.report(modules[i].downloadURL+" could not be parsed.");
						
						// remove the module from the list
						modules.splice(i, 1);
					}
				}
				
				_loadFinished = true;
				dispatchEvent(new Event(ModulesList.LOAD_FINISHED));
			}
			
		}
		
		// the listLoaded property will be true once the modules list file is loaded and successfully parsed
		public function get listLoaded():Boolean {
			return _listLoaded;
		}
		
		// the loadFinished property is true when...
		//   - the modules list file could not be loaded or parsed
		//   - all the module files have finished loading, whether successfully or not
		// note that this means the load finished property may be false while the xmlLoaded property is true
		public function get loadFinished():Boolean {
			return _loadFinished;
		}
		
	}
}

