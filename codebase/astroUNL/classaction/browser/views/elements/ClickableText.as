
package astroUNL.classaction.browser.views.elements {
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.text.TextLineMetrics;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	
	import flash.utils.getTimer;
	
	public class ClickableText extends Sprite {
		
		public static const ON_CLICK:String = "onClick";
		
		public static var defaultFormat:TextFormat = new TextFormat("Verdana", 14, 0xffffff);
		
		public var data:* = null;
		
		protected var _text:String;
		protected var _format:TextFormat;
		protected var _width:Number;
		
		protected var _field:TextField;
		protected var _clickable:Boolean;
		
		protected var _hitArea:Sprite;
		
		protected var _background:Shape;
		
		
		public function ClickableText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			_format = new TextFormat();
			
			_background = new Shape();
			_background.visible = false;
			addChild(_background);
			
			_field = new TextField();
			_field.autoSize = "none";
			_field.border = false;
			_field.background = false;
			_field.multiline = false;
			_field.type = "dynamic";
			_field.selectable = false;
			_field.embedFonts = true;
			_field.mouseEnabled = false;
			addChild(_field);
			
			// normally _hitArea.mouseEnabled would be set to false, but we need it to be true
			// so that the context menu will work (we don't use the contextMenu of the ClickableText
			// object since the hitArea won't apply as we would like)
			_hitArea = new Sprite();
			_hitArea.alpha = 0;
			addChild(_hitArea);
			
			_hitArea.contextMenu = new ContextMenu();
			_hitArea.contextMenu.hideBuiltInItems();
			_hitArea.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, onContextMenuSelect, false, 0, true);
			
			// since the hit area is mouse enabled, we need to intercept mouse events and redispatch
			// them from the ClickableText object (as outside code will expect)
			_hitArea.addEventListener(MouseEvent.CLICK, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.DOUBLE_CLICK, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.MOUSE_DOWN, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.MOUSE_MOVE, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.MOUSE_OUT, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.MOUSE_OVER, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.MOUSE_UP, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.MOUSE_WHEEL, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.ROLL_OUT, onHitAreaMouseEvent, false, 0, true);
			_hitArea.addEventListener(MouseEvent.ROLL_OVER, onHitAreaMouseEvent, false, 0, true);
			
			hitArea = _hitArea;
			
			// _clickable must initially be set to the opposite of what's intended
			_clickable = false;
			setClickable(true);
			
			lock();
			
			setText(text);
			this.data = data;
			setFormat(format);
			setWidth(width);
			
			unlock();
		}
		
		// instead of working with the contextMenu of the ClickableText object directly, one
		// must use the clearMenu and addMenuItem functions
		
		override public function get contextMenu():ContextMenu {
			Logger.report("getting contextMenu of ClickableText not allowed");
			return null;
		}
		
		override public function set contextMenu(arg:ContextMenu):void {
			Logger.report("setting contextMenu of ClickableText not allowed");
		}
		
		public function get showBackground():Boolean {
			return _background.visible;
		}
		
		public function set showBackground(arg:Boolean):void {
			_background.visible = arg;			
			if (_background.visible) redrawBackground();
		}
		
		protected var _backgroundColor:uint = 0xa0a0a0;
		protected var _backgroundCornerRadius:Number = 8;
		protected var _backgroundLeftRightPadding:Number = 12;
		protected var _backgroundTopBottomPadding:Number = 4;
		protected var _backgroundAlpha:Number = 1;
		
		public function getBackgroundStyle():Object {
			return {color: _backgroundColor,
					alpha: _backgroundAlpha,
					cornerRadius: _backgroundCornerRadius,
					topBottomPadding: _backgroundTopBottomPadding,
					leftRightPadding: _backgroundLeftRightPadding};
		}
		
		public function setBackgroundStyle(style:Object):void {
			if (style.color) _backgroundColor = style.color;
			if (style.alpha) _backgroundAlpha = style.alpha;
			if (style.cornerRadius) _backgroundCornerRadius = style.cornerRadius;
			if (style.leftRightPadding) _backgroundLeftRightPadding = style.leftRightPadding;
			if (style.topBottomPadding) _backgroundTopBottomPadding = style.topBottomPadding;
			if (_background.visible) redrawBackground();
		}
		
		public function clearMenu():void {
			_hitArea.contextMenu.customItems = [];
		}
		
		public function addMenuItem(label:String, listener:Function=null, separatorBefore:Boolean=false):ContextMenuItem {
			var item:ContextMenuItem = new ContextMenuItem(label, separatorBefore);
			if (listener!=null) {
				// since the menuItemSelect event will come from the hitArea, we need to intercept
				// the event and rebroadcast so looks like it comes from the ClickableText object
				// (this is what the onMenuItemSelect function does)
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemSelect, false, 0, true);
				item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, listener, false, 0, true);
			}
			_hitArea.contextMenu.customItems.push(item);
			return item;
		}
		
		public function addMenuSelectListener(listener:Function=null):void {
			// the onContextMenuSelect takes on the task of rebroadcasting the menuSelect events
			// so they look like they come from ClickableTextObject
			_hitArea.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, listener, false, 0, true);			
		}
			
		public function onMenuItemSelect(evt:ContextMenuEvent):void {
			// the function rebroadcasts menuItemSelect events so they come from the ClickableText object
			if (evt.contextMenuOwner==_hitArea) {
				evt.stopImmediatePropagation();
				evt.target.dispatchEvent(new ContextMenuEvent(evt.type, evt.bubbles, evt.cancelable, this, this));
			}
		}
		
		protected function onHitAreaMouseEvent(evt:MouseEvent):void {
			// this handler repropagates events so they come from the ClickableText object
			// (we don't just set mouseEnabled of the hitArea to false since it needs to be
			// true to work with the ClickableText)
			evt.stopImmediatePropagation();
			dispatchEvent(evt.clone());			
		}
		
		public function get text():String {
			return _field.text;
		}
		
		public function setText(text:String=""):void {
			if (_text!=text) {
				_text = text;
				redraw();
			}
		}
		
		public function setFormat(format:TextFormat=null):void {
			if (format==null) {
				_format.font = ClickableText.defaultFormat.font;
				_format.size = ClickableText.defaultFormat.size;
				_format.color = ClickableText.defaultFormat.color;
				_format.bold = ClickableText.defaultFormat.bold;
				_format.italic = ClickableText.defaultFormat.italic;
				_format.align = ClickableText.defaultFormat.align;
				_format.leading = ClickableText.defaultFormat.leading;
			}
			else {
				_format.font = format.font;
				_format.size = format.size;
				_format.color = format.color;
				_format.bold = format.bold;
				_format.italic = format.italic;
				_format.align = format.align;
				_format.leading = format.leading;
			}
			_field.defaultTextFormat = _format;
			redraw();
		}
		
		public function getWidth():Number {
			return _width;
		}
		
		public function setWidth(width:Number):void {
			if (_width!=width) {
				_width = width;
				redraw();
			}
		}
		
		public function setClickable(arg:Boolean):void {
			if (arg && !_clickable) doSetClickable(arg);
			else if (!arg && _clickable) {
				doSetClickable(arg);
				showUnderline(false);
			}
			_clickable = arg;
		}
		
		protected function doSetClickable(arg:Boolean):void {
			// this function is separate from setClickable for the benefit of the EditableClickableText class
			if (arg) {
				addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false, 0, true);
				addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false, 0, true);
			}
			else {
				removeEventListener(MouseEvent.CLICK, onClick, false);
				removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc, false);
				removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc, false);
			}
			buttonMode = arg;
			useHandCursor = arg;
			tabEnabled = arg;
		}
		
		protected function redraw():void {
			if (_locked) return;
			
			_field.text = "";
			_field.scrollH = 0;
			_field.scrollV = 0;
			_field.autoSize = "left";
			_field.height = 0;
			_field.width = _width;
			if (_width!=0) {
				_field.multiline = true;
				_field.wordWrap = true;
			}
			else {
				_field.multiline = false;
				_field.wordWrap = false;
			}
			
			_field.text = _text;
			
			_backgroundWidth = 0;
			_backgroundHeight = 0;
			
			var i:int;
			var m:TextLineMetrics;
			_hitArea.graphics.clear();
			for (i=0; i<_field.numLines; i++) {
				m = _field.getLineMetrics(i);
				_hitArea.graphics.beginFill(0x0000ff, 0.5);
				if (_field.defaultTextFormat.align=="left") {
					_hitArea.graphics.drawRect(_field.x+2, _field.y+2+i*m.height, m.width, m.height);
				}
				else if (_field.defaultTextFormat.align=="center") {
					_hitArea.graphics.drawRect(_field.x+((_field.width-m.width)/2), _field.y+2+i*m.height, m.width, m.height);
				}
				else {
					_hitArea.graphics.drawRect(_field.x+_field.width-m.width-2, _field.y+2+i*m.height, m.width, m.height);
				}
				
				if (m.width>_backgroundWidth) _backgroundWidth = m.width;
				_backgroundHeight += m.height;
				
				_hitArea.graphics.endFill();
			}
			
			_backgroundWidth += 4;
			_backgroundHeight += 4;
			
			if (_background.visible) redrawBackground();
		}
		
		protected var _backgroundWidth:Number;
		protected var _backgroundHeight:Number;
				
		protected function redrawBackground():void {
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_background.graphics.drawRoundRect(_field.x-(_backgroundLeftRightPadding/2), _field.y-(_backgroundTopBottomPadding/2), _backgroundWidth+_backgroundLeftRightPadding, _backgroundHeight+_backgroundTopBottomPadding, 2*_backgroundCornerRadius);
			_background.graphics.endFill();
		}
		
		protected function onClick(evt:MouseEvent):void {
			if (_clickable) dispatchEvent(new Event(ClickableText.ON_CLICK));
		}
		
		// Problem: When the user right-clicks on the text the mouseOut event is dispatched,
		// however, we'd like to keep the text underlined while the context menu is shown.
		// Solution: This is done by watching for the menuSelect event, which is called just
		// before the mouseOut event. So, when the menuSelect event comes we set a flag
		// (skipMouseOutPropagation) that lets the mouseOut handler know to ignore and stop
		// the next mouseOut event. Now, to know when the context menu has been closed we
		// listen for a mouseOver event from the stage. When this happens we dispatch a
		// mouseOut event -- effectively the one we suppressed when the context menu was
		// selected. Note that it's possible that this ClickableText instance might be removed
		// from the stage as a result of user interaction with the context menu (e.g. the user
		// deletes a module). In this case we listen for a removedFromStage event so we can
		// deregister the mouseOver listener for the stage.
		// Note: the skipMouseOutPropagation flag is reset (set to false) in the mouseOver handler
		// or the stage mouseOver handler, but in the latter case its existing value is used to
		// determine whether to dispatch the mouseOut event. This is done in case the user opens the
		// context menu, then clicks somewhere else on the same text item to close the menu. (The
		// stage mouseOver event follows the text's mouseOver event, and in this case we don't want
		// the mouseOut event fired).	
		
		protected function onMouseOverFunc(evt:MouseEvent):void {
			_skipMouseOutPropagation = false;
			showUnderline(true);
		}
		
		protected function onMouseOutFunc(evt:MouseEvent):void {
			if (_skipMouseOutPropagation) evt.stopImmediatePropagation();
			else showUnderline(false);
		}
		
		protected function showUnderline(arg:Boolean):void {
			_format.underline = arg;
			_field.defaultTextFormat = _format;
			_field.setTextFormat(_format);
		}
		
		protected var _skipMouseOutPropagation:Boolean;
		
		protected function onContextMenuSelect(evt:ContextMenuEvent):void {
			if (evt.contextMenuOwner==_hitArea) {
				_skipMouseOutPropagation = true;
				stage.addEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver, false, 0, true);
				addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
				
				// we've created a proxy mouse area for the context menu interaction, but we want the
				// events to look like they're coming from this ClickableText object, so we cancel
				// the event and redispatch it with the desired mouseTarget and contextMenuOwner values
				// (this is also why we've checked the value of evt.contextMenuOwner at the beginning of
				// this function -- we should only execute this code once)
				evt.stopImmediatePropagation();
				evt.target.dispatchEvent(new ContextMenuEvent(evt.type, evt.bubbles, evt.cancelable, this, this));
			}
		}
		
		protected function onStageMouseOver(evt:MouseEvent):void {
			if (_skipMouseOutPropagation) {
				_skipMouseOutPropagation = false;
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
			}
			stage.removeEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
		}
		
		protected function onRemovedFromStage(evt:Event):void {
			// the ClickableText could be removed from stage for a variety of reasons
			// (for example, the ModulesListView removes and then adds back ClickableText
			// objects when it redraws the list)
			if (_skipMouseOutPropagation) {
				_skipMouseOutPropagation = false;
				dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
			}
			stage.removeEventListener(MouseEvent.MOUSE_OVER, onStageMouseOver, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
		}
		
		protected var _locked:Boolean = false;
		
		public function lock():void {
			_locked = true;
		}
		
		public function unlock():void {
			_locked = false;	
			redraw();
		}
		
		override public function toString():String {
			return "[object ClickableText, text: " + _text + "]";
		}
	}
}

