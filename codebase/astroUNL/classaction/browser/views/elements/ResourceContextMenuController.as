
package astroUNL.classaction.browser.views.elements {
	
	// this class adds context menu support for resources (question, animations, etc.) so that
	// they can be added to custom modules via right-clicking
	
	// to use, call ResourceContextMenuController.register(object) where object is the display object
	// that you want to have the right-click active on; the display object must have an object called 'data'
	// with a property called 'item', which should be the ResourceItem associated with the display object;
	// (it's done this way so that it can work with ClickableText objects)	
	
	import astroUNL.classaction.browser.resources.ModulesList;
	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.resources.Question;
	import astroUNL.classaction.browser.resources.Module;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.InteractiveObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	import flash.utils.Dictionary;
	
	
	
	public class ResourceContextMenuController {

		protected static const _addToMenuText:String = "Add to…";
		protected static const _removeFromMenuText:String = "Remove from…";
		protected static const _moduleMenuTextPrefix:String = "…";
		protected static const _addRelevantText:String = "Mark as relevant";
		protected static const _removeRelevantText:String = "Unmark as relevant";

		public function ResourceContextMenuController() {
			trace("ResourceContextMenuController not meant to be instantiated");			
		}
		
		public static function register(obj:InteractiveObject):void {
			if (obj is ClickableText) {				
				var ct:ClickableText = obj as ClickableText;
				ct.addMenuSelectListener(onMenuSelect);
			}
			else {
				Logger.report("ResourceContextMenuController set up to work only with ClickableText objects");
				return;
			}
		}
		
		public static function set modulesList(arg:ModulesList):void {
			_modulesList = arg;		
		}
		
		protected static var _selectedModule:Module;
		protected static var _selectedQuestion:Question;
		
		public static function setState(module:Module, question:Question):void {
			_selectedModule = module;
			_selectedQuestion = question;
		}		
		
		protected static function onRename(evt:ContextMenuEvent):void {
			(evt.contextMenuOwner as EditableClickableText).setEditable(true);			
		}
		
		protected static function onMenuSelect(evt:ContextMenuEvent):void {
			
			var ct:ClickableText = evt.contextMenuOwner as ClickableText;
			
			var item:ResourceItem = ct.data.item as ResourceItem;
			if (item==null) {
				Logger.report("item undefined in ResourceContextMenuController.onMenuSelect");
				return;
			}
			
			ct.clearMenu();
			
			var isEditable:Boolean = (evt.contextMenuOwner is EditableClickableText);
			if (isEditable) ct.addMenuItem("Rename", onRename);
			
			// when done these lists will be populated with the custom modules the
			// item is included and not included in
			var inList:Array = [];
			var outList:Array = [];

			// populate the in and out lists
			var i:int, j:int;
			for (i=0; i<_modulesList.modules.length; i++) {
				if (!_modulesList.modules[i].readOnly) {
					for (j=0; j<item.modulesList.length; j++) {
						if (_modulesList.modules[i]==item.modulesList[j]) {
							inList.push(_modulesList.modules[i]);
							break;
						}						
					}
					if (j>=item.modulesList.length) outList.push(_modulesList.modules[i]);
				}
			}
			
			_moduleLookup = new Dictionary();			
			var menuItem:ContextMenuItem;
			
			// modules the resource could be added to
			if (outList.length>0) {
				ct.addMenuItem(_addToMenuText, null, isEditable);
				for (i=0; i<outList.length; i++) {
					menuItem = ct.addMenuItem(_moduleMenuTextPrefix+outList[i].name, onItemAddToModule);
					_moduleLookup[menuItem] = outList[i];
				}
			}
			
			// modules the resource could be removed from
			if (inList.length>0) {
				ct.addMenuItem(_removeFromMenuText, null, (isEditable || outList.length>0));
				for (i=0; i<inList.length; i++) {
					menuItem = ct.addMenuItem(_moduleMenuTextPrefix+inList[i].name, onItemRemoveFromModule);
					_moduleLookup[menuItem] = inList[i];
				}			
			}
		}
		
		protected static function onAddRelevantItem(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as ClickableText).data.item as ResourceItem;
			if (item!=null && _selectedQuestion!=null && _selectedModule!=null) {
				
				// first, check that the resource belongs to the selected module, if not, add it
				var i:int;
				for (i=0; i<item.modulesList.length; i++) if (_selectedModule==item.modulesList[i]) break;
				if (i>=item.modulesList.length) _selectedModule.addResource(item);
				else trace("the resource already belongs to the selected module");
				
				_selectedQuestion.addRelevantResource(item);
			}
		}
		
		protected static function onRemoveRelevantItem(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as ClickableText).data.item as ResourceItem;
			if (item!=null && _selectedQuestion!=null) _selectedQuestion.removeRelevantResource(item);
		}
		
		protected static var _modulesList:ModulesList;
		
		// moduleLookup is used to lookup the module associated with a given context menu item
		protected static var _moduleLookup:Dictionary;
		
		protected static function onItemAddToModule(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as ClickableText).data.item as ResourceItem;
			if (item is Question) _moduleLookup[evt.target].addQuestion(item as Question);
			else _moduleLookup[evt.target].addResource(item);
		}
		
		protected static function onItemRemoveFromModule(evt:ContextMenuEvent):void {
			var item:ResourceItem = (evt.contextMenuOwner as ClickableText).data.item as ResourceItem;
			if (item is Question) _moduleLookup[evt.target].removeQuestion(item as Question);
			else _moduleLookup[evt.target].removeResource(item);
		}
		
	}
}

