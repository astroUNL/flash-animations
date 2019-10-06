
package astroUNL.classaction.browser.views.elements {
	
	import br.hellokeita.utils.StringUtils;
	
	
	import flash.text.TextFormat;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	
	import astroUNL.classaction.browser.views.elements.ClickableText;
	
	public class EditableClickableText extends ClickableText {
		
		public static const EDIT_DONE:String = "editDone";
		public static const DIMENSIONS_CHANGED:String = "dimensionsChanged";
		
		protected var _halo:FocusHalo;
		
		protected var _editingFormat:TextFormat;
		
		protected var _editMenuItem:ContextMenuItem;
		
		public function EditableClickableText(text:String="", data:*=null, format:TextFormat=null, width:Number=0) {
			
			_editingFormat = new TextFormat();
			
			_halo = new FocusHalo();
			_halo.visible = false;
			_halo.mouseEnabled = false;
			addChild(_halo);
			
			super(text, data, format, width);
			
			_editMenuItem = addMenuItem("Rename", onEdit);
		}		
		
		protected function onEdit(evt:ContextMenuEvent):void {
			setEditable(true);
		}
		
		override public function setFormat(format:TextFormat=null):void {
			var notLocked:Boolean = !_locked;
			if (notLocked) lock();
			
			super.setFormat(format);
			
			_editingFormat.font = _format.font;
			_editingFormat.size = _format.size;
			_editingFormat.color = 0x000000;
			_editingFormat.bold = _format.bold;
			_editingFormat.italic = _format.italic;
			_editingFormat.underline = false;
			
			_field.defaultTextFormat = (_editable) ? _editingFormat : _format;
			
			if (notLocked) unlock();
		}
		
		override protected function redraw():void {
			super.redraw();
			updateHalo();
		}
		
		protected function updateHalo():void {
			if (_halo.scale9Grid!=null) {
				_halo.scaleX = _halo.scaleY = 1;
				_halo.width = _field.width + (_halo.width - _halo.scale9Grid.width);
				_halo.height = _field.height + (_halo.height - _halo.scale9Grid.height);
			}
			_halo.x = _field.width/2;
			_halo.y = _field.height/2;			
		}

		protected function selectAndFocus():void {
			stage.focus = _field;
			_field.setSelection(0, _field.text.length);
		}
		
		protected var _editable:Boolean = false;
		
		public function setEditable(editable:Boolean):void {
			
			if (_editable && !editable) {
				_halo.visible = false;
				_field.border = false;
				_field.background = false;
				_field.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn, false);
				_field.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false);
				_field.removeEventListener(Event.CHANGE, onFieldChanged, false);
				
				_field.type = "dynamic";
				_field.selectable = false;
				_field.defaultTextFormat = _format;
				_field.setTextFormat(_format);
				
				if (_clickable) doSetClickable(true);

				_hitArea.mouseEnabled = true;
				_field.mouseEnabled = false;
				_halo.mouseEnabled = false;
				
				_editable = false;
				
				_editMenuItem.enabled = true;
			}
			else if (!_editable && editable) {
				_halo.visible = true;
				_field.border = true;
				_field.borderColor = 0xafd6fa;
				_field.background = true;
				_field.backgroundColor = 0xffffff;
				_field.addEventListener(FocusEvent.FOCUS_IN, onFocusIn, false, 0, true);
				_field.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut, false, 0, true);
				_field.addEventListener(Event.CHANGE, onFieldChanged, false, 0, true);
				
				_field.type = "input";
				_field.selectable = true;
				_field.defaultTextFormat = _editingFormat;
				_field.setTextFormat(_editingFormat);
				
				if (_clickable) doSetClickable(false);
				
				_hitArea.mouseEnabled = false;
				_field.mouseEnabled = true;
				_halo.mouseEnabled = true;
				
				_numLines = _field.numLines;
				_editable = true;
				
				_editMenuItem.enabled = false;
				
				updateHalo();
				selectAndFocus();
			}
		}
		
		protected var _numLines:int;
		
		protected function onFieldChanged(evt:Event):void {
			if (_width==0 || _field.numLines!=_numLines) {
				updateHalo();
				_numLines = _field.numLines;
				dispatchEvent(new Event(EditableClickableText.DIMENSIONS_CHANGED));
			}
		}
		
		protected var _hasFocus:Boolean = false;
		
		protected function onFocusIn(evt:FocusEvent):void {
			_hasFocus = true;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc, false, 0, true);
		}
		
		protected function onFocusOut(evt:FocusEvent):void {
			_hasFocus = false;
			
			_field.text = StringUtils.trim(_field.text);
			if (_field.text=="") _field.text = _text;
			setText(_field.text);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc, false);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc, false);
			dispatchEvent(new Event(EditableClickableText.EDIT_DONE));
			
			// there's some kind of intermittent bug where underlines persist after editing
			// this line has been added in the hope of preventing this behavior
			_format.underline = false;
			
			setEditable(false);
		}
		
		public function get hasFocus():Boolean {
			return _hasFocus;
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) stage.focus = null;
		}
		
		protected function onMouseDownFunc(evt:MouseEvent):void {
			if (evt.target!=_field && evt.target!=_halo) stage.focus = null;
		}
		
		override public function get width():Number {
			return _field.width;
		}
		
		override public function get height():Number {
			return _field.height;			
		}		
				
	}	
}
