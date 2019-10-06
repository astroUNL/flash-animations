
package astroUNL.classaction.browser.views {
	
	import br.hellokeita.utils.StringUtils;
		
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.QuestionsBank;
//	import astroUNL.classaction.browser.resources.AnimationsBank;
//	import astroUNL.classaction.browser.resources.ImagesBank;
//	import astroUNL.classaction.browser.resources.OutlinesBank;
//	import astroUNL.classaction.browser.resources.TablesBank;
	import astroUNL.classaction.browser.views.elements.ScrollableLayoutPanes;
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	import astroUNL.utils.easing.CubicEaser;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	
	
	public class SearchPanel extends Sprite {
		
		public static const QUESTION_SELECTED:String = "questionSelected";
		
		protected var _expandTime:Number = 200;
				
		protected var _hitPool:Vector.<ClickableText>;
		protected var _hitFormat:TextFormat;
		protected var _hitParams:Object;
		
		protected var _heightEaser:CubicEaser;
		protected var _heightTimer:Timer;
		
		protected var _margin:Number = 12;
		protected var _bottomMargin:Number = 20;
		protected var _panesMargin:Number = 1.5*_margin;
		
		protected var _panelHeightMin:Number = 40;
		protected var _panelWidth:Number = 290;
		protected var _panelHeight:Number;
		
		protected var _messageY:Number = 40;
		
		protected var _panes:ScrollableLayoutPanes;
		protected var _panesWidth:Number =_panelWidth - 2*_panesMargin;
		protected var _panesHeightLimit:Number = 140;
		
		protected var _background:Shape;
		protected var _maskedContent:Sprite;
		protected var _mask:Shape;
		protected var _message:TextField;
		protected var _paneNum:TextField;
		
		protected var _searchFieldBackground:Shape;
		protected var _searchFieldBackgroundColor:uint = 0x0C0E0E;
		protected var _searchFieldBorderColor:uint = 0x303635;
		
		protected var _backgroundColor:uint = 0x272D2E;
		
		protected var _back:SearchPanelButton;
		protected var _forward:SearchPanelButton;
		protected var _navButtonSpread:Number = 36;
		
		public function SearchPanel() {
			
			_background = new Shape();
			addChild(_background);
			
			_searchFieldBackground = new Shape();
			addChild(_searchFieldBackground);
			
			_searchFieldBackground.graphics.beginFill(_searchFieldBackgroundColor);
			_searchFieldBackground.graphics.lineStyle(1, _searchFieldBorderColor);
			_searchFieldBackground.graphics.drawRect(searchField.x-2, searchField.y-2, searchField.width+4, searchField.height+4);
			_searchFieldBackground.graphics.endFill();
			
			_panelHeight = _panelHeightMin;
			
			_heightEaser = new CubicEaser(_panelHeight);
			
			_heightTimer = new Timer(20);
			_heightTimer.addEventListener(TimerEvent.TIMER, onHeightTimer);
			
			_maskedContent = new Sprite();
			addChild(_maskedContent);
			
			_message = new TextField();
			_message.autoSize = "left";
			_message.wordWrap = true;
			_message.width = _panesWidth;
			_message.embedFonts = true;
			_message.selectable = false;
			_message.x = _margin;
			_message.y = _messageY;
			_message.defaultTextFormat = new TextFormat("Verdana", 12, 0xffffff, false, true);
			_maskedContent.addChild(_message);
			
			_panes = new ScrollableLayoutPanes(_panesWidth, _panesHeightLimit, 0, 5, {topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, columnSpacing: 0, numColumns: 1});
			_panes.x = _panesMargin;
			_maskedContent.addChild(_panes);
			
			_paneNum = new TextField();
			_paneNum.wordWrap = true;
			_paneNum.embedFonts = true;
			_paneNum.selectable = false;
			_paneNum.width = _panelWidth;
			_paneNum.height = 0;
			_paneNum.x = 0;
			_paneNum.defaultTextFormat = new TextFormat("Verdana", 12, 0xffffff, false, false, null, null, null, "center");
			_paneNum.autoSize = "center";
			_paneNum.text = " ";
			_paneNum.height = _paneNum.height; // this is necessary
			_paneNum.autoSize = "none";
			_maskedContent.addChild(_paneNum);
			
			_back = new SearchPanelButton();
			_back.x = (_panelWidth/2) - _navButtonSpread;
			_back.rotation = 180;
			_back.addEventListener(MouseEvent.CLICK, onBack);
			_back.visible = false;
			_maskedContent.addChild(_back);
			
			_forward = new SearchPanelButton();
			_forward.x = (_panelWidth/2) + _navButtonSpread;
			_forward.addEventListener(MouseEvent.CLICK, onForward);
			_forward.visible = false;
			_maskedContent.addChild(_forward);	
			
			
			_mask = new Shape();
			addChild(_mask);
			
			setChildIndex(searchField, numChildren-1);
			setChildIndex(searchButton, numChildren-1);
			
			_maskedContent.mask = _mask;
			
			_hitPool = new Vector.<ClickableText>();
			_hitParams = {};
			_hitFormat = new TextFormat("Verdana", 13, 0xffffff);
			
			searchButton.useHandCursor = true;
			searchButton.setStyle("upSkin", CAB_Button_upSkin);
			searchButton.setStyle("overSkin", CAB_Button_upSkin);
			searchButton.setStyle("downSkin", CAB_Button_downSkin);
			searchButton.setStyle("embedFonts", true);
			searchButton.setStyle("textFormat", new TextFormat("Verdana", 11, 0xffffff, false, false));
			searchButton.addEventListener(MouseEvent.CLICK, doSearch);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			redraw();
		}
		
		public function takeFocus():void {
			stage.focus = searchField;		
		}
		
		protected function onHeightTimer(evt:TimerEvent):void {
			var timeNow:Number = getTimer();
			if (timeNow>_heightEaser.targetTime) {
				_panelHeight = _heightEaser.targetValue;
				_heightEaser.init(_panelHeight);		
				_heightTimer.stop();
			}
			else {
				_panelHeight = _heightEaser.getValue(timeNow);				
			}
			dispatchEvent(new Event(Event.RESIZE));
			redraw();
		}
		
		protected function redraw():void {
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColor);
			_background.graphics.drawRect(0, 0, _panelWidth, _panelHeight);
			_background.graphics.endFill();
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000);
			_mask.graphics.drawRect(0, 0, _panelWidth, _panelHeight);
			_mask.graphics.endFill();
		}
		
		protected function onAddedToStage(evt:Event):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc);
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) doSearch();
		}
		
		protected function addLink(item:ResourceItem, num:int):void {
			var hit:ClickableText;
			var i:int;
			for (i=0; i<_hitPool.length; i++) {
				if (_hitPool[i].alpha==0) {
					hit = _hitPool[i];
					break;					
				}
			}			
			if (hit==null) {
				hit = new ClickableText("", null, _hitFormat, _panesWidth);
				hit.addEventListener(ClickableText.ON_CLICK, onHitClicked);
				_hitPool.push(hit);
			}
			hit.alpha = 1;
			if (num<10) hit.setText(" "+String(num)+". "+item.name);
			else hit.setText(String(num)+". "+item.name);
			hit.data = item;
			_panes.addContent(hit, _hitParams);
		}
		
		protected function clearLinks():void {
			_selectedModule = null;
			_selectedQuestion = null;
			for each (var hit:ClickableText in _hitPool) hit.alpha = 0;
			_panes.reset();
		}
		
		protected function onHitClicked(evt:Event):void {
			var item:ResourceItem = (evt.target as ClickableText).data;
			if (item==null) {
				trace("WARNING,invalid item in search panel");
				_selectedModule = null;
				_selectedQuestion = null;
			}
			else if (item.type==ResourceItem.QUESTION) {
				trace("item clicked: "+item.name);
				if (item.modulesList.length>0) {
					_selectedModule = item.modulesList[0];
					_selectedQuestion = item as Question;
					dispatchEvent(new Event(SearchPanel.QUESTION_SELECTED));
				}
			}
			else {
				trace("WARNING, unrecognized type in search panel");
				_selectedModule = null;
				_selectedQuestion = null;
			}
		}
		
		protected var _selectedModule:Module;
		protected var _selectedQuestion:Question;
		
		public function get selectedModule():Module {
			return _selectedModule;			
		}
		
		public function get selectedQuestion():Question {
			return _selectedQuestion;		
		}
		
		// these weights describe the relative importance of finding a match in various parts of an item's searchable text
		protected var _nameWeight:Number = 1.5;
		protected var _descriptionWeight:Number = 1;
		protected var _keywordWeight:Number = 1.3;
		
		protected function findHits(pattern:RegExp, lookup:Object, hits:Dictionary):void {
			var score:Number;
			var matches:Array = [];
			var i:int;
			for each (var item:ResourceItem in lookup) { 
				score = 0;
				matches = item.name.match(pattern);
				if (matches!=null) score += _nameWeight*matches.length;
				matches = item.description.match(pattern);
				if (matches!=null) score += _descriptionWeight*matches.length;
				for each (var keyword:String in item.keywords) {
					matches = keyword.match(pattern);
					if (matches!=null) score += _keywordWeight*matches.length;
				}
				if (score>0) {
					if (hits[item]==undefined) {
						hits[item] = {item: item, score: score, numMatches: 1};						
					}
					else {
						hits[item].score += score;
						hits[item].numMatches += 1;						
					}
				}
			}
		}
		
		protected function doSearch(evt:Event=null):void {
			
			var startTimer:Number = getTimer();
			
			var i:int, j:int;
			
			clearLinks();
			
			// if there are multiple search terms we show the items that match multiple terms before items that match fewer terms, regardless of score
			// within a group of items that match the same number of terms we sort by the score (which is assigned by the findHits function)
			
			// hitsDict is used to collect the hits by item in an efficient way
			// after all the hits have been collected they are put into the hits array
			var hitsDict:Dictionary = new Dictionary();
			
			// hits is a two dimensional array;
			// each entry in hits is a list of hit objects that have .item and .score properties
			//  hits[0] - contains the items that match all search terms
			//  hits[1] - contains the items that match all but one search term
			//  ....
			//  hits[hits.length-1] - contains the items that match only one search term
			var hits:Array = [];
			
			var pattern:RegExp;
			var term:String;
			var terms:Array = searchField.text.split(/\s/);
			
			// find the hits
			for (i=0; i<terms.length; i++) {
				term = StringUtils.trim(terms[i]);
				if (term!="") {
					hits.push([]);
					pattern = new RegExp(term, "i");
					findHits(pattern, QuestionsBank.lookup, hitsDict);
				}
			}
			
			var hit:Object;			
			var numHits:int = 0;
			
			// repackage the hits into the hits array
			for each (hit in hitsDict) hits[hits.length-hit.numMatches].push(hit);
			
			// present the sorted hits
			for (i=0; i<hits.length; i++) {
				hits[i].sortOn("score", Array.DESCENDING | Array.NUMERIC);
				for (j=0; j<hits[i].length; j++) {
					hit = hits[i][j];
					if (hit.item.type==ResourceItem.QUESTION && hit.item.modulesList.length>0) {
						numHits++;
						addLink(hit.item, numHits);
					}
//					trace(" "+numHits+", "+j+", "+hit.score+", "+hit.numMatches+", "+hit.item.name);				
				}
			}
							
			_message.text = "";
			_message.height = 0;
			if (numHits>0) _message.text = "results for \"" + StringUtils.trim(searchField.text) + "\":";
			else _message.text = "nothing found for \"" + StringUtils.trim(searchField.text) + "\"";
			
			_panes.y = _message.y + 3 + _message.height;
			
			var targetHeight:Number;
			
			if (numHits==0) {
				targetHeight = _panes.y + _margin;
				_paneNum.visible = _back.visible = _forward.visible = false;
			}
			else if (_panes.numPanes<=1) {
				targetHeight = _panes.y + _panes.cursorY + _margin;
				_paneNum.visible = _back.visible = _forward.visible = false;
			}
			else {
				_back.y = _forward.y = _panes.y + _panesHeightLimit + 0.33*_margin + (_forward.height/2);
				_paneNum.y = _forward.y - (_paneNum.height/2);
				targetHeight = _forward.y + (_forward.height/2) + 0.75*_margin;
				_paneNum.visible = _back.visible = _forward.visible = true;
				refreshPaneNumControl();
			}
			
			var timeNow:Number = getTimer();
			_heightEaser.setTarget(timeNow, _panelHeight, timeNow+_expandTime, targetHeight);
			
			_heightTimer.start();
			
			trace("sort time: "+(getTimer()-startTimer));
		}
		
		protected var _easeTime:Number = 200;
		
		protected function onBack(evt:MouseEvent):void {
			_panes.incrementPaneNum(-1, _easeTime);
			refreshPaneNumControl();
		}
		
		protected function onForward(evt:MouseEvent):void {
			_panes.incrementPaneNum(1, _easeTime);
			refreshPaneNumControl();
		}
		
		protected function refreshPaneNumControl():void {
			if (_panes.numPanes<=1) {
				_back.enabled = false;
				_forward.enabled = false;
			}
			else if (_panes.paneNum==0) {
				_back.enabled = false;
				_forward.enabled = true;
			}
			else if (_panes.paneNum==(_panes.numPanes-1)) {
				_back.enabled = true;
				_forward.enabled = false;
			}
			else {
				_back.enabled = true;
				_forward.enabled = true;
			}
			_paneNum.text = String(_panes.paneNum+1) + " of " + String(_panes.numPanes);
		}
		
		override public function set width(arg:Number):void {
			//
		}
		
		override public function get width():Number {
			return _panelWidth;
		}
		
		override public function set height(arg:Number):void {
			//
		}
		
		override public function get height():Number {
			return _panelHeight;
		}
		
	}
}

