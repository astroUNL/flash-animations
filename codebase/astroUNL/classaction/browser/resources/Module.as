
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.IDownloadable;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.utils.logger.Logger;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	
	import flash.utils.getTimer;
	import flash.utils.ByteArray;
	
	
	public class Module extends EventDispatcher implements IDownloadable {
		
		// loadFinished dispatched when the module has finished loading (not necessarily successfully, check the loaded property)
		public static const LOAD_FINISHED:String = "loadFinished";
		
		// update is dispatched when some change has occured to the module after the load has finished (e.g. question removed)
		public static const UPDATE:String = "update";
		
		
		protected var _readOnly:Boolean = false;
		
		protected var _name:String = "";
		protected var _filename:String = "";
		
		protected var _fractionLoaded:Number = 0;
		protected var _downloadState:int = Downloader.NOT_QUEUED;		
		protected var _loaded:Boolean = false;
		protected var _loadFinished:Boolean = false;
		
		public var allQuestionsList:Array = [];
		public var warmupQuestionsList:Array = [];
		public var generalQuestionsList:Array = [];
		public var challengeQuestionsList:Array = [];
		public var discussionQuestionsList:Array = [];		
		
		public var animationsList:Array = [];
		public var imagesList:Array = [];
		public var outlinesList:Array = [];
		public var tablesList:Array = [];
		
		
		protected static var _nextID:int = 0;
		public static function obtainID():int {
			return _nextID++;
		}
		
		protected var _id:int;
		
		public function getCopy():Module {
			var newModule:Module = new Module(null, false);
			newModule.parseData(getXMLString());
			newModule.name = "Copy of " + _name;
			return newModule;
		}
		
		public function Module(filename:String, readOnly:Boolean=true, serialization:ByteArray=null) {
			_readOnly = readOnly;
			_serialization = new ByteArray();
			_serializationValid = false;
			_id = Module.obtainID();
			if (filename==null || filename=="") _filename = Module.getUniqueFilename();
			else _filename = filename;
			_name = "A Module";
			if (_readOnly) {
				Downloader.get(this);
			}
			else {
				_loaded = true;
				_loadFinished = true;				
				if (serialization!=null) setSerialization(serialization);
			}
		}
		
		public function hasQuestion(question:Question):Boolean {
			for each (var q:Question in allQuestionsList) if (q==question) return true;
			return false;
		}		
		
		protected var _serializationSuccess:Boolean = false;
		
		public function get serializationSuccess():Boolean {
			return _serializationSuccess;
		}
		
		protected static var _filenameCharacters:Vector.<String>;
		
		protected static function getUniqueFilename():String {
			var i:int;
			if (_filenameCharacters==null) {
				_filenameCharacters = new Vector.<String>();
				for (i=48; i<=57; i++) _filenameCharacters.push(String.fromCharCode(i)); // 0-9
				for (i=65; i<=90; i++) _filenameCharacters.push(String.fromCharCode(i)); // A-Z
				for (i=97; i<=122; i++) _filenameCharacters.push(String.fromCharCode(i)); // a-z
			}
			var filename:String = "module_";
			for (i=0; i<35; i++) filename += _filenameCharacters[int(_filenameCharacters.length*Math.random())];
			filename += ".xml";
			return filename;
		}
		
		protected function setSerialization(ser:ByteArray):void {
			// this function can be called only from the constructor since it expects the module to be empty when called
			// may want to somehow combine this with parseData since there's redundancy
			
			try {
				ser.inflate();
			}
			catch (err:Error) {
				Logger.report("could not inflate module serialization");
				_serializationSuccess = false;
				return;				
			}
			
			ser.position = 0;
			
			var obj:Object;
			try {
				obj = ser.readObject();
			}
			catch (err:Error) {
				Logger.report("could not read module serialization object");
				_serializationSuccess = false;
				return;
			}
			
			// success simply means that all the expected properties were there and in the correct format
			var success:Boolean = true;
			
			// set the name
			if (obj.name is String) _name = obj.name;
			else success = false;
			
			// set the filename
			if (obj.filename is String) _filename = obj.filename;
			else success = false;
			
			// set the questions list
			var i:int;
			var question:Question;
			if (obj.questions is Array) {
				for (i=0; i<obj.questions.length; i++) {
					if (obj.questions[i] is String) {
						question = QuestionsBank.lookup[obj.questions[i]];
						if (question==null) Logger.report("question " + obj.questions[i] + " not found in setSerialization (module: " + _name + ")");
						else {
							if (question.questionType==Question.WARM_UP) warmupQuestionsList.push(question);
							else if (question.questionType==Question.GENERAL) generalQuestionsList.push(question);
							else if (question.questionType==Question.CHALLENGE) challengeQuestionsList.push(question);
							else if (question.questionType==Question.DISCUSSION) discussionQuestionsList.push(question);
							else continue;
							allQuestionsList.push(question);
							question.modulesList.push(this);
							question.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
						}
					}
					else {
						success = false;
						break;
					}
				}				
			}
			else success = false;
			
			// set the resources
			if (obj.animations is Array) if (!addResourcesFromIdsList(obj.animations, animationsList, AnimationsBank)) success = false;
			if (obj.images is Array) if (!addResourcesFromIdsList(obj.images, imagesList, ImagesBank)) success = false;
			if (obj.outlines is Array) if (!addResourcesFromIdsList(obj.outlines, outlinesList, OutlinesBank)) success = false;
			if (obj.tables is Array) if (!addResourcesFromIdsList(obj.tables, tablesList, TablesBank)) success = false;

			_serializationSuccess = success;
		}
		
		protected function addResourcesFromIdsList(idsList:Array, objList:Array, bank:Object):Boolean {
			var i:int;
			var item:ResourceItem;
			var success:Boolean = true;
			for (i=0; i<idsList.length; i++) {
				if (idsList[i] is String) {
					item = bank.lookup[idsList[i]];
					if (item==null) Logger.report("resource " + idsList[i] + " not found in addResourcesFromIdsList (module: " + _name + ")");
					else {
						objList.push(item);
						item.modulesList.push(this);
						item.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
					}
				}
				else {
					success = false;
					break;
				}
			}
			return success;
		}		
		
		protected var _serializationValid:Boolean = false;
		protected var _serialization:ByteArray;
		
		public function getSerialization():ByteArray {
			
			if (_serializationValid) {
				_serialization.position = 0;
				return _serialization;
			}
			
			var obj:Object = {};
			obj.name = _name;
			obj.filename = _filename;
			obj.questions = getIdsList(allQuestionsList);
			obj.animations = getIdsList(animationsList);
			obj.images = getIdsList(imagesList);
			obj.outlines = getIdsList(outlinesList);
			obj.tables = getIdsList(tablesList);
			
			_serialization.length = 0;
			_serialization.writeObject(obj);			
			_serialization.deflate();
			
			_serializationValid = true;
			
			_serialization.position = 0;
			return _serialization;
		}
		
		protected function getIdsList(objList:Array):Array {
			var idsList:Array = [];
			for (var i:int = 0; i<objList.length; i++) idsList[i] = objList[i].id;
			return idsList;			
		}
		
		public function getXMLString():String {
			
			var i:int;
			
			var questions:XML = new XML("<Questions></Questions>");
			var animations:XML = new XML("<Animations></Animations>");
			var images:XML = new XML("<Images></Images>");
			var outlines:XML = new XML("<Outlines></Outlines>");
			var tables:XML = new XML("<Tables></Tables>");
			
			for (i=0; i<allQuestionsList.length; i++) questions.appendChild(new XML("<Question>"+allQuestionsList[i].id+"</Question>"));				
			for (i=0; i<animationsList.length; i++) animations.appendChild(new XML("<Animation>"+animationsList[i].id+"</Animation>"));
			for (i=0; i<imagesList.length; i++) images.appendChild(new XML("<Image>"+imagesList[i].id+"</Image>"));				
			for (i=0; i<outlinesList.length; i++) outlines.appendChild(new XML("<Outline>"+outlinesList[i].id+"</Outline>"));				
			for (i=0; i<tablesList.length; i++) tables.appendChild(new XML("<Table>"+tablesList[i].id+"</Table>"));				
			
			var moduleSpec:XML = new XML("<ModuleSpecification></ModuleSpecification>");
			moduleSpec.@id = _name;
			moduleSpec.appendChild(questions);
			moduleSpec.appendChild(animations);
			moduleSpec.appendChild(images);
			moduleSpec.appendChild(outlines);
			moduleSpec.appendChild(tables);
			
			return "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n" + moduleSpec.toXMLString();
		}
		
		public function get id():int {
			return _id;
		}
		
		protected function dispatchUpdate():void {
			_serializationValid = false;
			dispatchEvent(new Event(Module.UPDATE));
		}
		
		protected function onResourceUpdate(evt:Event):void {
			dispatchEvent(new Event(Module.UPDATE));
		}
		
		public function addResource(item:ResourceItem):void {
			if (_readOnly) {
				Logger.report("attempt to add a resource to a read-only module, module: "+_name);
				return;				
			}			
			
			// note that we're doing no checking to see that the item is not
			// already associated with this module
			
			if (item.type==ResourceItem.ANIMATION) {
				animationsList.push(item);
				item.modulesList.push(this);
			}
			else if (item.type==ResourceItem.IMAGE) {
				imagesList.push(item);
				item.modulesList.push(this);
			}
			else if (item.type==ResourceItem.OUTLINE) {
				outlinesList.push(item);
				item.modulesList.push(this);
			}
			else if (item.type==ResourceItem.TABLE) {
				tablesList.push(item);
				item.modulesList.push(this);
			}
			
			item.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
			
			dispatchUpdate();
		}
		
		public function removeResource(item:ResourceItem):void {
			if (_readOnly) {
				Logger.report("attempt to remove a resource from a read-only module, module: "+_name);
				return;				
			}
			
			var list:Array;
			if (item.type==ResourceItem.ANIMATION) list = animationsList;				
			else if (item.type==ResourceItem.IMAGE) list = imagesList;	
			else if (item.type==ResourceItem.OUTLINE) list = outlinesList;	
			else if (item.type==ResourceItem.TABLE) list = tablesList;	
			
			var success:Boolean = false;
			
			var i:int;
			for (i=0; i<list.length; i++) {
				if (list[i]==item) {					
					list.splice(i, 1);
					for (i=0; i<item.modulesList.length; i++) {
						if (item.modulesList[i]==this) {
							item.modulesList.splice(i, 1);
							break;
						}
					}					
					item.removeEventListener(ResourceItem.UPDATE, onResourceUpdate, false);
					success = true;
					break;
				}
			}
			
			if (success) dispatchUpdate();
		}
		
		public function release():void {
			// this function will remove the reference to this module from each resource and
			// will unsubscribe from its events; it will also zero out the resource lists
			// (called by the modules list when removing modules)
			// this function does not prune the resource banks
			
			var i:int;
			var list:Array;
			var item:ResourceItem;
			
			for each (list in [allQuestionsList, animationsList, imagesList, outlinesList, tablesList]) {
				for each (item in list) {
					for (i=0; i<item.modulesList.length; i++) {
						if (item.modulesList[i]==this) {
							item.modulesList.splice(i, 1);
							break;
						}
					}
					item.removeEventListener(ResourceItem.UPDATE, onResourceUpdate, false);
				}
			}
			
			// empty the resources lists
			warmupQuestionsList = [];
			generalQuestionsList = [];
			challengeQuestionsList = [];
			discussionQuestionsList = [];		
			allQuestionsList = [];
			animationsList = [];
			imagesList = [];
			outlinesList = [];
			tablesList = [];
		}
		
		public function addQuestion(question:Question):void {
			if (_readOnly) {
				Logger.report("attempt to add a question to a read-only module, module: "+_name);
				return;				
			}
			for (var i:int = 0; i<allQuestionsList.length; i++) {
				if (allQuestionsList[i]==question) {
					Logger.report("attempt to add a question to a module it already belongs to, module: "+_name);
					return;
				}
			}
			if (question.questionType==Question.WARM_UP) warmupQuestionsList.push(question);
			else if (question.questionType==Question.GENERAL) generalQuestionsList.push(question);
			else if (question.questionType==Question.CHALLENGE) challengeQuestionsList.push(question);
			else if (question.questionType==Question.DISCUSSION) discussionQuestionsList.push(question);
			else {
				Logger.report("question has invalid type in Module.addQuestion, question id: "+question.id);
				return;				
			}
			allQuestionsList.push(question);
			question.modulesList.push(this);
			
			question.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
			
			dispatchUpdate();
		}
		
		public function removeQuestion(question:Question):void {
			if (_readOnly) {
				Logger.report("attempt to remove a question from a read-only module, module: "+_name);
				return;				
			}
			for (var i:int = 0; i<allQuestionsList.length; i++) {
				if (allQuestionsList[i]==question) {
					allQuestionsList.splice(i, 1);
							
					var subList:Array;
					if (question.questionType==Question.WARM_UP) subList = warmupQuestionsList;
					else if (question.questionType==Question.GENERAL) subList = generalQuestionsList;
					else if (question.questionType==Question.CHALLENGE) subList = challengeQuestionsList;
					else if (question.questionType==Question.DISCUSSION) subList = discussionQuestionsList;
					else return;
					
					for (i=0; i<subList.length; i++) {
						if (subList[i]==question) {
							subList.splice(i, 1);
							break;
						}						
					}
					
					// remove the module from the question's modulesList
					for (i=0; i<question.modulesList.length; i++) {
						if (question.modulesList[i]==this) {
							question.modulesList.splice(i, 1);
							break;							
						}
					}
					question.removeEventListener(ResourceItem.UPDATE, onResourceUpdate, false);
						
					if (!question.readOnly && question.modulesList.length==0) QuestionsBank.remove(question);					
					
					dispatchUpdate();
					
					return;
				}
			}
					
			Logger.report("could not find question to remove, question: "+question.name+", module: "+_name);
		}
		
		public function get readOnly():Boolean {
			return _readOnly;
		}
		
		public function set name(arg:String):void {
			if (_readOnly) {
				Logger.report("attempt to change the name of a read-only module, module: "+_name);
				return;
			}
			_name = arg;			
			dispatchUpdate();
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get filename():String {
			return _filename;			
		}
		
		public function get downloadURL():String {
			return _filename;
		}
		
		public function get downloadFormat():String {
			return URLLoaderDataFormat.TEXT;
		}
		
		public function get downloadPriority():int {
			return 2000000;
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
				dispatchEvent(new Event(Module.LOAD_FINISHED));
			}
		}

		public function parseData(data:String):void {
			if (warmupQuestionsList.length>0 || generalQuestionsList.length>0 || challengeQuestionsList.length>0
				|| discussionQuestionsList.length>0 || animationsList.length>0 || imagesList.length>0
				|| outlinesList.length>0 || tablesList.length>0 || allQuestionsList.length>0) {
				Logger.report("parseData should only be called with an empty module");
				return;
			}
			
			try {
				var startTimer:Number = getTimer();
				
				var moduleXML:XML = new XML(data);
				var resource:XML;
				
				
				_name = moduleXML.attribute("id").toString();
				
				var question:Question;
				
				for each (resource in moduleXML["Questions"].elements()) {
					question = QuestionsBank.lookup[resource.toString()];
					if (question==null) Logger.report("question " + resource.toString() + " not found (module: " + _name + ")");
					else {
						if (question.questionType==Question.WARM_UP) warmupQuestionsList.push(question);
						else if (question.questionType==Question.GENERAL) generalQuestionsList.push(question);
						else if (question.questionType==Question.CHALLENGE) challengeQuestionsList.push(question);
						else if (question.questionType==Question.DISCUSSION) discussionQuestionsList.push(question);
						else continue;
						allQuestionsList.push(question);
						question.modulesList.push(this);
						question.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
					}
				}
				
				var item:ResourceItem;
				
				for each (resource in moduleXML["Animations"].elements()) {
					item = AnimationsBank.lookup[resource.toString()];
					if (item==null) Logger.report("animation " + resource.toString() + " not found (module: " + _name + ")");
					else {
						animationsList.push(item);
						item.modulesList.push(this);
						item.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
					}
				}
				for each (resource in moduleXML["Images"].elements()) {
					item = ImagesBank.lookup[resource.toString()];
					if (item==null) Logger.report("image " + resource.toString() + " not found (module: " + _name + ")");
					else {
						imagesList.push(item);
						item.modulesList.push(this);
						item.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
					}
				}
				for each (resource in moduleXML["Tables"].elements()) {
					item = TablesBank.lookup[resource.toString()];
					if (item==null) Logger.report("table " + resource.toString() + " not found (module: " + _name + ")");
					else {
						tablesList.push(item);
						item.modulesList.push(this);
						item.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
					}
				}
				for each (resource in moduleXML["Outlines"].elements()) {
					item = OutlinesBank.lookup[resource.toString()];
					if (item==null) Logger.report("outline " + resource.toString() + " not found (module: " + _name + ")");
					else {
						outlinesList.push(item);
						item.modulesList.push(this);
						item.addEventListener(ResourceItem.UPDATE, onResourceUpdate, false, 0, true);
					}
				}
				
				_loaded = true;
			}
			catch (err:Error) {
				//
			}
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
		
		override public function toString():String {
			return _name + " (Module)";
		}
	}
}

