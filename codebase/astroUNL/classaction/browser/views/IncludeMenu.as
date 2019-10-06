
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;	
	import astroUNL.classaction.browser.views.elements.ClickableText;	
	
	import flash.utils.Dictionary;
	
	import flash.display.Sprite;
	import fl.controls.CheckBox;
	import flash.events.Event;
	
	public class IncludeMenu extends Sprite {
		
		protected var _content:Sprite;
		protected var _background:Sprite;
		
		protected var _moduleHasListener:Dictionary;
		
		public function IncludeMenu() {
			
			_moduleHasListener = new Dictionary();
			
			_background = new Sprite();
			addChild(_background);			
		}
		
		protected var _checkBoxesList:Array;
		
		
		protected function redraw():void {
			// this function adds checkboxes for all custom modules
			// it should be called anytime the modules list changes
			
			if (_content!=null) removeChild(_content);
			_content = new Sprite();
			addChild(_content);
			
			_checkBoxesList = [];
			
			var ck:CheckBox;
			var y:Number = 0;
			var yStep:Number = 20;
			for (var i:int = 0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					ck = new CheckBox();
					ck.y = y;
					y += yStep;
					ck.label = _modulesList.modules[i].name;
					ck.addEventListener(Event.CHANGE, onCheckBoxChange);
					_checkBoxesList.push({checkBox: ck, module: _modulesList.modules[i]});
					_content.addChild(ck);
				}				
			}
			
//			var ct:ClickableText = new ClickableText("new module");
//			ct.y = y;
//			_content.addChild(ct);
			
			_background.graphics.clear();
			_background.graphics.beginFill(0x808080);
			_background.graphics.drawRect(0, 0, 120, y);
			_background.graphics.endFill();
		}
		
		protected function refresh():void {
			if (_selectedQuestion!=null) {
				_content.visible = true;
				
				trace("\ninclude menu should be visible\n");
				
				var i:int, j:int;				
				var m:Module;
				
				for (i=0; i<_checkBoxesList.length; i++) {
					m = _checkBoxesList[i].module;
					for (j=0; j<m.allQuestionsList.length; j++) {
						if (m.allQuestionsList[j]==_selectedQuestion) {
							_checkBoxesList[i].checkBox.selected = true;
							break;
						}
					}
					if (j>=m.allQuestionsList.length) {
						_checkBoxesList[i].checkBox.selected = false;
					}
				}
				
			}
			else {
				trace("not visible");
				_content.visible = false;
			}
		}
		
		
		protected var _selectedQuestion:Question;
		
		public function setState(module:Module, question:Question):void {
			_selectedQuestion = question;
			refresh();
			
		}
		
		protected function onCheckBoxChange(evt:Event):void {
			var i:int;
			if (evt.target.selected) {
				for (i=0; i<_checkBoxesList.length; i++) {
					if (_checkBoxesList[i].checkBox==evt.target) {
						_checkBoxesList[i].module.addQuestion(_selectedQuestion);
						break;
					}
				}
			}
			else {
				for (i=0; i<_checkBoxesList.length; i++) {
					if (_checkBoxesList[i].checkBox==evt.target) {
						_checkBoxesList[i].module.removeQuestion(_selectedQuestion);
						break;
					}
				}
			}
		}
		
		protected var _modulesList:ModulesList;
		
		public function get modulesList():ModulesList {
			return _modulesList;
		}
		
		public function set modulesList(m:ModulesList):void {
			_modulesList = m;
			_modulesList.addEventListener(ModulesList.UPDATE, onModulesListUpdate);
			redraw();
			refresh();
		}
		
		protected function onModulesListUpdate(evt:Event):void {
			// I think it is benign to repeatedly add the same event listener to an object, but I'm not sure
			for (var i:int = 0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly && !_moduleHasListener[_modulesList.modules[i]]) {
					_modulesList.modules[i].addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
					_moduleHasListener[_modulesList.modules[i]] = true;					
				}
			}
			redraw();
			refresh();
		}		
		
		protected function onModuleUpdate(evt:Event):void {
			redraw();
			refresh();			
		}
		
	}	
}

