
package astroUNL.classaction.browser.views {
	
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.Module;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.events.StateChangeRequestEvent;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class NavControl extends Sprite {
		
		protected var _back:NavButton;
		protected var _forward:NavButton;
		
		protected var _navInProgress:Boolean = false;
		protected var _navItem:NavItem; // the item that is being navigated to if a nav is in progress
		protected var _currItem:NavItem; // the currently selected item in the queue
		
		protected var _customModules:Dictionary; // used so that module listeners get added just once
		protected var _modulesList:ModulesList;
		protected var _id:int = 0; // assigns unique numbers to queue items, for debugging
		
		// setStateCalled is a flag used to verify that setState gets called during a nav event -- if it
		// doesn't, then a queue panic occurs
		protected var _setStateCalled:Boolean = false; 
		
		public function NavControl() {
			
			var shift:Number = 6.5;
			
			_back = new NavButton();
			_back.addEventListener(MouseEvent.CLICK, onBack);
			_back.rotation = 180;
			_back.x = -shift;
			addChild(_back);
			
			_forward = new NavButton();
			_forward.addEventListener(MouseEvent.CLICK, onForward);
			_forward.x = shift;
			addChild(_forward);
			
			updateButtons();
		}
		
		protected function updateButtons():void {
			// this function updates the buttons so that they are appropriately enabled or
			// disabled depending on where we are in the queue
			// it should be called whenever the currently selected item is set
			if (_currItem==null) {
				_forward.enabled = false;
				_back.enabled = false;
			}
			else {
				_forward.enabled = (_currItem.next!=null);
				_back.enabled = (_currItem.prev!=null);
			}
		}
		
		public function setState(module:Module, question:Question):void {
			// called by the main controller when the state has changed
			_setStateCalled = true;
			if (_navInProgress) {
				// the main controller is reacting to a state change request dispatched by this class
				if (_navItem==null || module!=_navItem.module || question!=_navItem.question) {
					// should not happen
					panic();
					addNewStateToQueue(module, question);
				}
				else {
					// a successful navigation
					_currItem = _navItem;
				}
			}
			else {
				// a new state
				addNewStateToQueue(module, question);
			}
			enforceLengthLimit();
			updateButtons();
		}
		
		protected function addNewStateToQueue(module:Module, question:Question):void {
			// this function adds a new state to the queue and makes it the selected item
			var item:NavItem;
			item = new NavItem();
			item.module = module;
			item.question = question;
			item.id = _id++;
			if (_currItem!=null) {
				removeBranch(_currItem.next);
				_currItem.next = item;
				item.prev = _currItem;
			}
			_currItem = item;
		}
		
		public function get modulesList():ModulesList {
			return _modulesList;
		}
		
		public function set modulesList(list:ModulesList):void {
			// the NavBar listens to the modules list so that it can attach listeners to 
			// newly added modules and prune out deleted modules
			_modulesList = list;
			_customModules = new Dictionary();
			_modulesList.addEventListener(ModulesList.UPDATE, onModuleListUpdate);
			onModuleListUpdate();
		}
		
		protected function onBack(evt:MouseEvent):void {
			if (_currItem!=null && _currItem.prev!=null) doNav(_currItem.prev);
		}
		
		protected function onForward(evt:MouseEvent):void {
			if (_currItem!=null && _currItem.next!=null) doNav(_currItem.next);
		}				
		
		protected function onModuleListUpdate(evt:Event=null):void {
			// assign listeners to each of the custom modules (assuming we haven't already)
			// so that we know when a question has been removed from a module, which 
			// may necessitate pruning of the queue
			for each (var m:Module in _modulesList.modules) {
				if (!m.readOnly && _customModules[m]==undefined) {
					_customModules[m] = true;
					m.addEventListener(Module.UPDATE, onModuleUpdate, false, 0, true);
				}
			}
			prune(); // a module in the queue may have been deleted
		}
		
		protected function onModuleUpdate(evt:Event):void {
			prune(); // a question in the queue may have been removed from a module
		}

		protected function prune():void {
			var currItemAtStart:NavItem = _currItem;
			
			var item:NavItem;
			var next:NavItem;
			
			// first, remove all states referencing a deleted module
			if (_currItem!=null) {
				item = _currItem;
				while (item.prev!=null) item = item.prev;
				while (item!=null) {
					next = item.next;
					if (item.module!=null && !item.module.readOnly && !_modulesList.hasModule(item.module)) {
						// deleted module found
						removeItem(item);
					}
					item = next;
				}
			}
			
			// remove all states where the question is no longer in the custom module
			if (_currItem!=null) {
				item = _currItem;
				while (item.prev!=null) item = item.prev;
				while (item!=null) {
					next = item.next;
					if (item.module!=null && item.question!=null && !item.module.readOnly && !item.module.hasQuestion(item.question)) {
						// removed question found
						removeItem(item);
					}
					item = next;
				}
			}
				
			// consolidate all consecutive identical states
			if (_currItem!=null) {
				item = _currItem;
				while (item.prev!=null) item = item.prev;
				while (item!=null && item.next!=null) {					
					if (item.module==item.next.module && item.question==item.next.question) {
						// identical states found						
						removeItem(item.next);
					}
					else item = item.next;
				}
			}
			
			// if the current item changed due to pruning then we need to sync to the new state
			// (the removeItem called may have changed _currItem)
			if (currItemAtStart!=_currItem) doNav(_currItem);
		}
				
		protected function doNav(item:NavItem):void {
			// this function is called when the currently selected item needs to change
			// (it is up to the Main controller to actually call setState)
			// due to how prune is programmed, if setState is not called then we need to reset the queue (panic)
			_setStateCalled = false;
			_navInProgress = true;
			_navItem = item;
			if (_navItem!=null) dispatchEvent(new StateChangeRequestEvent(_navItem.module, _navItem.question, true));
			else dispatchEvent(new StateChangeRequestEvent(null, null));
			_navInProgress = false;
			if (!_setStateCalled) panic(); 
		}
		
		// a very long queue can cause the prune function to take a lot of time, so a limit is useful 
		//  - note that the limit applies only to the number of items before the currently selected item
		//  - set to a negative number if you don't want a limit
		protected var _lengthLimit:int = 20;
		
		protected function enforceLengthLimit():void {
			// this function enforces a limit on the length of the queue preceeding the currently selected item
			if (_currItem==null) return;
			var lastItem:NavItem = _currItem;
			for (var i:int = 0; i<_lengthLimit; i++) {
				if (lastItem.prev!=null) lastItem = lastItem.prev;
				else break;
			}
			removeRoot(lastItem.prev);
		}
		
		protected function removeItem(item:NavItem):void {
			// removes an item from the queue by splicing the previous and next items together
			// if the item is the currently selected item then that designation will 
			// go to, in order: the previous item, the next item, null
			// (the preference for the previous item is due to how pruning of redundant states works)
			
			// note that this function directly changes the currently selected item even though
			// currItem is supposed to be set by the Main controller class -- this is how I wrote
			// it originally and I don't see an easy and safe way to change it -- instead, the prune
			// function (which is the only one that called removeItem) will call doNav, and doNav
			// will insist on a reaction from the Main controller or it will call panic
			
			if (item!=null) {
				if (item==_currItem) {
					if (item.prev!=null) _currItem = item.prev;
					else if (item.next!=null) _currItem = item.next;
					else _currItem = null;
				}
				if (item.next!=null) item.next.prev = item.prev;
				if (item.prev!=null) item.prev.next = item.next;			
				item.module = null;
				item.question = null;
				item.next = null;
				item.prev = null;
			}			
		}
		
		protected function removeBranch(item:NavItem):void {
			// removes an item and all items after it
			// if any of the items are the currently selected item then that designation should
			// go to the item just before the ones that have been removed (the tip)
			// (as long as removeBranch is called only by addNewStateToQueue then none of the
			// items being removed should be the currently selected item)
			var tip:NavItem = null;
			if (item!=null && item.prev!=null) {
				item.prev.next = null;
				tip = item.prev;
			}
			var next:NavItem;
			while (item!=null) {
				next = item.next;
				if (_currItem==item) {
					panic();
					doNav(tip);
				}
				item.module = null;
				item.question = null;
				item.next = null;
				item.prev = null;
				item = next;
			}			
		}
		
		protected function removeRoot(item:NavItem):void {
			// removes an item and all items before it
			// if any of the items are the currently selected item then that designation should
			// go to the item just after the ones that have been removed (the new root)
			// (as long as removeRoot is called only by the length enforcing function, then removing
			// the currently selected item should never happen)
			var newRoot:NavItem = null;
			if (item!=null && item.next!=null) {
				item.next.prev = null;
				newRoot = item.next;
			}
			var prev:NavItem;
			while (item!=null) {
				prev = item.prev;
				if (_currItem==item) {
					panic();
					doNav(newRoot);					
				}
				item.module = null;
				item.question = null;
				item.next = null;
				item.prev = null;
				item = prev;
			}			
		}
		
		protected function panic():void {
			Logger.report("queue panic in NavButtons");
			_currItem = null;
			_navItem = _currItem; // this step prevents a redundant panic call in doNav
			updateButtons();			
		}
		
//		protected function traceQueue():void {
//			if (_currItem!=null) {
//				trace("queue:");
//				var item:NavItem = _currItem;
//				var moduleName:String, questionName:String;
//				while (item.prev!=null) item = item.prev;
//				var pre:String;
//				do {
//					pre = (item==_currItem) ? " +" : "  ";
//					moduleName = (item.module!=null) ? item.module.name : "null";
//					questionName = (item.question!=null) ? item.question.name : "null";
//					trace(pre+" "+item.id+", "+moduleName+", "+questionName);
//					item = item.next;
//				} while (item!=null);
//			}
//			else trace("queue:\r ...empty...");
//		}
		
	}	
}


import astroUNL.classaction.browser.resources.Module;
import astroUNL.classaction.browser.resources.Question;

internal class NavItem {
	public var module:Module;
	public var question:Question;
	public var next:NavItem;
	public var prev:NavItem;
	public var id:int;
}

