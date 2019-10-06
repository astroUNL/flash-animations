
package astroUNL.classaction.browser.views.elements {
	
	
	import astroUNL.utils.easing.CubicEaser;
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	
	
	public class PopupWindow extends Sprite {
		
		protected var _closeButton:PopupCloseButton;
		protected var _expandButton:PopupExpandButton;
		
		protected var _title:TextField;
		protected var _width:Number;
		
		protected var _titlebar:Sprite;
		
		protected var _contentMask:Shape;
		
		protected var _perimeter:Shape;
		
		protected var _xEaser:CubicEaser;
		protected var _yEaser:CubicEaser;
		protected var _positionTimer:Timer;
		protected var _positionEaseDuration:Number = 250;
		
		protected var _expandEaser:CubicEaser;
		protected var _expandTimer:Timer;
		protected var _expandEaseDuration:Number = 250;


		public function PopupWindow(initTitle:String, initContent:DisplayObject=null) {
			
			_xEaser = new CubicEaser(0);
			_yEaser = new CubicEaser(0);
			_expandEaser = new CubicEaser(1);
			
			_positionTimer = new Timer(20);
			_positionTimer.addEventListener(TimerEvent.TIMER, onPositionTimer);
			
			_expandTimer = new Timer(20);
			_expandTimer.addEventListener(TimerEvent.TIMER, onExpandTimer);
			
			_titlebar = new Sprite();
			_titlebar.doubleClickEnabled = true;
			_titlebar.addEventListener(MouseEvent.DOUBLE_CLICK, toggleExpanded, false, 0, true);
			_titlebar.addEventListener(MouseEvent.MOUSE_DOWN, onTitlebarMouseDown, false, 0, true);
			addChild(_titlebar);
						
			_title = new TextField();
			_title.defaultTextFormat = new TextFormat("Verdana", 13, 0xffffff, true);
			_title.embedFonts = true;
			_title.multiline = false;
			_title.selectable = false;
			_title.mouseEnabled = false;
			_title.tabEnabled = false;
			_title.height = 0;
			_title.autoSize = "left";
			_title.text = "8";
			_title.height = _title.height; // ridiculous, but necessary
			_title.autoSize = "none";
			addChild(_title);
			
			_expandButton = new PopupExpandButton();
			_expandButton.addEventListener(MouseEvent.CLICK, toggleExpanded);
			addChild(_expandButton);
			
			_closeButton = new PopupCloseButton();
			_closeButton.buttonMode = true;
			_closeButton.addEventListener(MouseEvent.CLICK, close);
			addChild(_closeButton);
			
			_contentMask = new Shape();
			addChild(_contentMask);
			
			_perimeter = new Shape();
			addChild(_perimeter);
			
			title = initTitle;
			if (initContent!=null) content = initContent;
		}
		
		protected var _manager:PopupManager;
		
		public function get manager():PopupManager {
			return _manager;
		}
		
		public function set manager(arg:PopupManager):void {
			_manager = arg;
			keepInBounds();
		}
		
		public function moveTo(left:Number, top:Number, doAnimate:Boolean=true):void {
			// moves the popup to the specified upper left corner (including titlebar)
			
			var bounds:Rectangle = (_manager!=null && _manager.bounds!=null) ? _manager.bounds : new Rectangle(Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY, Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY);
			
			if (left<bounds.left) left = bounds.left;
			else if ((left+_width)>bounds.right) left = bounds.right - _width;
			
			if (top<bounds.top) top = bounds.top;
			else if ((top+_titlebarHeight)>bounds.bottom) top = bounds.bottom - _titlebarHeight;
			
			if (doAnimate) {
				var timeNow:Number = getTimer();
				_xEaser.setTarget(timeNow, null, timeNow+_positionEaseDuration, left);
				_yEaser.setTarget(timeNow, null, timeNow+_positionEaseDuration, top+_titlebarHeight);
				if (!_positionTimer.running) _positionTimer.start();
			}
			else {
				super.x = left;
				super.y = top + _titlebarHeight;
				_xEaser.init(super.x);
				_yEaser.init(super.y);
				if (_positionTimer.running) _positionTimer.stop();
			}
			
		}
		
		public function keepInBounds(doAnimate:Boolean=true):void {
			// checks if the current position is within bounds, and moves the popup if necessary
			
			if (_manager==null || _manager.bounds==null) return;
			
			var nx:Number = Number.NaN;
			var ny:Number = Number.NaN;
			
			if (x<_manager.bounds.left) nx = _manager.bounds.left;
			else if ((x+_width)>_manager.bounds.right) nx = _manager.bounds.right - _width;
			
			if ((y-_titlebarHeight)<_manager.bounds.top) ny = _manager.bounds.top + _titlebarHeight;
			else if (y>_manager.bounds.bottom) ny = _manager.bounds.bottom;
			
			var timeNow:Number = getTimer();
			
			if (!isNaN(nx)) {
				if (doAnimate) _xEaser.setTarget(timeNow, null, timeNow+_positionEaseDuration, nx);
				else _xEaser.init(nx);
			}
			
			if (!isNaN(ny)) {
				if (doAnimate) _yEaser.setTarget(timeNow, null, timeNow+_positionEaseDuration, ny);
				else _yEaser.init(ny);
			}
			
			if ((timeNow<_xEaser.targetTime || timeNow<_yEaser.targetTime) && !_positionTimer.running) _positionTimer.start();
			else if (timeNow>=_xEaser.targetTime && timeNow>=_yEaser.targetTime) {
				super.x = _xEaser.targetValue;
				super.y = _yEaser.targetValue;
				if (_positionTimer.running) _positionTimer.stop();
			}
		}
		
		protected function onPositionTimer(evt:TimerEvent):void {
			var timeNow:Number = getTimer();
			super.x = (timeNow<_xEaser.targetTime) ? _xEaser.getValue(timeNow) : _xEaser.targetValue;			
			super.y = (timeNow<_yEaser.targetTime) ? _yEaser.getValue(timeNow) : _yEaser.targetValue;
			if (timeNow>=_xEaser.targetTime && timeNow>=_yEaser.targetTime) _positionTimer.stop();
			evt.updateAfterEvent();
		}
		
		public function get isOpen():Boolean {
			return visible;
		}
		
		public function set isOpen(arg:Boolean):void {
			visible = arg;
		}
		
		public function open(evt:Event=null):void {
			visible = true;
		}
		
		public function close(evt:Event=null):void {
			visible = false;
		}
		
		protected function toggleExpanded(evt:Event=null):void {
			if (expandEnabled) expanded = !expanded;
		}
		
		public function get expanded():Boolean {
			return (_expandEaser.targetValue==1);
		}
		
		public function set expanded(arg:Boolean):void {
			var timeNow:Number = getTimer();
			var u:Number = (arg) ? 1 : 0;
			_expandEaser.setTarget(timeNow, null, timeNow+_expandEaseDuration, u);
			_expandButton.state = (arg) ? PopupExpandButton.CONTRACT : PopupExpandButton.EXPAND;
			if (!_expandTimer.running) _expandTimer.start();
		}
		
		protected function onExpandTimer(evt:TimerEvent):void {
			refreshExpansion();
			refreshPerimeter();
			if (getTimer()>=_expandEaser.targetTime) _expandTimer.stop();			
		}
		
		protected function refreshExpansion():void {
			var timeNow:Number = getTimer();
			var u:Number = (timeNow<_expandEaser.targetTime) ? _expandEaser.getValue(timeNow) : _expandEaser.targetValue;
			if (u<0) u = 0;
			else if (u>1) u = 1;
			_content.y = (u-1)*_content.height;
		}
		
		protected var _dragOffsetX:Number, _dragOffsetY:Number;
		
		protected function onTitlebarMouseDown(evt:MouseEvent):void {
			parent.setChildIndex(this, parent.numChildren-1);
			_dragOffsetX = parent.mouseX - x;
			_dragOffsetY = parent.mouseY - y;
			stage.addEventListener(MouseEvent.MOUSE_UP, onTitlebarMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onTitlebarMouseMove, false, 0, true);
		}
		
		protected function onTitlebarMouseMove(evt:MouseEvent):void {			
			moveTo(parent.mouseX-_dragOffsetX,  parent.mouseY-_dragOffsetY-_titlebarHeight, false);
			evt.updateAfterEvent();
		}
		
		protected function onTitlebarMouseUp(evt:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, onTitlebarMouseUp, false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onTitlebarMouseMove, false);
		}
		
		protected var _content:DisplayObject;
		
		public function get content():DisplayObject {
			return _content;
		}
		
		public function set content(arg:DisplayObject):void {
			if (_content!=null) {
				removeChild(_content);
				_content.removeEventListener(Event.RESIZE, onContentResized, false);
			}
			_content = arg;
			_content.addEventListener(Event.RESIZE, onContentResized, false, 0, true);
			_content.x = 0;
			_content.y = 0;			
			_content.mask = _contentMask;
			addChild(_content);
			swapChildren(_content, _perimeter);
			onContentResized();
		}
		
		protected function onContentResized(evt:Event=null):void {
			_width = _content.width;
			refreshTitlebar();
			refreshContentMask();
			refreshExpansion();
			refreshPerimeter();
			keepInBounds();
		}
		
		protected var _titlebarPadding:Number = 3;
		protected var _titlebarExtraPaddingForText:Number = 2;
		protected var _perimeterThickness:Number = 1;
		protected var _perimeterColor:uint = 0x3A4545;
		protected var _perimeterAlpha:Number = 1;
		protected var _titlebarColor:uint = 0x3A4545;
		protected var _titlebarHeight:Number;
		
		protected function refreshTitlebar():void {
			
			var cx:Number = _width - _titlebarPadding;
			if (_closeButton.visible) {
				_closeButton.x = cx - _closeButton.width/2;
				cx -= _closeButton.width + _titlebarPadding;
			}
			if (_expandButton.visible) {
				_expandButton.x = cx - _expandButton.width/2;
				cx -= _expandButton.width + _titlebarPadding;
			}
			
			_title.x = _titlebarPadding + _titlebarExtraPaddingForText;
			_title.width = cx - _titlebarPadding - _titlebarExtraPaddingForText;
			
			_titlebarHeight = _title.height + 2*_titlebarPadding;
			
			_expandButton.y = _closeButton.y = -_titlebarHeight/2;
			
			_title.y = -_title.height - _titlebarPadding;
			
			_titlebar.graphics.clear();
			
			_titlebar.graphics.beginFill(_titlebarColor);
			_titlebar.graphics.drawRect(0, -_titlebarHeight, _width, _titlebarHeight);
			_titlebar.graphics.endFill();
		}
		
		protected function refreshContentMask():void {
			_contentMask.graphics.clear();
			_contentMask.graphics.beginFill(0xff0000);
			_contentMask.graphics.drawRect(0, 0, _width, _content.height);
			_contentMask.graphics.endFill();
		}
		
		protected function refreshPerimeter():void {
			_perimeter.graphics.clear();
			_perimeter.graphics.lineStyle(_perimeterThickness, _perimeterColor, _perimeterAlpha);
			_perimeter.graphics.drawRect(0, -_titlebarHeight, _width, _content.height+_titlebarHeight+_content.y);
		}
		
		public function get expandEnabled():Boolean {
			return _expandButton.visible;
		}
		
		public function set expandEnabled(arg:Boolean):void {
			_expandButton.visible = arg;
			refreshTitlebar();
		}
		
		public function get closeEnabled():Boolean {
			return _closeButton.visible;			
		}
		
		public function set closeEnabled(arg:Boolean):void {
			_closeButton.visible = arg;
			refreshTitlebar();
		}
		
		public function get titlebarHeight():Number {
			return _titlebarHeight;
		}
		
		public function get title():String {
			return _title.text;
		}
		
		public function set title(arg:String):void {
			_title.text = arg;
		}
		
		override public function get height():Number {
			return _content.height + _titlebarHeight;			
		}
		
		override public function set height(arg:Number):void {
			//
		}
		
		override public function get width():Number {
			return _width;
		}
		
		override public function set width(arg:Number):void {
			//
		}
		
		override public function set x(arg:Number):void {
			//
		}
		
		override public function set y(arg:Number):void {
			//
		}
		
	}	
}
