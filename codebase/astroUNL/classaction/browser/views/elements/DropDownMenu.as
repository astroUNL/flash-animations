
package astroUNL.classaction.browser.views.elements {
	
	import astroUNL.utils.easing.CubicEaser;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	public class DropDownMenu extends Sprite {
		
		protected var _background:Sprite;
		protected var _selections:ScrollableLayoutPanes;		
		
		protected var _menuWidth:Number;
		protected var _menuHeight:Number;
		
		protected var _perimeterPadding:Number = 7;
		protected var _selectionFormat:TextFormat;
		
		protected var _openEaser:CubicEaser;
		protected var _openTimer:Timer;
		protected var _openEaseDuration:Number = 250;
		
		public function DropDownMenu(width:Number) {
			
			_menuWidth = width;
			_menuHeight = 0;
			
			_openEaser = new CubicEaser(0);
			
			_openTimer = new Timer(10);
			_openTimer.addEventListener(TimerEvent.TIMER, onOpenTimer);
			
			_background = new Sprite();
			addChild(_background);
			
			_selectionFormat = new TextFormat("Verdana", 14, 0xffffff);
			
			_selections = new ScrollableLayoutPanes(_menuWidth, 1600, 0, 0, {numColumns: 1,
																			 columnSpacing: 0,
																			 leftMargin: 1.5*_perimeterPadding,
																			 minLeftOver: _perimeterPadding,
																			 topMargin: _perimeterPadding,
																			 bottomMargin: 0});
			addChild(_selections);			
		}
		
		public function get isOpen():Boolean {
			return _openEaser.targetValue==1;
		}
		
		public function set isOpen(arg:Boolean):void {
			var newTarget:Number = Number.NaN;
			if (_openEaser.targetValue==1 && !arg) newTarget = 0;
			else if (_openEaser.targetValue==0 && arg) newTarget = 1;
			if (!isNaN(newTarget)) {
				var timeNow:Number = getTimer();
				_openEaser.setTarget(timeNow, null, timeNow+_openEaseDuration, newTarget);
				_openTimer.start();
			}			
		}
		
		protected function onOpenTimer(evt:TimerEvent):void {
			refreshOpen();
			if (getTimer()>_openEaser.targetTime) _openTimer.stop();
			evt.updateAfterEvent();
		}
		
		protected function refreshOpen():void {
			var timeNow:Number = getTimer();
			var u:Number = (timeNow<_openEaser.targetTime) ? _openEaser.getValue(timeNow) : _openEaser.targetValue;
			if (u<0) u = 0;
			else if (u>1) u = 1;
			_selections.y = _background.y = (u-1)*(_menuHeight+5);
		}
		
		public function open():void {
			isOpen = true;			
		}
		
		public function close():void {
			isOpen = false;
		}
		
		public function addSelection(text:String):void {
			var ct:ClickableText = new ClickableText(text, text, _selectionFormat, _menuWidth);
			ct.addEventListener(ClickableText.ON_CLICK, onSelectionClicked);
			_selections.addContent(ct);
			_menuHeight = _selections.cursorY + _perimeterPadding;
			redrawBackground();
			refreshOpen();
		}
		
		public function get selection():String {
			return _selection;
		}
		
		protected var _selection:String;
		
		protected function onSelectionClicked(evt:Event):void {
			_selection = (evt.target as ClickableText).data as String;
			dispatchEvent(new Event(Event.SELECT));
		}
		
		protected var _borderThickness:Number = 1;
		protected var _borderColor:uint = 0x3A4545;
		protected var _borderAlpha:Number = 1;
		
		protected var _backgroundColor:uint = 0x272D2E;
		protected var _backgroundAlpha:Number = 1;
		
		protected function redrawBackground():void {
			
			var littleExtra:Number = 2;
			
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_background.graphics.drawRect(0, -littleExtra, _menuWidth, _menuHeight+littleExtra);
			_background.graphics.endFill();
			
			_background.graphics.lineStyle(_borderThickness, _borderColor, _borderAlpha);
			_background.graphics.moveTo(0, -littleExtra);
			_background.graphics.lineTo(0, _menuHeight);
			_background.graphics.lineTo(_menuWidth, _menuHeight);
			_background.graphics.lineTo(_menuWidth, -littleExtra);
		}
		
	}
}
