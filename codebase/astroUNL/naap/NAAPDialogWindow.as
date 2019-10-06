
package astroUNL.naap {
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.core.UIComponent;
	import fl.controls.Button;
	
	public class NAAPDialogWindow extends UIComponent {
		
		protected var _title:String = "";
		protected var _range:Rectangle;
		protected var _titleTextField:TextField;
		protected var _closeButton:Button;
		protected var _currentTitleBar:DisplayObject;
		protected var _currentContent:DisplayObject;
		protected var _xDraggingOffset:Number;
		protected var _yDraggingOffset:Number;
		
		public function NAAPDialogWindow() {
			super();			
		}
		
		override protected function configUI():void {
			super.configUI();
			
			_titleTextField = new TextField();
			_titleTextField.mouseEnabled = false;
			_titleTextField.type = "dynamic";
			_titleTextField.autoSize = "left";
			_titleTextField.selectable = false;
			addChild(_titleTextField);
			
			_closeButton = new Button();
			_closeButton.label = "close";
			_closeButton.tabIndex = 10;
			_closeButton.useHandCursor = true;
			addChild(_closeButton);
			
			_closeButton.addEventListener("click", onCloseButtonPressed);
		}
		
		protected function onCloseButtonPressed(...ignored):void {
			visible = false;
		}
		
		public function get title():String {
			return _title;			
		}
		
		public function set title(arg:String):void {
			_title = arg;			
			invalidate();
		}
		
		override public function set width(arg:Number):void {
			throw new Error("width is read-only");
		}
		
		override public function set height(arg:Number):void {
			throw new Error("height is read-only");
		}
		
		protected function onMouseDownOnTitleBar(...ignored):void {
			parent.setChildIndex(this, parent.numChildren-1);
			_xDraggingOffset = x - parent.mouseX;
			_yDraggingOffset = y - parent.mouseY;
			stage.addEventListener("mouseUp", onMouseUpFromTitleBar);
			stage.addEventListener("mouseMove", onMouseMoveWithTitleBar);
		}
		
		protected function onMouseUpFromTitleBar(...ignored):void {
			stage.removeEventListener("mouseUp", onMouseUpFromTitleBar);
			stage.removeEventListener("mouseMove", onMouseMoveWithTitleBar);
		}
		
		protected function onMouseMoveWithTitleBar(evt:MouseEvent):void {
			setPosition(parent.mouseX+_xDraggingOffset, parent.mouseY+_yDraggingOffset, true);
			evt.updateAfterEvent();
		}
		
		public function center():void {
			// this function positions the window to the center of its range
			x = (_range.left + _range.width/2) - width/2;
			y = (_range.top + _range.height/2) - height/2;
		}
		
		public function setPosition(newX:Number, newY:Number, adjustDraggingOffsets:Boolean = false):void {
			// this function positions the window at the given location, assuming that location is within bounds
			
			// when the user drags the window to the range limit the window stops moving but the mouse
			// keeps going (obviously we can't stop it); if the user then moves the mouse in the opposite
			// direction the window won't start dragging again until the mouse reaches the position
			// defined by the offset; this offset is the originally clicked position, unless we allow
			// the dragging offsets to be recomputed; allowing the dragging offsets to adjusted makes
			// dragging more responsive and more natural when dragging to the limits
			
			// when recomputing the dragging offsets we introduce a margin, m, which defines the limit 
			// to which the dragging offsets will be adjusted (so that the mouse must always be over
			// the titlebar to cause dragging in a given axis); the margin is measured inwards from the
			// edge of the titlebar, so that if m is 2, for example, the active dragging point will
			// always be adjusted such that it is within the titlebar area but never less than
			// two pixels from the edge
			
			var m:Number = 2;
			
			// do the x position
			if (_range!=null && width>_range.width) {
				// the window is wider than the horizontal range, so center it
				x = (_range.left + _range.width/2) - width/2;
			}
			else {
				// enforce the range
				if (newX<_range.left) newX = _range.left;
				else if (newX>(_range.right-width)) newX = _range.right - width;
				
				// adjust the dragging offset if we're already at the range limit and that option is chosen
				if (adjustDraggingOffsets && (x==_range.left || x==(_range.right-width))) {					
					_xDraggingOffset = newX - parent.mouseX;
					
					// although we can adjust the dragging offsets, we limit the possible offsets
					// so that the mouse still has to be over the titlebar (within the margin)
					// to cause dragging movement
					if (_xDraggingOffset<(-width+m)) _xDraggingOffset = -width+m;
					else if (_xDraggingOffset>-m) _xDraggingOffset = -m;
				}
				
				x = newX;
			}
			
			// do the y position
			if (_range!=null && height>_range.height) {
				// the window is taller than the vertical range, so center it
				y = (_range.top + _range.height/2) - height/2;
			}
			else {
				// enforce the range
				if (newY<_range.top) newY = _range.top;
				else if (newY>(_range.bottom-height)) newY = _range.bottom - height;
				
				// adjust the dragging offset if we're already at the range limit and that option is chosen
				if (adjustDraggingOffsets && (y==_range.top || y==(_range.bottom-height))) {					
					_yDraggingOffset = newY - parent.mouseY;
					
					// although we can adjust the dragging offsets, we limit the possible offsets
					// so that the mouse still has to be over the titlebar (within the margin)
					// to cause dragging movement
					var titleBarHeight:Number = (_currentTitleBar!=null) ? _currentTitleBar.height : 0;
					if (_yDraggingOffset<(-titleBarHeight+m)) _yDraggingOffset = -titleBarHeight+m;
					else if (_yDraggingOffset>-m) _yDraggingOffset = -m;
				}
				
				y = newY;
			}
		}
		
		
		override protected function draw():void {
			
			// add the titlebar skin (if necessary) and register the mouse down listener
			var titleBar:DisplayObject = getDisplayObjectInstance(getStyleValue("titleBarSkin"));
			if (titleBar!=null && titleBar!=_currentTitleBar) {
				if (_currentTitleBar!=null) {
					// clear out the previous titlebar skin
					_currentTitleBar.removeEventListener("mouseDown", onMouseDownOnTitleBar);
					removeChild(_currentTitleBar);
				}
				addChild(titleBar);
				_currentTitleBar = titleBar;
				_currentTitleBar.addEventListener("mouseDown", onMouseDownOnTitleBar);
			}
			
		
			var content:DisplayObject = getDisplayObjectInstance(getStyleValue("content"));
			
			if (content!=null && content!=_currentContent) {
				if (_currentContent!=null) removeChild(_currentContent);
				addChild(content);
				_width = content.width;
				_currentContent = content;
			}
			
			if (content!=null) content.y = (titleBar!=null) ? titleBar.height : 0;
						
			if (content!=null && titleBar!=null) {
				titleBar.width = content.width;
				_height = content.height + titleBar.height;
			}
			else {
				titleBar.width = 250;				
			}
			
			var defaultTF:TextFormat = UIComponent.getStyleDefinition().defaultTextFormat as TextFormat;
			var preferredTitleTF:TextFormat = getStyleValue("titleTextFormat") as TextFormat;
			var titleTF:TextFormat = (preferredTitleTF!=null) ? preferredTitleTF : defaultTF;
			/*
			var preferredOptionsTF:TextFormat = getStyleValue("optionsTextFormat") as TextFormat;
			var optionsTF:TextFormat = (preferredOptionsTF!=null) ? preferredOptionsTF : defaultTF;
			*/
			
			var embed:Object = getStyleValue("embedFonts");
			
			_titleTextField.height = 0;
			_titleTextField.width = 0;
			_titleTextField.text = _title;
			_titleTextField.setTextFormat(titleTF);
			_titleTextField.defaultTextFormat = titleTF;
			if (embed!=null) _titleTextField.embedFonts = embed;

			var sideSpacingMultiplier:Number = getStyleValue("titleSpacingMultiplier") as Number;
			_titleTextField.y = Math.round((titleBar.height - _titleTextField.height)/2);
			_titleTextField.x = sideSpacingMultiplier*_titleTextField.y;
			
			setChildIndex(_titleTextField, numChildren-1);
			setChildIndex(_closeButton, numChildren-1);
			
			var closeButtonSkin:DisplayObject = getDisplayObjectInstance(getStyleValue("closeButtonSkin"));
			var closeButtonIcon:DisplayObject = getDisplayObjectInstance(getStyleValue("closeButtonIcon"));
			var preferredCloseButtonTF:TextFormat = getStyleValue("closeButtonTextFormat") as TextFormat;
			var closeButtonTF:TextFormat = (preferredCloseButtonTF!=null) ? preferredCloseButtonTF : defaultTF;
			
			var closeButtonPadding:Number = getStyleValue("closeButtonPadding") as Number;
			
			_closeButton.setStyle("disabledSkin", closeButtonSkin);
			_closeButton.setStyle("downSkin", closeButtonSkin);
			_closeButton.setStyle("emphasizedSkin", closeButtonSkin);
			_closeButton.setStyle("overSkin", closeButtonSkin);
			_closeButton.setStyle("selectedDisabledSkin", closeButtonSkin);
			_closeButton.setStyle("selectedDownSkin", closeButtonSkin);
			_closeButton.setStyle("selectedOverSkin", closeButtonSkin);
			_closeButton.setStyle("selectedUpSkin", closeButtonSkin);
			_closeButton.setStyle("upSkin", closeButtonSkin);
			
			_closeButton.setStyle("textFormat", closeButtonTF);
			_closeButton.setStyle("embedFonts", embed);
			
			_closeButton.setStyle("icon", closeButtonIcon);
			
			_closeButton.setStyle("textPadding", closeButtonPadding);
			_closeButton.setStyle("focusRectPadding", 3);
			_closeButton.drawNow();
			
			var closeButtonHeight:Number = 2*Math.floor((closeButtonIcon.height + 2*closeButtonPadding)/2) - 2; // iconHeight + 2*padding, rounded to previous even int, then minus 2
			var closeButtonWidth:Number = Math.ceil(closeButtonIcon.width + 3*closeButtonPadding + (_closeButton.textField.textWidth + 4)); // iconWidth + 3*padding + textWidth
			_closeButton.setSize(closeButtonWidth, closeButtonHeight);

			var closeButtonSpacing:Number = (titleBar.height - closeButtonHeight)/2;
			_closeButton.x = titleBar.width - closeButtonWidth - closeButtonSpacing;
			_closeButton.y = closeButtonSpacing;
			
			_closeButton.drawNow();
			
			setPosition(x, y);
			
			// always call super.draw() at the end
			super.draw();
		}
		
		private static var defaultStyles:Object = {
			
			titleBarSkin: "NAAPDialogWindow_titleBarSkin",
			titleTextFormat: new TextFormat("Verdana", 12, 0xffffff, true),
			
			closeButtonIcon: "NAAPDialogWindow_closeButtonIcon",
			closeButtonSkin: "NAAPDialogWindow_closeButtonSkin",
			closeButtonTextFormat: new TextFormat("Verdana", 10, 0x666666, true),
			closeButtonPadding: 4,
			
			titleSpacingMultiplier: 1.6,
			content: null,
			embedFonts: false,
			
			focusRectSkin: null,
			focusRectPadding: null,
			textFormat: null
		};
		
		public static function getStyleDefinition():Object { 
			return defaultStyles;
		}
		
		
		
		
		public function get range():Rectangle {
			return _range.clone();			
		}
		
		public function set range(arg:Rectangle):void {
			_range = arg.clone();
			invalidate();
		}
		
	}	
}
