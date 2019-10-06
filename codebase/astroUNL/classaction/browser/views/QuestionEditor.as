
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Question;
//	import astroUNL.classaction.browser.views.elements.MessageBubble;
//	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.display.Sprite;
//	import flash.display.Shape;
//	import flash.display.Loader;
//	import flash.utils.Timer;
//	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class QuestionEditor extends Sprite {
		
		public function QuestionEditor() {
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		protected function onAddedToStage(evt:Event):void {
			imageButton.addEventListener(MouseEvent.CLICK, onBeginAddImage);			
		}
		
		protected function onBeginAddImage(evt:MouseEvent):void {
			trace("begin the process of adding an image");			
		}
		
	}
	
}
