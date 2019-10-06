
package astroUNL.classaction.browser.download {
	
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	
	public interface IDownloadable {
		
		// the download url is the address of the resource -- the Downloader will 
		// concatenate this with its baseURL when making the request 
		function get downloadURL():String;
		
		// the data format specifies whether to download the data as text or binary
		function get downloadFormat():String;
		
		// the download priority tells the downloader how important the download
		// is -- higher values jump ahead in line
		function get downloadPriority():int;
		
		// downloadState should be read-only
		// it is set to one of the predefined values (see Downloader)
		// via the onDownloadStateChanged function
		function get downloadState():int;
		
		// the downloadNoCache property tells the downloader
		// whether to try to force a fresh download (when true)
		function get downloadNoCache():Boolean;
		
		// the onDownloadProgress function is called as the download progresses
		// it is NOT called when the download finishes
		function onDownloadProgress(bytesLoaded:uint, bytesTotal:uint):void;
		
		// - the onDownloadStateChanged function is called when the state of the 
		// download changes (see the Downloader file for the different states)
		// - the implementation of this function is responsible for setting the
		// value of the downloadState property to the value being passes
		// - when the download state is being set to DONE_SUCCESS the data
		// argument will be the downloaded data, otherwise data is undefined
		function onDownloadStateChanged(state:int, data:*=null):void;
	}
}
