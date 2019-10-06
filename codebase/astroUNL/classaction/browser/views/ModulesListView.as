
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.events.MenuEvent;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	import astroUNL.classaction.browser.views.elements.EditableClickableText;
	
	import astroUNL.utils.keylistener.KeyListener;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.Dictionary;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	public class ModulesListView extends Sprite {
		
		public static const MODULE_SELECTED:String = "moduleSelected";
		public static const START_ZIP_DOWNLOAD:String = "startZipDownload";

		protected var _createCommand:ClickableText;
		protected var _downloadCommand:ClickableText;
		
		protected var _content:Sprite;
		
		protected var _headingFormat:TextFormat;
		protected var _itemFormat:TextFormat;
		protected var _actionFormat:TextFormat;
		protected var _editingFormat:TextFormat;
		
		protected var _panelWidth:Number;
		protected var _panelHeight:Number;
		protected var _navButtonSpacing:Number = 20;
		protected var _panesTopMargin:Number = 0;
		protected var _panesSideMargin:Number = 15;
		protected var _panesBottomMargin:Number = 45;
		protected var _panesWidth:Number;
		protected var _panesHeight:Number;
		protected var _columnSpacing:Number = 20;
		protected var _numColumns:int = 3;
		protected var _easeTime:Number = 250;
		
		protected var _headingTopMargin:Number = 10;
		protected var _headingBottomMargin:Number = 4;
		protected var _headingMinLeftOver:Number = 25;
		protected var _itemLeftMargin:Number = 7;
		protected var _itemBottomMargin:Number = 9;
		protected var _itemMinLeftOver:Number = -9;
		
		protected var _leftButton:ResourcePanelNavButton;
		protected var _rightButton:ResourcePanelNavButton;
		
		protected var _standardHeading:TextField;
		protected var _customHeading:TextField;
		
		protected var _readOnly:Boolean;
		
		public function ModulesListView(w:Number, h:Number, readOnly:Boolean) {
			
			_panelWidth = w;
			_panelHeight = h;
			
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			
			_moduleLinks = new Dictionary();
			
			_readOnly = readOnly;
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeight, _navButtonSpacing, _navButtonSpacing, {topMargin: 0, leftMargin: _panesSideMargin, rightMargin: _panesSideMargin, bottomMargin: 0, columnSpacing: _columnSpacing, numColumns: _numColumns});
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			addChild(_panes);
			
			_headingFormat = new TextFormat("Verdana", 15, 0xffffff, true);
			_itemFormat = new TextFormat("Verdana", 14, 0xffffff);
			_actionFormat = new TextFormat("Verdana", 12, 0xffffff, false, true);
			_editingFormat = new TextFormat("Verdana", 14, 0x000000);
			
			if (_readOnly) {
				_standardHeading = createHeading("My Modules");
				_customHeading = createHeading("Custom Modules");
			}
			else {
				_standardHeading = createHeading("ClassAction Modules");
				_customHeading = createHeading("My Modules");
			}
			
			_createCommand = new ClickableText("create new module", null, _actionFormat, _panes.columnWidth);
			_createCommand.addEventListener(ClickableText.ON_CLICK, onCreateCustomModule, false, 0, true);
			_downloadCommand = new ClickableText("download my modules", null, _actionFormat, _panes.columnWidth);
			_downloadCommand.addEventListener(ClickableText.ON_CLICK, onDownloadCustomModules, false, 0, true);
			
			_leftButton = new ResourcePanelNavButton();
			_leftButton.x = _navButtonSpacing;
			_leftButton.y = _panelHeight/2;
			_leftButton.scaleX = -1;
			_leftButton.addEventListener(MouseEvent.CLICK, onLeftButtonClicked);
			_leftButton.visible = false;
			addChild(_leftButton);
			
			_rightButton = new ResourcePanelNavButton();
			_rightButton.x = _panelWidth - _navButtonSpacing;
			_rightButton.y = _panelHeight/2;
			_rightButton.addEventListener(MouseEvent.CLICK, onRightButtonClicked);
			_rightButton.visible = false;
			addChild(_rightButton);				
		}
		
		
		protected var _panes:ScrollableLayoutPanes;
		
		protected var _customNum:int = 1;
		
		protected function onCreateCustomModule(evt:Event):void {
			var newModule:Module = new Module(null, false);
			newModule.name = "New Module " + (_customNum++).toString();
			_modulesList.addModule(newModule);
			_moduleLinks[newModule].setEditable(true);
		}
		
		protected function onModuleDeleteRequest(evt:ContextMenuEvent):void {
			var module:Module = (evt.contextMenuOwner as EditableClickableText).data;
			if (module!=null) {
				var success:Boolean = _modulesList.removeModule(module);
				if (success) delete _moduleLinks[module];
			}
		}
		
		protected function onModuleNameEntered(evt:Event):void {
			evt.target.data.name = evt.target.text;
		}
		
		protected function onDownloadCustomModules(evt:Event):void {
			dispatchEvent(new Event(ModulesListView.START_ZIP_DOWNLOAD));
		}
		
		protected function onModuleCopyRequest(evt:ContextMenuEvent):void {
			var module:Module = (evt.contextMenuOwner as ClickableText).data;
			if (module!=null) {
				var copy:Module = module.getCopy();
				_modulesList.addModule(copy);
				_moduleLinks[copy].setEditable(true);
			}		
		}
		
		protected var _modulesList:ModulesList;
		
		public function get modulesList():ModulesList {
			return _modulesList;
		}
		
		public function set modulesList(m:ModulesList):void {
			_modulesList = m;
			_modulesList.addEventListener(ModulesList.UPDATE, onModuleListUpdate);
			redraw();
		}
		
		protected function onModuleListUpdate(evt:Event):void {
			redraw();
		}
		
		protected function onModuleUpdate(evt:Event):void {
			redraw();
		}
		
		public function setDimensions(w:Number, h:Number):void {
			if (w==_panelWidth && h==_panelHeight) return;
			_panelWidth = w;
			_panelHeight = h;
			_dimensionsUpdateNeeded = true;
			if (visible) redraw();
		}
		
		override public function set visible(visibleNow:Boolean):void {
			var previouslyVisible:Boolean = super.visible;
			super.visible = visibleNow;			
			if (!previouslyVisible && visibleNow) redraw();
		}
		
		protected var _dimensionsUpdateNeeded:Boolean = true;
		
		protected function doDimensionsUpdate():void {			
		
			// adjust the panes
			_panesWidth = _panelWidth - 2*_navButtonSpacing;
			_panesHeight = _panelHeight - _panesTopMargin - _panesBottomMargin;
			_panes.setDimensions(_panesWidth, _panesHeight);
			_panes.reset(); // needed here to recalculate columnWidth -- gets called again in redraw
			
			// adjust the layout
			_panes.x = _navButtonSpacing;
			_panes.y = _panesTopMargin;
			_leftButton.x = _navButtonSpacing;
			_leftButton.y = _panelHeight/2;
			_rightButton.x = _panelWidth - _navButtonSpacing;
			_rightButton.y = _panelHeight/2;
			
			// adjust the text widths
			_standardHeading.width = _panes.columnWidth;
			_customHeading.width = _panes.columnWidth;
			_createCommand.setWidth(_panes.columnWidth);
			_downloadCommand.setWidth(_panes.columnWidth);
			for each (var link:ClickableText in _moduleLinks) link.setWidth(_panes.columnWidth-_itemLeftMargin);
		
			_dimensionsUpdateNeeded = false;
		}
				
		protected function redraw():void {
			
			var startTimer:Number = getTimer();
			
			if (_dimensionsUpdateNeeded) doDimensionsUpdate();
			
			var oldPaneNum:int = _panes.paneNum;
			
			_panes.reset();
			
			var headingParams:Object = {topMargin: _headingTopMargin, bottomMargin: _headingBottomMargin, minLeftOver: _headingMinLeftOver};
			var itemParams:Object = {columnTopMargin: 45, leftMargin: _itemLeftMargin, bottomMargin: _itemBottomMargin, minLeftOver: _itemMinLeftOver};
			
			var i:int;
			var ct:ClickableText;
			
			_panes.addContent(_standardHeading, headingParams);
			for (i=0; i<_modulesList.modules.length; i++) {
				if (_modulesList.modules[i].readOnly) {
					if (_moduleLinks[modulesList.modules[i]]==undefined) {
						ct = new ClickableText(_modulesList.modules[i].name, _modulesList.modules[i], _itemFormat, _panes.columnWidth-_itemLeftMargin);		
						ct.addEventListener(ClickableText.ON_CLICK, onModuleClicked, false, 0, true);
						ct.addMenuSelectListener(onReadOnlyMenuSelect);
						if (!_readOnly) ct.addMenuItem(_copyModuleText, onModuleCopyRequest);						
						_moduleLinks[modulesList.modules[i]] = ct;
					}
					_panes.addContent(_moduleLinks[modulesList.modules[i]], itemParams);
				}
			}
			
			if (_readOnly) return;
			
			_panes.advanceColumn();
			
			var numCustom:int = 0;
			
			_panes.addContent(_customHeading, headingParams);
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					numCustom++;
					
					if (_moduleLinks[modulesList.modules[i]]==undefined) {
						// have not encountered this custom module before
						
						// listen for module updates
						_modulesList.modules[i].addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
						
						// create the label
						ct = new EditableClickableText(_modulesList.modules[i].name, _modulesList.modules[i], _itemFormat, _panes.columnWidth);		
						ct.addEventListener(EditableClickableText.DIMENSIONS_CHANGED, onModuleNameEntered, false, 0, true);
						ct.addEventListener(EditableClickableText.EDIT_DONE, onModuleNameEntered, false, 0, true);
						ct.addEventListener(ClickableText.ON_CLICK, onModuleClicked, false, 0, true);
						ct.addMenuSelectListener(onCustomMenuSelect);
						if (!_readOnly) ct.addMenuItem(_copyModuleText, onModuleCopyRequest);
						ct.addMenuItem(_deleteItemText, onModuleDeleteRequest);									
						_moduleLinks[modulesList.modules[i]] = ct;
					}	
					
					if (_moduleLinks[modulesList.modules[i]].text!=modulesList.modules[i].name) {
						_moduleLinks[modulesList.modules[i]].setText(modulesList.modules[i].name);
					}
					
					_panes.addContent(_moduleLinks[modulesList.modules[i]], itemParams);
				}
			}
			
			if (numCustom>0) itemParams.topMargin = 10;
			if (numCustom<_customModuleLimit) {
				_panes.addContent(_createCommand, itemParams);
				itemParams.topMargin = 0;
			}
			if (numCustom>0) _panes.addContent(_downloadCommand, itemParams);
			
			if (oldPaneNum>=_panes.numPanes) oldPaneNum = _panes.numPanes - 1;
			_panes.paneNum = oldPaneNum;
			
			_leftButton.visible = _rightButton.visible = (_panes.numPanes>1);
			
			
			_numCustom = numCustom;
			
//			trace("redraw modules list view: "+(getTimer()-startTimer));
		}
		
		protected var _numCustom:int;
		
		protected var _customModuleLimit:Number = Number.POSITIVE_INFINITY;
		
		protected var _deleteItemText:String = "Delete (hold Shift)";
		protected var _copyModuleText:String = "Copy Module";
		
		protected function onReadOnlyMenuSelect(evt:ContextMenuEvent):void {
			// this function handles the right-clicks on the read-only module names
			for (var i:int = 0; i<evt.target.customItems.length; i++) {
				if (evt.target.customItems[i].caption==_copyModuleText) {
					evt.target.customItems[i].enabled = _numCustom<_customModuleLimit;
				}
			}
		}
		
		protected function onCustomMenuSelect(evt:ContextMenuEvent):void {
			// this function handles the right-clicks on custom module names
			for (var i:int = 0; i<evt.target.customItems.length; i++) {
				if (evt.target.customItems[i].caption==_deleteItemText) {
					evt.target.customItems[i].enabled = KeyListener.isDown(Keyboard.SHIFT);
					KeyListener.reset();
				}
				else if (evt.target.customItems[i].caption==_copyModuleText) {
					evt.target.customItems[i].enabled = _numCustom<_customModuleLimit;
				}
			}
		}
		
		// moduleLinks contains the references to the ClickableText or EditableClickableText
		// instances associated with each module
		protected var _moduleLinks:Dictionary;
		
		protected function createHeading(text:String):TextField {
			var t:TextField = new TextField();
			t.text = text;
			t.autoSize = "left";
			t.height = 0;
			t.width = _panes.columnWidth;
			t.multiline = true;
			t.wordWrap = true;			
			t.selectable = false;
			t.setTextFormat(_headingFormat);
			t.embedFonts = true;
			return t;
		}				
		
		protected function onModuleClicked(evt:Event):void {
			dispatchEvent(new MenuEvent(ModulesListView.MODULE_SELECTED, evt.target.data));
		}

		protected function onLeftButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(-1, _easeTime);
		}
		
		protected function onRightButtonClicked(evt:MouseEvent):void {
			_panes.incrementPaneNum(1, _easeTime);
		}
				
	}
}

