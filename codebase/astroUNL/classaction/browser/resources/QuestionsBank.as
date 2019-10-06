
package astroUNL.classaction.browser.resources {
	
	import astroUNL.classaction.browser.download.Downloader;
	
	import astroUNL.utils.logger.Logger;
		
	public class QuestionsBank {
		
		public static var lookup:Object = {};
		public static var downloadState:int = Downloader.NOT_QUEUED;
		public static var total:uint = 0;
		public static var loaded:Boolean = false;
		
		public static function add(question:Question):void {
			if (lookup[question.id]!=undefined) Logger.report("duplicate id in QuestionsBank.add, id: "+question.id);
			else total++;
			lookup[question.id] = question;
		}		
		
		public static function remove(question:Question):void {
			if (question.modulesList.length>0) {
				Logger.report("can't remove question that's being used by a module");
				return;
			}
			delete lookup[question.id];
			total--;			
		}
		
	import flash.utils.getTimer;
	
		public static function prune():void {
			// removes all custom questions with no owning modules
			
			// don't know how removing items from an object while iterating over those items works,
			// so using an intermediate array to be safe
			var toBeRemoved:Array = [];
			
			var question:Question;
			var startTimer:Number = getTimer();
			for each (question in lookup) if (!question.readOnly && question.modulesList.length==0) toBeRemoved.push(question);
			for each (question in toBeRemoved) QuestionsBank.remove(question);
			
			trace("QuestionsBank.prune, n: "+toBeRemoved.length+", time: "+(getTimer()-startTimer));
		}
		
	}	
}
