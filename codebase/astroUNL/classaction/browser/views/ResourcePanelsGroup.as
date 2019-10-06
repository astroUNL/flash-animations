
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.ResourceItem;
	
	import astroUNL.classaction.browser.resources.AnimationsBank;
	import astroUNL.classaction.browser.resources.ImagesBank;
	import astroUNL.classaction.browser.resources.OutlinesBank;
	import astroUNL.classaction.browser.resources.TablesBank;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	
	public class ResourcePanelsGroup extends Sprite {
		
		public static const PREVIEW_ITEM_CHANGED:String = "previewItemChanged";
		
		protected var _panelWidth:Number = 800;
		protected var _panelHeight:Number = 300;
		protected var _previewItem:ResourceItem;
		protected var _panelsList:Vector.<ResourcePanel>;
		protected var _readOnly:Boolean;
		protected var _halo:ResourcePanelHalo;
		protected var _previewPosition:Point;
		protected var _tabSpacing:Number = 65;
		protected var _tabOffset:Number;
		
		public function ResourcePanelsGroup(readOnly:Boolean) {
			_readOnly = readOnly;
		}
		
		public function get previewItem():ResourceItem {
			return _previewItem;
		}
		
		public function get previewPosition():Point {
			return _previewPosition;			
		}
		
		public function setPreviewItem(item:ResourceItem, pos:Point=null):void {
			_previewItem = item;
			_previewPosition = pos;
			dispatchEvent(new Event(ResourcePanelsGroup.PREVIEW_ITEM_CHANGED));
		}
		
		public function init() {
			
			_halo = new ResourcePanelHalo();
			_halo.width = _panelWidth;
			addChild(_halo);
			
			_panelsList = new Vector.<ResourcePanel>();
			_tabOffset = 50;
			
			if (AnimationsBank.total>0) addPanel(ResourcePanel.ANIMATIONS);
			if (ImagesBank.total>0) addPanel(ResourcePanel.IMAGES);
			if (OutlinesBank.total>0) addPanel(ResourcePanel.OUTLINES);
			if (TablesBank.total>0) addPanel(ResourcePanel.TABLES);
		}
		
		public function get panelWidths():Number {
			return _panelWidth;
		}
		
import flash.utils.getTimer;
		public function set panelWidths(arg:Number):void {
			var startTimer:Number = getTimer();
			_panelWidth = arg;
			if (_halo!=null) _halo.width = _panelWidth;
			for each (var panel:ResourcePanel in _panelsList) panel.panelWidth = _panelWidth;
			trace("set panelWidths, "+(getTimer()-startTimer));
		}
		
		protected function addPanel(type:String):void {
			var newPanel:ResourcePanel = new ResourcePanel(this, type, _panelWidth, _panelHeight, _readOnly);
			newPanel.addEventListener(ResourcePanel.MINIMIZED, onMinimize);
			newPanel.addEventListener(ResourcePanel.MAXIMIZED, onMaximize);
			newPanel.setTabOffset(_tabOffset);
			addChild(newPanel);
			_panelsList.push(newPanel);
			_tabOffset += newPanel.tabWidth + _tabSpacing;
		}
		
		public function setState(module:Module, question:Question):void {
			for each (var panel:ResourcePanel in _panelsList) panel.setState(module, question);
		}
		
		public function set modulesList(arg:ModulesList):void {
			for each (var panel:ResourcePanel in _panelsList) panel.modulesList = arg;
		}
		
		protected function onMinimize(evt:Event):void {
			minimizeAll();
		}
		
		protected function onMaximize(evt:Event):void {
			var maximizedPanel:ResourcePanel = (evt.target as ResourcePanel);
			if (maximizedPanel!=null) {
				for each (var panel:ResourcePanel in _panelsList) {
					if (panel!=maximizedPanel) {
						panel.y = -_panelHeight;
						panel.inFront = false;
					}
				}
				maximizedPanel.y = -_panelHeight;
				maximizedPanel.inFront = true;
				setChildIndex(maximizedPanel, numChildren-1);
			}	
			_halo.y = -_panelHeight;
			_halo.visible = true;
		}
		
		public function minimizeAll():void {
			for each (var panel:ResourcePanel in _panelsList) {
				panel.y = 0;
				panel.inFront = false;
			}
			_halo.y = 0;
			_halo.visible = false;
			setPreviewItem(null);
		}
		
		public function get maxTabHeight():Number {
			var h:Number = 0;
			for each (var panel:ResourcePanel in _panelsList) {
				if (panel.tabHeight>h) h = panel.tabHeight;
			}
			return h;
		}
		
	}	
}

