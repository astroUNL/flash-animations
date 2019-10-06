
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.views.elements.MessageBubble;
	import astroUNL.classaction.browser.download.Downloader;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	
	
	public class QuestionView extends Sprite {
		
		protected var _errorMsg:MessageBubble;
		protected var _preloader:Preloader;
		protected var _timer:Timer;
		protected var _mask:Shape;
		protected var _loader:Loader;
		protected var _question:Question;
		protected var _maxWidth:Number = 780;
		protected var _maxHeight:Number = 515;
		
		
		public function QuestionView() {
			
			_mask = new Shape();
			addChild(_mask);
			
			_errorMsg = new MessageBubble();
			_errorMsg.visible = false;
			addChild(_errorMsg);
			
			_preloader = new Preloader();
			_preloader.x = 300;
			_preloader.y = 300;
			_preloader.visible = false;
			addChild(_preloader);
			
			_loader = new Loader();
			_loader.visible = false;
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderDone);
			_loader.mask = _mask;
			addChild(_loader);
			
			_timer = new Timer(20);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function get question():Question {
			return _question;
		}
		
		public function set question(q:Question):void {
			_question = q;
			refresh();
		}
		
		public function setMaxDimensions(w:Number, h:Number):void {
			_maxWidth = w;
			_maxHeight = h;
			
			refreshPositioning();
		}
		
		protected function onTimer(evt:TimerEvent):void {
			refresh();
			evt.updateAfterEvent();
		}
		
		protected function onLoaderDone(evt:Event):void {
			_loader.visible = true;
			refreshPositioning();
		}
		
		protected function refresh():void {
			if (_question==null) {
				_loader.unloadAndStop(true);
				_errorMsg.visible = false;
				_preloader.visible = false;
				_loader.visible = false;
				if (_timer.running) _timer.stop();
				return;
			}
			
			if (_question.downloadState==Downloader.DONE_SUCCESS) {
				if (_question.data.length>0) {
					_loader.loadBytes(_question.data);
					_errorMsg.visible = false;
					_preloader.visible = false;
					_loader.visible = false;
					if (_timer.running) _timer.stop();
				}
			}
			else if (_question.downloadState==Downloader.DONE_FAILURE) {
				_errorMsg.setMessage("the question file failed to load");
				_errorMsg.visible = true;
				_preloader.visible = false;
				_loader.visible = false;
				if (_timer.running) _timer.stop();
			}
			else {
				_errorMsg.visible = false;
				_preloader.visible = true;
				_loader.visible = false;
				if (!_timer.running) _timer.start();				
			}
			
			refreshPositioning();
		}
		
		protected function refreshPositioning():void {
			
			var midX:Number = _maxWidth/2;
			var midY:Number = _maxHeight/2;
			
			_errorMsg.x = midX - _errorMsg.width/2;
			_errorMsg.y = midY - _errorMsg.height/2;
			
			_preloader.x = midX - _preloader.width/2;
			_preloader.y = midY - _preloader.height/2;
			
			if (_loader.visible) {
				
				var maxAspect:Number = _maxWidth/_maxHeight;
				var qAspect:Number = _question.width/_question.height;
				
				var qScale:Number, qWidth:Number, qHeight:Number;
				
				if (qAspect>maxAspect) {
					qScale = _maxWidth/_question.width;
					qWidth = qScale*_question.width;
					qHeight = qScale*_question.height;
					_loader.scaleX = _loader.scaleY = qScale;
					_loader.x = 0;
					_loader.y = (_maxHeight - qHeight)/2;
				}
				else {
					qScale = _maxHeight/_question.height;
					qWidth = qScale*_question.width;
					qHeight = qScale*_question.height;
					_loader.scaleX = _loader.scaleY = qScale;
					_loader.x = (_maxWidth - qWidth)/2;
					_loader.y = 0;
				}
				
				_mask.graphics.clear();
				_mask.graphics.moveTo(_loader.x, _loader.y);
				_mask.graphics.beginFill(0xffff00);
				_mask.graphics.drawRect(_loader.x, _loader.y, qWidth, qHeight);
				_mask.graphics.endFill();
			}
			else {
				_mask.graphics.clear();
			}
			
		}
		
	}	
}

