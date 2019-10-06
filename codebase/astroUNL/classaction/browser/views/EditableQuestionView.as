
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Question;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	
	public class EditableQuestionView extends Sprite {

		protected var _question:Question;
		protected var _editorPanel:QuestionEditor;
		protected var _content:Sprite;
		
		protected var _width:Number;
		protected var _height:Number;
		
		public function EditableQuestionView() {
			
			_content = new Sprite();
			addChild(_content);
			
			_editorPanel = new QuestionEditor();
			addChild(_editorPanel);
		}
		
		public function setDimensions(width:Number, height:Number, scale:Number):void {
			trace("set dimensions: "+width+", "+height+", "+scale);
			
			_width = width;
			_height = height;
			
			_content.graphics.clear();
			_content.graphics.lineStyle(1, 0x0000a0);
			_content.graphics.drawRect(0, 0, width, height);
			refresh();
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function set question(q:Question):void {
			trace("set question: "+q.name);
			_question = q;			
			refresh();
		}
		
		protected function refresh():void {
			
			
			
		}
		
	}
}

