
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	
	
	public class BinaryFile implements IDownloadable {
		
		public var byteArray:ByteArray;
		
		protected var _downloadState:int = Downloader.NOT_QUEUED;
		protected var _downloadPriority:int = 0;
		protected var _fractionLoaded:Number = 0;
		
		protected var _filename:String;
		
		public function BinaryFile(filename:String, getNow:Boolean=true) {
			_filename = filename;
			if (getNow) Downloader.get(this);
		}
		
		public function get downloadURL():String {
			return _filename;			
		}
		
		public function get downloadFormat():String {
			return URLLoaderDataFormat.BINARY;			
		}
				
		public function set downloadPriority(arg:int):void {
			_downloadPriority = arg;
		}
		
		public function get downloadPriority():int {
			return _downloadPriority;
		}
		
		public function get downloadState():int {
			return _downloadState;			
		}
		
		public function get downloadNoCache():Boolean {
			return false;
		}
		
		public function get fractionLoaded():Number {
			return _fractionLoaded;
		}		
		
		public function onDownloadProgress(bytesLoaded:uint, bytesTotal:uint):void {
			_fractionLoaded = bytesLoaded/bytesTotal;			
		}
		
		public function onDownloadStateChanged(state:int, data:*=null):void {
			_downloadState = state;
			if (_downloadState==Downloader.DONE_SUCCESS) {
				_fractionLoaded = 1;
				byteArray = data;
			}
		}		
		
	}	
}

