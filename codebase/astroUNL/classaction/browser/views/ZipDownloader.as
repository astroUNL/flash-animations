
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.BinaryFile;
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.Main;
	
	import astroUNL.utils.logger.Logger;
	
	import nochump.util.zip.ZipOutput;
	import nochump.util.zip.ZipEntry;	
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.net.FileReference;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	
	
	public class ZipDownloader extends Sprite {
		
		public static const DONE:String = "done";
		
		protected var _downloadWindow:Sprite;
		protected var _background:Sprite;		
		protected var _browserSwf:BinaryFile;
		protected var _startHtml:BinaryFile;
		protected var _swfobjectJs:BinaryFile;
		protected var _swfHtmlTemplateFile:BinaryFile;
		protected var _imageHtmlTemplateFile:BinaryFile;
		protected var _downloadPoller:Timer;
		protected var _backdrop:Bitmap;
		protected var _modulesList:ModulesList;
		protected var _fr:FileReference;
		
		protected var _swfHtmlTemplate:String;
		protected var _imageHtmlTemplate:String;
		
		protected var _saveButton:ClickableText;		
		protected var _cancelButton:ClickableText;
		protected var _progressBar:Shape;
		
		protected var _zipPoller:Timer;
		protected var _zipStepTime:Number = 30;
		
		protected var _zipReadyMessage:String = "zip file is ready - click here to save";
		protected var _zipPrepMessage:String = "please wait while the zip file is prepared";
		
		protected var _saveButtonPrepY:Number = -50;
		protected var _saveButtonReadyY:Number = -40;
		
		protected var _modulesXML:XML;
		protected var _questionsXML:XML;
		protected var _animationsXML:XML;
		protected var _imagesXML:XML;
		protected var _outlinesXML:XML;
		protected var _tablesXML:XML;
		protected static const rootURL:String = "";
		protected static const baseURL:String = rootURL + "classaction/";
		
		
		public function ZipDownloader() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(evt:Event):void {
			
			_backdrop = new Bitmap();
			_backdrop.filters = [new BlurFilter(5, 5, 2)];
			addChild(_backdrop);
			
			var kx:Number = 200;
			var ky:Number = 90;
			
			_downloadWindow = new Sprite();
			_downloadWindow.x = stage.stageWidth/2;
			_downloadWindow.y = stage.stageHeight/2;
			addChild(_downloadWindow);
			
			_background = new Sprite();
			_background.graphics.beginFill(0x272D2E, 1);
			_background.graphics.lineStyle(1, 0x404848);
			_background.graphics.drawRect(-kx, -ky, 2*kx, 2*ky);
			_background.graphics.endFill();
			_downloadWindow.addChild(_background);
			
			_progressBar = new Shape();
			_progressBar.x = 0;
			_progressBar.y = -20;
			_downloadWindow.addChild(_progressBar);
			
			_saveButton = new ClickableText();
			_saveButton.addEventListener(ClickableText.ON_CLICK, onSave);
			_saveButton.x = 0;
			_saveButton.y = -50;
			_downloadWindow.addChild(_saveButton);
			
			_cancelButton = new ClickableText("cancel");
			_cancelButton.addEventListener(ClickableText.ON_CLICK, onCancel);
			_cancelButton.x = 0 - (_cancelButton.width/2);
			_cancelButton.y = 20;
			_downloadWindow.addChild(_cancelButton);
					 
			_fr = new FileReference();
			
			_browserSwf = new BinaryFile("~DO_NOT_DELETE~browser.swf");			
			_startHtml = new BinaryFile("~DO_NOT_DELETE~start.html");
			
			_swfobjectJs = new BinaryFile("swfobject.js");
			
			_swfHtmlTemplateFile = new BinaryFile("~DO_NOT_DELETE~downloaded_swf_html_template.html");	
			_imageHtmlTemplateFile = new BinaryFile("~DO_NOT_DELETE~downloaded_image_html_template.html");	

			_downloadPoller = new Timer(20);
			_downloadPoller.addEventListener(TimerEvent.TIMER, onDownloadPoll);
			
			_zipPoller = new Timer(_zipStepTime*1.2);
			_zipPoller.addEventListener(TimerEvent.TIMER, onZipPoll);
		}
		
		public function set modulesList(arg:ModulesList):void {
			_modulesList = arg;
		}
		
		public function setMainWindowDimensions(w:Number, h:Number):void {
			_downloadWindow.x = w/2;
			_downloadWindow.y = h/2;
			if (visible) createBlurredBackdrop();
		}
		
		protected function createBlurredBackdrop():void {
			var wasVisible:Boolean = visible;			
			visible = false;
			var bmd:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0);
			bmd.draw(stage);
			_backdrop.bitmapData = bmd;			
			visible = wasVisible;
		}
		
		protected var _numberOfCustomModules:int;
		protected var _numberOfCustomModuleQuestions:int;
		
		public function start():void {
			
			// must first download all the necessary files (if not already done) before making zip
			
			createBlurredBackdrop();
			
			// set appearance
			_saveButton.setText(_zipPrepMessage);
			_saveButton.x = -_saveButton.width/2;
			_saveButton.y = _saveButtonPrepY;
			_saveButton.setClickable(false);
			_progressBar.visible = true;
			
			_numberOfCustomModules = 0;
			_numberOfCustomModuleQuestions = 0;
			
			// determine the number of custom modules and questions
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					_numberOfCustomModules++;
					_numberOfCustomModuleQuestions += _modulesList.modules[i].allQuestionsList.length;
				}
			}

			if (!checkForDoneness()) {
				// some of the files are not yet downloaded
				
				var i:int, j:int;
				
				// get the files and thumbnails
				for (i=0; i<_modulesList.modules.length; i++) {
					if (!_modulesList.modules[i].readOnly) {
						Downloader.get(_modulesList.modules[i].allQuestionsList);
						Downloader.get(_modulesList.modules[i].animationsList);
						Downloader.get(_modulesList.modules[i].imagesList);
						Downloader.get(_modulesList.modules[i].outlinesList);
						Downloader.get(_modulesList.modules[i].tablesList);
						
						getThumbs(_modulesList.modules[i].animationsList);
						getThumbs(_modulesList.modules[i].imagesList);
						getThumbs(_modulesList.modules[i].outlinesList);
						getThumbs(_modulesList.modules[i].tablesList);
					}
				}
				
				// watch for file download completion
				_downloadPoller.start();
			}
			else startZip();
			
			_initialQueueLength = Downloader.queueLength;
			
			updateProgressBar();
		}
		
		protected var _initialQueueLength:int;
				
		protected function getThumbs(list:Array):void {
			var i:int;
			for (i=0; i<list.length; i++) {
				if (list[i].thumb!=null) {
					list[i].thumb.downloadPriority = 800000;
					if (list[i].thumb.downloadState==Downloader.NOT_QUEUED) Downloader.get(list[i].thumb);
				}
			}			
		}
		
		protected function onCancel(evt:Event):void {
			if (_downloadPoller.running) _downloadPoller.stop();
			if (_zipPoller.running) _zipPoller.stop();
			dispatchEvent(new Event(ZipDownloader.DONE));
		}
		
		protected function onSave(evt:Event):void {
			// some of this should be impossible
			if (_downloadPoller.running) _downloadPoller.stop();
			if (_zipPoller.running) _zipPoller.stop();
			_fr.save(_zip.byteArray, "custom.zip");
			try {
				// analytics
				if (ExternalInterface.available && Security.sandboxType==Security.REMOTE) ExternalInterface.call("pageTracker._trackEvent", "ClassAction", "Custom Zip Download", String(_numberOfCustomModules), _numberOfCustomModuleQuestions);
			}
			catch (err:Error) {
				Logger.report("error in ZipDownloader.onSave, "+err.message);
			}
			dispatchEvent(new Event(ZipDownloader.DONE));
		}
		
		protected function checkResourceListForDoneness(list:Array):Boolean {
			var i:int;
			for (i=0; i<list.length; i++) {
				if (list[i].downloadState!=Downloader.DONE_SUCCESS) return false;
				
				// has the thumb been loaded
				// (the thumb being null means there is no thumb for the given item)
				// (not having the thumb (ie. DONE_FAILURE) is not a fatal error, so just check that the Downloader is finised) 
				if (list[i].thumb!=null && list[i].thumb.downloadState<Downloader.DONE_SUCCESS) return false;
			}
			return true;
		}
		
		protected function checkForDoneness():Boolean {
			
			// have all the custom module resources been loaded?
			var i:int, j:int;
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					if (!checkResourceListForDoneness(_modulesList.modules[i].allQuestionsList)) return false;
					if (!checkResourceListForDoneness(_modulesList.modules[i].animationsList)) return false;
					if (!checkResourceListForDoneness(_modulesList.modules[i].imagesList)) return false;
					if (!checkResourceListForDoneness(_modulesList.modules[i].outlinesList)) return false;
					if (!checkResourceListForDoneness(_modulesList.modules[i].tablesList)) return false;					
				}
			}
			
			// have the start.html and browser.html files been loaded?
			if (_startHtml.downloadState!=Downloader.DONE_SUCCESS) return false;
			if (_browserSwf.downloadState!=Downloader.DONE_SUCCESS) return false;
			
			// has swfobject.js been loaded?
			if (_swfobjectJs.downloadState!=Downloader.DONE_SUCCESS) return false;
			
			// have the html template files been loaded?
			// (load them into strings if that hasn't been done yet)
			if (_swfHtmlTemplateFile.downloadState!=Downloader.DONE_SUCCESS) return false;
			else if (_swfHtmlTemplate==null) _swfHtmlTemplate = _swfHtmlTemplateFile.byteArray.readMultiByte(_swfHtmlTemplateFile.byteArray.length, "iso-8859-1");
			if (_imageHtmlTemplateFile.downloadState!=Downloader.DONE_SUCCESS) return false;			
			else if (_imageHtmlTemplate==null) _imageHtmlTemplate = _imageHtmlTemplateFile.byteArray.readMultiByte(_imageHtmlTemplateFile.byteArray.length, "iso-8859-1");
			
			// ok, all the files for the custom modules have been loaded
			
			if (_downloadPoller.running) _downloadPoller.stop();
			
			return true;
		}
		
		protected function onDownloadPoll(evt:TimerEvent):void {
			if (checkForDoneness()) startZip();
			updateProgressBar();
		}
		
		protected var _zip:ZipOutput;
		protected var _itemsList:Array;
		protected var _currItemIndex:int;
		protected var _addedItems:Dictionary;
		
		protected function startZip():void {
			
			_zip = new ZipOutput();
			
			_itemsList = [];
			_currItemIndex = 0;
			_addedItems = new Dictionary();
			
			var i:int, j:int;
			var entry:ZipEntry;
			var ba:ByteArray = new ByteArray();
			
			var modulesXML:XML = new XML("<modules></modules>");
			var questionsXML:XML = new XML("<QuestionBank></QuestionBank>");
			var animationsXML:XML = new XML("<AnimationBank></AnimationBank>");
			var imagesXML:XML = new XML("<ImageBank></ImageBank>");
			var outlinesXML:XML = new XML("<OutlineBank></OutlineBank>");
			var tablesXML:XML = new XML("<TableBank></TableBank>");
			
			// find the modules to add to the zip
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {					
				
					// for each custom module...
					
					// add the resources (questions, animations, etc.) it depends on
					// (the actual file inclusion is done later, over many frames, due to the time it takes)
					parseResourceList(_modulesList.modules[i].allQuestionsList, questionsXML);
					parseResourceList(_modulesList.modules[i].animationsList, animationsXML);
					parseResourceList(_modulesList.modules[i].imagesList, imagesXML);
					parseResourceList(_modulesList.modules[i].outlinesList, outlinesXML);
					parseResourceList(_modulesList.modules[i].tablesList, tablesXML);
					
					// write the xml file for this custom module
					ba.length = 0;
					ba.writeMultiByte(_modulesList.modules[i].getXMLString(), "iso-8859-1");
					entry = new ZipEntry(baseURL+_modulesList.modules[i].filename);
					_zip.putNextEntry(entry);
					_zip.write(ba);
					_zip.closeEntry();
					
					// add this custom module to the modules list xml file
					modulesXML.appendChild(new XML("<module>"+_modulesList.modules[i].filename+"</module>"));
				}
			}
			
			// add the modules list and resource bank xml files
			addXMLFileToZip(modulesXML, baseURL+"moduleslist.xml");
			addXMLFileToZip(questionsXML, baseURL+"questions/questions.xml");
			addXMLFileToZip(animationsXML, baseURL+"animations/animations.xml");
			addXMLFileToZip(imagesXML, baseURL+"images/images.xml");
			addXMLFileToZip(outlinesXML, baseURL+"outlines/outlines.xml");
			addXMLFileToZip(tablesXML, baseURL+"tables/tables.xml");
						
			// add the browser.swf file
			entry = new ZipEntry(baseURL+"browser.swf");
			_zip.putNextEntry(entry);
			_zip.write(_browserSwf.byteArray);
			_zip.closeEntry();
			
			// add swfobject.js
			entry = new ZipEntry(baseURL+"swfobject.js");
			_zip.putNextEntry(entry);
			_zip.write(_swfobjectJs.byteArray);
			_zip.closeEntry();
			
			// add the start.html file
			entry = new ZipEntry(rootURL+"start.html");
			_zip.putNextEntry(entry);
			_zip.write(_startHtml.byteArray);
			_zip.closeEntry();			
			
			// start adding the resource item files
			_zipPoller.start();			
			
		}
		
		protected function parseResourceList(list:Array, bankXML:XML):void {
			// this function parses a list of resources (e.g. questions, animations, etc.),
			// checking to see if any of the items have already been added to the zip and resource bank,
			// if they have not, this function puts the item in list of items to be added to the
			// zip later (done asynchronously since it is a long process), and also adds the item's
			// xml data to the given resource bank xml			
			// (this approach is used since a resource may be used in multiple modules)
			var i:int;
			for (i=0; i<list.length; i++) {
				if (!_addedItems[list[i]]) {
					_itemsList.push(list[i]);
					bankXML.appendChild(list[i].getXML());
					_addedItems[list[i]] = true;
				}
			}
		}
		
		protected function onZipPoll(evt:TimerEvent):void {
			addItemsToZip();			
			if (_currItemIndex>=_itemsList.length) finishZip();
			updateProgressBar();
		}
		
		protected function updateProgressBar():void {			
			
			// downloading a zip has two phases: downloading the necessary files and
			// packaging them into a zip file			
			// zipFrac is the fraction of the total download progress that is assigned
			// to the packaging of the zip file (assuming there are files yet to be downloaded,
			// otherwise zipFrac is set to 100%)
			var zipFrac:Number = (_initialQueueLength==0) ? 1 : 0.66;
						
			var progress:Number = 0;
			
			if (_initialQueueLength!=0) progress += (1-zipFrac)*(1-(Downloader.queueLength/_initialQueueLength));
			
			if (_itemsList!=null) {
				if (_itemsList.length==0) progress += zipFrac;
				else progress += zipFrac*_currItemIndex/_itemsList.length;
			}
			
			if (progress>1) progress = 1; // could theoretically happen if there are unrelated items on the download queue
			
			var barWidth:Number = 300;
			var progressWidth:Number = barWidth*progress;
			var barHeight:Number = 15;
			var barBorderThickness:Number = 1;
			var barProgressColor:uint = 0xA8B5B5;
			var barBackgroundColor:uint = 0x101211;
			_progressBar.graphics.clear();
			_progressBar.graphics.lineStyle();
			_progressBar.graphics.moveTo(0, 0);
			_progressBar.graphics.beginFill(barProgressColor);
			_progressBar.graphics.drawRect(-barWidth/2, -barHeight/2, progressWidth, barHeight);
			_progressBar.graphics.endFill();			
			_progressBar.graphics.moveTo(0, 0);
			_progressBar.graphics.beginFill(barBackgroundColor);
			_progressBar.graphics.drawRect(-barWidth/2+progressWidth, -barHeight/2, (barWidth-progressWidth), barHeight);
			_progressBar.graphics.endFill();			
		}
		
		protected function addItemsToZip():void {
			// this function adds the items in the items list up until
			// the time limit is reached (this done so that the progress animation
			// can run while files are added to the zip)
			var item:ResourceItem;
			var entry:ZipEntry;
			var isSwf:Boolean;
			var pattern:RegExp;
			var htmlURL:String;
			var htmlStr:String;
			var htmlBA:ByteArray = new ByteArray();
			var filename:String;
			var timeLimit:Number = getTimer() + _zipStepTime;
			do {
				// add the item to the zip file
				item = _itemsList[_currItemIndex] as ResourceItem;
				if (item==null) {
					Logger.report("non-ResourceItem encountered in addItemsToZip");
					continue;
				}
				entry = new ZipEntry(baseURL+item.downloadURL);
				_zip.putNextEntry(entry);
				_zip.write(item.data);
				_zip.closeEntry();
				
				// add the item's thumb to the zip file
				if (item.thumb!=null) {
					if (item.thumb.downloadState==Downloader.DONE_SUCCESS){ 
						// don't need to include 'thumbs' that are identical to the resource
						// (this will throw a duplicate entry error in the ZipOutput)
						if (item.thumb.downloadURL!=item.downloadURL) {
							entry = new ZipEntry(baseURL+item.thumb.downloadURL);
							_zip.putNextEntry(entry);
							_zip.write(item.thumb.byteArray);
							_zip.closeEntry();
						}
					}
					else {
						Logger.report("could not get thumbnail for zip, url: "+item.thumb.downloadURL);
					}
				}
				
				// add an html file to the zip file
				htmlURL = baseURL + item.downloadURL;
				isSwf = htmlURL.slice(htmlURL.lastIndexOf(".")) == ".swf";
				htmlURL = htmlURL.slice(0, htmlURL.lastIndexOf(".")) + ".html";
				filename = item.downloadURL.slice(item.downloadURL.lastIndexOf("/")+1);
				htmlStr = (isSwf) ? _swfHtmlTemplate : _imageHtmlTemplate;
				htmlStr = htmlStr.replace(/\$name/g, item.name);
				htmlStr = htmlStr.replace(/\$filename/g, filename);
				htmlStr = htmlStr.replace(/\$width/g, item.width);
				htmlStr = htmlStr.replace(/\$height/g, item.height);
				htmlStr = htmlStr.replace(/\$description/g, item.description);
				htmlStr = htmlStr.replace(/\$type/g, item.type);
				htmlStr = htmlStr.replace(/\$magicNumA/g, 0.5*item.width);
				htmlStr = htmlStr.replace(/\$magicNumB/g, 0.25*item.height);
				htmlStr = htmlStr.replace(/\$magicNumC/g, 0.75*item.height + 25);
				if (item.modulesList.length>0) htmlStr = htmlStr.replace(/\$primaryModuleName/g, item.modulesList[0].name);
				else htmlStr = htmlStr.replace(/\$primaryModuleName/g, "...");
				
				htmlBA.length = 0;
				htmlBA.writeMultiByte(htmlStr, "iso-8859-1");
				
				entry = new ZipEntry(htmlURL);
				_zip.putNextEntry(entry);
				_zip.write(htmlBA);
				_zip.closeEntry();
				
				_currItemIndex++;
			} while (getTimer()<timeLimit && _currItemIndex<_itemsList.length);			
			
		}
	
		protected function addXMLFileToZip(xml:XML, filename:String):void {			
			var ba:ByteArray = new ByteArray();
			ba.writeMultiByte("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n" + (new XML(xml)).toXMLString(), "iso-8859-1");
			var entry:ZipEntry = new ZipEntry(filename);
			_zip.putNextEntry(entry);
			_zip.write(ba);
			_zip.closeEntry();			
		}
		
		protected function finishZip():void {
			_zip.finish();
			_zipPoller.stop();
			_saveButton.setText(_zipReadyMessage);
			_saveButton.x = -_saveButton.width/2;
			_saveButton.y = _saveButtonReadyY;
			_saveButton.setClickable(true);
			
			_progressBar.visible = false;
			
		}
				
	}
}

