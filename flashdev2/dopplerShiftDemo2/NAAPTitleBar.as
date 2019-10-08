
package {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	import flash.events.Event;
	
	import flash.utils.getDefinitionByName;
	
	import fl.core.UIComponent;
	import fl.controls.Button;
	
	import flash.utils.getTimer;
	
	import flash.geom.Rectangle;
	
	
	public class NAAPTitleBar extends UIComponent {
		
		protected var _title:String = "Title";
		protected var _helpContentClassName:String = "";
		
		protected var _resetButton:Button;
		protected var _helpButton:Button;
		protected var _aboutButton:Button;
		
		protected var _helpWindow:NAAPDialogWindow;
		protected var _aboutWindow:NAAPDialogWindow;
		
		protected var _background:DisplayObject;
		protected var _titleTextField:TextField;
		
		protected var _allowReset:Boolean = true;
		
		public static const RESET:String = "reset";
		
		public function NAAPTitleBar() {
			
			super();			
			
		}
		
		override protected function configUI():void {
			
			super.configUI();
			
			_helpWindow = new NAAPDialogWindow();
			_aboutWindow = new NAAPDialogWindow();
			
			_aboutWindow.visible = false;
			_helpWindow.visible = false;
			
			addChild(_helpWindow);
			addChild(_aboutWindow);
			
			_helpWindow.title = "Help";
			_aboutWindow.title = "About";
			
			_resetButton = new Button();
			_helpButton = new Button();
			_aboutButton = new Button();
			
			_resetButton.label = "reset";
			_helpButton.label = "help";
			_aboutButton.label = "about";
			
			_resetButton.tabIndex = 1;
			_helpButton.tabIndex = 2;
			_aboutButton.tabIndex = 3;
			
			var emptySprite:Sprite;
			
			var buttonsList:Array = [_aboutButton, _helpButton, _resetButton];
			
			for each (var button in buttonsList) {
				
				button.useHandCursor = true;
				
				button.textField.autoSize = "left";
				button.textField.width = 0;
				button.textField.height = 0;
				
				emptySprite = new Sprite();
				button.setStyle("disabledSkin", emptySprite);
				button.setStyle("downSkin", emptySprite);
				button.setStyle("emphasizedSkin", emptySprite);
				button.setStyle("overSkin", emptySprite);
				button.setStyle("selectedDisabledSkin", emptySprite);
				button.setStyle("selectedDownSkin", emptySprite);
				button.setStyle("selectedOverSkin", emptySprite);
				button.setStyle("selectedUpSkin", emptySprite);
				button.setStyle("upSkin", emptySprite);
				button.setStyle("textPadding", 0);
				button.setStyle("focusRectPadding", 1);
				
				button.addEventListener("click", onOptionSelected);
			}
			
			_titleTextField = new TextField();
			_titleTextField.type = "dynamic";
			_titleTextField.autoSize = "left";
			_titleTextField.selectable = false;
			addChild(_titleTextField);
		}		
		
		override protected function draw():void {
			var startTimer:Number = getTimer();
			
			var help:DisplayObject = getDisplayObjectInstance(getStyleValue("helpContent"));
			var about:DisplayObject = getDisplayObjectInstance(getStyleValue("aboutContent"));
			
			_helpWindow.setStyle("content", help);
			_aboutWindow.setStyle("content", about);
			
			var windowMargin:Number = getStyleValue("dialogWindowMargin") as Number;
			var windowRanges = new Rectangle(windowMargin, height+windowMargin, stage.stageWidth-2*windowMargin, stage.stageHeight-height-2*windowMargin);
			
			_helpWindow.range = windowRanges;
			_aboutWindow.range = windowRanges;
			
			_helpWindow.drawNow();
			_aboutWindow.drawNow();
			
			_helpWindow.center();
			_aboutWindow.center();
			
			
			/*
			trace("windowMargin: "+windowMargin);
			trace("window ranges:");
			trace(" x: "+windowRanges.x);
			trace(" y: "+windowRanges.y);
			trace(" width: "+windowRanges.width);
			trace(" height: "+windowRanges.height);
			*/
			
			
			if (help==null) {
				if (contains(_helpButton)) removeChild(_helpButton);
			}
			else {
				if (!contains(_helpButton)) addChild(_helpButton);
			}
			
			if (about==null) {
				if (contains(_aboutButton)) removeChild(_aboutButton);
			}
			else {
				if (!contains(_aboutButton)) addChild(_aboutButton);
			}			
			
			if (_allowReset) addChild(_resetButton);
			else if (contains(_resetButton)) removeChild(_resetButton);
			
			var defaultTF:TextFormat = UIComponent.getStyleDefinition().defaultTextFormat as TextFormat;
			var preferredTitleTF:TextFormat = getStyleValue("titleTextFormat") as TextFormat;
			var titleTF:TextFormat = (preferredTitleTF!=null) ? preferredTitleTF : defaultTF;
			var preferredOptionsTF:TextFormat = getStyleValue("optionsTextFormat") as TextFormat;
			var optionsTF:TextFormat = (preferredOptionsTF!=null) ? preferredOptionsTF : defaultTF;
			var embed:Object = getStyleValue("embedFonts");
			
			_titleTextField.height = 0;
			_titleTextField.width = 0;
			_titleTextField.text = _title;
			_titleTextField.setTextFormat(titleTF);
			_titleTextField.defaultTextFormat = titleTF;
			if (embed!=null) _titleTextField.embedFonts = embed;
			
			var sideSpacingMultiplier:Number = getStyleValue("sideSpacingMultiplier") as Number;
			_titleTextField.y = Math.round((height - _titleTextField.textHeight)/2) - 2;
			var sideSpacing:Number = sideSpacingMultiplier*_titleTextField.y;
			_titleTextField.x = sideSpacing;
			
			var optionsSpacing:Number = getStyleValue("optionsSpacing") as Number;
			
			var buttonPosition:Number = width - sideSpacing;
			
			var w:Number;
			var h:Number;
			var underline:Sprite;
			var underlineColor:uint = (optionsTF.color!=null) ? (optionsTF.color as uint) : 0x000000;
			
			var buttonsList:Array = [_aboutButton, _helpButton, _resetButton];
			for each (var button in buttonsList) {
				if (!contains(button)) continue;
				
				button.setStyle("textFormat", optionsTF);
				button.setStyle("embedFonts", embed);
				
				// call drawNow so that the textWidth and textHeight properties will be consistent
				// with the just-set styles
				button.drawNow();
				
				w = button.textField.textWidth + 4;
				h = button.textField.textHeight + 4;
				button.setSize(w, h);
				
				buttonPosition -= w;
				button.x = buttonPosition;
				buttonPosition -= optionsSpacing;
				
				// now create the underline sprite for the button's over skin
				// (we give it an invisible fill so it can scale properly)
				underline = new Sprite();
				underline.graphics.lineStyle();
				underline.graphics.moveTo(0, 0);
				underline.graphics.beginFill(0xff0000, 0);
				underline.graphics.lineTo(0, h);
				underline.graphics.lineStyle(0, underlineColor);
				underline.graphics.lineTo(w, h);
				underline.graphics.lineStyle();
				underline.graphics.lineTo(w, 0);
				underline.graphics.lineTo(0, 0);
				underline.graphics.endFill();
				button.setStyle("overSkin", underline);
				
				button.drawNow();
			}
			
			_resetButton.y = _helpButton.y = _aboutButton.y = Math.round((height - h)/2);
			
			// update the background skin
			if (_background!=null) removeChild(_background);
			_background = getDisplayObjectInstance(getStyleValue("backgroundSkin"));
			if (_background!=null) {
				addChildAt(_background, 0);
				_background.width = width;
				_background.height = height;
			}
			
			// always call super.draw() at the end
			super.draw();
			
			//trace("draw: "+(getTimer()-startTimer));
		}		
		
		protected function onOptionSelected(evt:Event):void {
			switch (evt.target) {
				case _resetButton:
					dispatchEvent(new Event(NAAPTitleBar.RESET));
					_aboutWindow.visible = false;
					_helpWindow.visible = false;
					_helpWindow.center();
					_aboutWindow.center();
					break;
				case _helpButton:
					_aboutWindow.visible = false;
					_helpWindow.visible = true;
					break;
				case _aboutButton:
					_aboutWindow.visible = true;
					_helpWindow.visible = false;
					break;
			}
		}
		
		private static var defaultStyles:Object = {
			backgroundSkin: "NAAPTitleBar_backgroundSkin",
			
			dialogWindowMargin: 7,
			
			helpContent: null,
			aboutContent: null,
			
			embedFonts: true,
			
			sideSpacingMultiplier: 1.6,
			optionsSpacing: 13,
			
			titleTextFormat: new TextFormat("Verdana", 14),
			optionsTextFormat: new TextFormat("Verdana", 12),
			
			focusRectSkin: null,
			focusRectPadding: null,
			textFormat: null
		};
		
		public static function getStyleDefinition():Object { 
			return defaultStyles;
		}
		
		
		/*
		protected function setEmbedFont() {
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				textField.embedFonts = embed;
			}	
		}
		

		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES,InvalidationType.STATE)) {
				drawTextFormat();
				drawBackground();
				
				var embed:Object = getStyleValue('embedFonts');
				if (embed != null) {
					textField.embedFonts = embed;
				}
				
				invalidate(InvalidationType.SIZE,false);
			}
			if (isInvalid(InvalidationType.SIZE)) {
				drawLayout();
			}

			super.draw();
		}
*/

		
		[Inspectable(defaultValue="Title")]
		
		public function get title():String {
			return _title;			
		}
		
		public function set title(arg:String):void {
			_title = arg;
			_titleTextField.text = _title;
		}
									 
		
		[Inspectable(defaultValue="")]
		
		public function get allowReset():Boolean {
			return _allowReset;
		}
		
		public function set allowReset(arg:Boolean):void {
			_allowReset = arg;
		}
		
		
		[Inspectable(defaultValue="",name="helpContent (style)")]
		
		public function set helpContent(arg:String):void {
			clearStyle("helpContent");
			setStyle("helpContent", arg);
		}
		
		
		[Inspectable(defaultValue="",name="aboutContent (style)")]
		
		public function set aboutContent(arg:String):void {
			clearStyle("aboutContent");
			setStyle("aboutContent", arg);
		}		
		
		
	}
}
