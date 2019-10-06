
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.views.elements.DropDownMenu;
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.ModulesList;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class HeaderBar extends Sprite {
		
		public static const QUESTION_SELECTED:String = "questionSelected";
		public static const MODULE_SELECTED:String = "moduleSelected";
		public static const MODULES_LIST_SELECTED:String = "modulesListSelected";
		
		public static const MENU_ITEM_SELECTED:String = "menuItemSelected";
		
		public static const SEARCH:String = "Search";
		public static const ABOUT:String = "About";
		
		protected var _logoMenu:DropDownMenu;
		protected var _menusMask:Shape;
		
		protected var _navControl:NavControl;
		protected var _breadcrumbs:Breadcrumbs;
				
		protected var _width:Number = 800;
		protected const _height:Number = 29;
		protected var _dropLimit:Number = 1600;
		
		protected var _logoMenuWidth:Number = 80;
		
		public function HeaderBar(width:Number) {
			
			// the navigation events dispatched by the nav control and breadcrumbs bubble up
			
			_navControl = new NavControl();
			_navControl.x = 25;
			_navControl.y = 14;
			addChild(_navControl);
			
			_breadcrumbs = new Breadcrumbs();
			_breadcrumbs.x = 2*_navControl.x;
			_breadcrumbs.y = 4;
			addChild(_breadcrumbs);
			
			_menusMask = new Shape();
			addChild(_menusMask);
			
			_logoMenuWidth = logo.width;
			
			_logoMenu = new DropDownMenu(_logoMenuWidth);
			_logoMenu.addSelection(HeaderBar.SEARCH);
			_logoMenu.addSelection(HeaderBar.ABOUT);
			_logoMenu.y = _height;
			_logoMenu.addEventListener(Event.SELECT, onLogoMenuSelection);
			addChild(_logoMenu);
			
			_logoMenu.mask = _menusMask;
			
			logo.buttonMode = true;
			logo.addEventListener(MouseEvent.CLICK, onLogoClicked);
			
			this.width = width;
			
			redrawMask();
		}
		
		public function setState(module:Module, question:Question):void {
			_breadcrumbs.setState(module, question);
			_navControl.setState(module, question);			
		}
		
		public function get modulesList():ModulesList {
			return _navControl.modulesList;
		}
		
		public function set modulesList(list:ModulesList):void {
			_navControl.modulesList = list;
		}	
		
		public function get selection():String {
			return _logoMenu.selection;
		}
		
		protected function onLogoMenuSelection(evt:Event):void {
			dispatchEvent(new Event(HeaderBar.MENU_ITEM_SELECTED));				
			_logoMenu.close();
		}
		
		protected function onLogoClicked(evt:MouseEvent):void {
			_logoMenu.isOpen = !_logoMenu.isOpen;
		}
		
		protected function redrawMask():void {
			_menusMask.graphics.clear();
			_menusMask.graphics.beginFill(0xffff80);
			_menusMask.graphics.drawRect(0, _height, _width, _dropLimit);
			_menusMask.graphics.endFill();
		}
		
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(arg:Number):void {
			//
		}
		
		override public function get width():Number {
			return _width;			
		}
		
		override public function set width(arg:Number):void {			
			background.width = arg;
			_width = arg;
			logo.x = _width - 80;
			_logoMenu.x = logo.x;
			_breadcrumbs.maxWidth = logo.x - _breadcrumbs.x;
			redrawMask();
		}
		
	}	
}
