package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;	
	import astroUNL.classaction.browser.resources.QuestionsBank;
	import astroUNL.classaction.browser.resources.AnimationsBank;
	import astroUNL.classaction.browser.resources.ImagesBank;
	import astroUNL.classaction.browser.resources.OutlinesBank;
	import astroUNL.classaction.browser.resources.TablesBank;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;
		
	
	public class ResourceItem extends EventDispatcher implements IDownloadable {
				
		public static const UPDATE:String = "update";
		
		public static const QUESTION:String = "question";
		public static const ANIMATION:String = "animation";
		public static const IMAGE:String = "image";
		public static const TABLE:String = "table";
		public static const OUTLINE:String = "outline";
		
		public var thumb:BinaryFile;
		
		protected var _readOnly:Boolean = true;
		
		public var id:String;
		protected var _name:String;
		public var description:String = "";
		public var keywords:Array = [];
		public var filename:String;
		public var width:Number;
		public var height:Number;
		public var modulesList:Array = []; // the list of modules this resource is associated with
		public var type:String;
		public var data:ByteArray;
		
		public var typeCapped:String;
		
		public function ResourceItem(type:String, initObj:*=null) {
			// how the resource initializes depends on the value of initObj; initObj can be...
			//  XML - used by the read only resources
			//  ByteArray - serialization used by custom resources loaded from the shared object
			//  null - used when creating new custom resources
						
			setType(type);
			
			_serialization = new ByteArray();
			
			if (initObj==null) initCustom();
			else if (initObj is XML) setXML(initObj);
			else if (initObj is ByteArray) setSerialization(initObj);
			else Logger.report("error in ResourceItem()");
		}
		
		protected function setType(t:String):void {
			type = t;
			typeCapped = t.charAt(0).toUpperCase() + t.slice(1);
		}
		
		protected function initCustom():void {
			
			_readOnly = false;
			
			onDownloadStateChanged(Downloader.DONE_SUCCESS, new ByteArray());
			id = getUniqueID();
			_name = "New " + typeCapped;
			filename = type + "_" + id + ".data";
			width = 100;
			height = 100;			
		}
		
		/*
		protected function addToBank():void {
			var bank:Object;
			if (type==ResourceItem.QUESTION) bank = QuestionsBank;
			else if (type==ResourceItem.ANIMATION) bank = AnimationsBank;
			else if (type==ResourceItem.IMAGE) bank = ImagesBank;
			else if (type==ResourceItem.OUTLINE) bank = OutlinesBank;
			else if (type==ResourceItem.TABLE) bank = TablesBank;
			bank.add(this);
		}
		*/
		
		public function setXML(itemXML:XML):void {
			if (itemXML!=null) {
				id = itemXML.attribute("id").toString();
				_name = itemXML.Name;
				description = itemXML.Description;
				filename = itemXML.File;
				width = itemXML.Width;
				height = itemXML.Height;
				
				var keywordXML:XML;
				for each (keywordXML in itemXML.Keywords.elements()) keywords.push(keywordXML.toString());
				
				var thumbFilename:String = "";
				if (type==ResourceItem.ANIMATION) thumbFilename = filename.slice(0, filename.lastIndexOf(".")) + ".jpg";
				else if (type==ResourceItem.IMAGE) thumbFilename = filename.slice(0, filename.lastIndexOf(".")) + "_thumb" + filename.slice(filename.lastIndexOf("."));
				else if (type==ResourceItem.OUTLINE) thumbFilename = filename;
				else if (type==ResourceItem.TABLE) thumbFilename = filename;
				if (thumbFilename!="") thumb = new BinaryFile(thumbFilename, false);
			}			
		}
		
		public function getXML():XML {
			
			var xml:XML = new XML("<"+typeCapped+"></"+typeCapped+">");
			xml.@id = id;
			xml.appendChild(new XML("<Name>"+_name+"</Name>"));
			xml.appendChild(new XML("<Description>"+description+"</Description>"));
			
			var keywordsXML:XML = new XML("<Keywords></Keywords>");
			for each (var keyword:String in keywords) keywordsXML.appendChild(new XML("<Keyword>"+keyword+"</Keyword>"));
			xml.appendChild(keywordsXML);
			
			xml.appendChild(new XML("<File>"+filename+"</File>"));
			xml.appendChild(new XML("<Width>"+width+"</Width>"));
			xml.appendChild(new XML("<Height>"+height+"</Height>"));
			return xml;
		}
				
		// the stuff below takes care the IDownloadable requirements
		
		protected var _downloadState:int = Downloader.NOT_QUEUED;
		protected var _downloadPriority:int = 0;
		protected var _fractionLoaded:Number = 0;
		
		public function get downloadURL():String {
			return filename;			
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
				this.data = data;
			}
		}				
		
		override public function toString():String {
			if (_name==null) return "unnamed (ResourceItem)";
			else return _name + " (ResourceItem)";
		}		
		
		protected var _filenameCharacters:Vector.<String>;		
		protected function getUniqueID():String {
			// this function adapted from from Module.as
			var i:int;
			if (_filenameCharacters==null) {
				_filenameCharacters = new Vector.<String>();
				for (i=48; i<=57; i++) _filenameCharacters.push(String.fromCharCode(i)); // 0-9
				for (i=65; i<=90; i++) _filenameCharacters.push(String.fromCharCode(i)); // A-Z
				for (i=97; i<=122; i++) _filenameCharacters.push(String.fromCharCode(i)); // a-z
			}
			var id:String = "";
			for (i=0; i<35; i++) id += _filenameCharacters[int(_filenameCharacters.length*Math.random())];
			return id;
		}		
		
		protected var _serializationValid:Boolean = false;
		protected var _serializationSuccess:Boolean = false;
		protected var _serialization:ByteArray;
		
		protected function dispatchUpdate():void {
			_serializationValid = false;
			dispatchEvent(new Event(ResourceItem.UPDATE));
		}		
		
		public function get name():String {
			return _name;
		}
		
		public function set name(arg:String):void {
			if (_readOnly) {
				Logger.report("attempt to change the name of a read-only resource, resource: "+this);
				return;
			}
			_name = arg;
			dispatchUpdate();
		}		
		
		public function get readOnly():Boolean {
			return _readOnly;
		}
		
		public function getSerialization():ByteArray {
			
			if (_serializationValid) {
				_serialization.position = 0;
				return _serialization;
			}
			
			_serialization.length = 0;
			_serialization.writeObject(composeSerializationObject());			
			_serialization.deflate();
			
			_serializationValid = true;
			
			_serialization.position = 0;
			return _serialization;
		}
		
		protected function composeSerializationObject():Object {
			var obj:Object = {};
			obj.id = id;
			obj.name = _name;
			obj.description = description;
			obj.keywords = keywords;
			obj.filename = filename;
			obj.width = width;
			obj.height = height;
			obj.type = type;		
			return obj;
		}
		
		protected function setSerialization(s:ByteArray):void {
			
			// success simply means that all the expected properties were there and in the correct format
			_serializationSuccess = true;
			
			try {
				s.inflate();
			}
			catch (err:Error) {
				Logger.report("could not inflate resource serialization");
				// continue on, maybe it's already inflated (can happen in certain circumstances)
			}
			
			s.position = 0;
			
			var obj:Object;
			try {
				obj = s.readObject();
			}
			catch (err:Error) {
				Logger.report("could not read resource serialization object");
				_serializationSuccess = false;
				return;
			}
			
			readSerializationObject(obj);
			
			_readOnly = false;
			onDownloadStateChanged(Downloader.DONE_SUCCESS, new ByteArray());
		}
		
		protected function readSerializationObject(obj:Object):void {
			
			if (obj.id is String) id = obj.id;
			else _serializationSuccess = false;
			
			if (obj.name is String) _name = obj.name;
			else _serializationSuccess = false;
			
			if (obj.description==null || obj.description is String) description = obj.description;
			else _serializationSuccess = false;
			
			if (obj.keywords is Array) keywords = obj.keywords;
			else _serializationSuccess = false;
			
			if (obj.filename is String) filename = obj.filename;
			else _serializationSuccess = false;
			
			if (obj.width is Number) width = obj.width;
			else _serializationSuccess = false;
			
			if (obj.height is Number) height = obj.height;
			else _serializationSuccess = false;
			
			if (obj.type is String) setType(obj.type);
			else _serializationSuccess = false;			
		}
		
		public function get serializationSuccess():Boolean {
			return _serializationSuccess;
		}
				
	}
}
