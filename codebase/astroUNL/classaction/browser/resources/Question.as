
package astroUNL.classaction.browser.resources {
	
	import astroUNL.utils.logger.Logger;
	
	import flash.events.Event;
	
	public class Question extends ResourceItem {
		
		public static const WARM_UP:int = 0;
		public static const GENERAL:int = 1;
		public static const CHALLENGE:int = 2;
		public static const DISCUSSION:int = 3;
				
		public var questionType:int = Question.GENERAL;
		public var relevantAnimationIDsList:Array = [];
		public var relevantImageIDsList:Array = [];
		public var relevantOutlineIDsList:Array = [];
		public var relevantTableIDsList:Array = [];
		
		public function Question(initObj:*=null) {
			super(ResourceItem.QUESTION, initObj);
		}
		
		public function addRelevantResource(item:ResourceItem):void {
			
			var list:Array;
			if (item.type==ResourceItem.ANIMATION) list = relevantAnimationIDsList;
			else if (item.type==ResourceItem.IMAGE) list = relevantImageIDsList;
			else if (item.type==ResourceItem.OUTLINE) list = relevantOutlineIDsList;
			else if (item.type==ResourceItem.TABLE) list = relevantTableIDsList;
			else return;

			// check that the item is not already marked as relevant
			var i:int;
			for (i=0; i<list.length; i++) if (list[i]==item.id) return;
			
			list.push(item.id);
			dispatchEvent(new Event(ResourceItem.UPDATE));
		}
		
		public function removeRelevantResource(item:ResourceItem):void {
			var list:Array;
			if (item.type==ResourceItem.ANIMATION) list = relevantAnimationIDsList;
			else if (item.type==ResourceItem.IMAGE) list = relevantImageIDsList;
			else if (item.type==ResourceItem.OUTLINE) list = relevantOutlineIDsList;
			else if (item.type==ResourceItem.TABLE) list = relevantTableIDsList;
			else return;
			
			var i:int;
			for (i=0; i<list.length; i++) {
				if (list[i]==item.id) {
					list.splice(i, 1);
					dispatchEvent(new Event(ResourceItem.UPDATE));
					return;
				}
			}			
		}
		
		override public function getXML():XML {
			var xml:XML = super.getXML();
			xml.appendChild(new XML("<Type>"+questionType+"</Type>"));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.ANIMATION));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.IMAGE));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.OUTLINE));
			xml.appendChild(getRelevantResourcesXML(ResourceItem.TABLE));
			return xml;
		}
		
		protected function getRelevantResourcesXML(type:String):XML {
			
			var xml:XML;
			var list:Array;
			var opening:String, closing:String;
			if (type==ResourceItem.ANIMATION) {
				xml = new XML("<RelevantAnimations></RelevantAnimations>");
				opening = "<RelevantAnimation>";
				closing = "</RelevantAnimation>";
				list = relevantAnimationIDsList;
			}
			else if (type==ResourceItem.IMAGE) {
				xml = new XML("<RelevantImages></RelevantImages>");
				opening = "<RelevantImage>";
				closing = "</RelevantImage>";
				list = relevantImageIDsList;
			}
			else if (type==ResourceItem.OUTLINE) {
				xml = new XML("<RelevantOutlines></RelevantOutlines>");
				opening = "<RelevantOutline>";
				closing = "</RelevantOutline>";
				list = relevantOutlineIDsList;
			}
			else if (type==ResourceItem.TABLE) {
				xml = new XML("<RelevantTables></RelevantTables>");
				opening = "<RelevantTable>";
				closing = "</RelevantTable>";
				list = relevantTableIDsList;
			}
			else return new XML();
			
			var i:int;
			for (i=0; i<list.length; i++) xml.appendChild(new XML(opening+list[i]+closing));
			
			return xml;
		}
		
		override protected function initCustom():void {
			super.initCustom();
			questionType = Question.GENERAL;
			width = 780;
			height = 515;
			dispatchEvent(new Event(ResourceItem.UPDATE));
		}
		
		override public function setXML(itemXML:XML):void {
			if (itemXML!=null) {
				super.setXML(itemXML);
				
				questionType = itemXML.Type;
				
				if (questionType!=Question.WARM_UP && questionType!=Question.GENERAL && questionType!=Question.CHALLENGE && questionType!=Question.DISCUSSION) {
					Logger.report("question " + id + " does not have a valid type");
				}
				
				var relevant:XML;
				
				for each (relevant in itemXML.RelevantAnimations.elements()) {
					relevantAnimationIDsList.push(relevant.toString());
				}
				for each (relevant in itemXML.RelevantImages.elements()) {
					relevantImageIDsList.push(relevant.toString());
				}
				for each (relevant in itemXML.RelevantTables.elements()) {
					relevantTableIDsList.push(relevant.toString());
				}
				for each (relevant in itemXML.RelevantOutlines.elements()) {
					relevantOutlineIDsList.push(relevant.toString());
				}				
				
			}
		}		
		
		override protected function readSerializationObject(obj:Object):void {
			super.readSerializationObject(obj);
			
			if (obj.questionType is int) questionType = obj.questionType;
			else {
				Logger.report("bad question type found, using general");
				questionType = Question.GENERAL;
				_serializationSuccess = true;//false;
			}
			
			if (_serializationSuccess) trace("successfully loaded question, "+_name+", "+obj.id);
			else trace("failed to load question, "+obj.id);
			
		}
		
		override protected function composeSerializationObject():Object {
			var obj:Object = super.composeSerializationObject();
			obj.questionType = questionType;
			return obj;
		}
		
	}	
}

