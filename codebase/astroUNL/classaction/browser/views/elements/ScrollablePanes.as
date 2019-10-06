
package astroUNL.classaction.browser.views.elements {
	
	import astroUNL.utils.easing.CubicEaser;
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.geom.Matrix;
	
	
	
	public class ScrollablePanes extends Sprite {
		
		// onUpdate is called at the end of the update function, which means it is
		// called after the pane number changes; it is also called when all the panes
		// are cleared or a new pane is added (assuming the doUpdate argument of the
		// associated functions is not set to false)
		public static var ON_UPDATE:String = "onUpdate";
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _spacing:Number = 0;
		protected var _fadeDistance:Number = 0;
		
		protected var _panesList:Vector.<DisplayObject>;
		protected var _container:Sprite;
		protected var _containerMask:Shape;
		protected var _easeTimer:Timer;
		protected var _easer:CubicEaser;
		protected var _currPaneNum:Number = 0;
		protected var _paneNum:int = 0;
		
		public function ScrollablePanes(width:Number=0, height:Number=0, spacing:Number=0, fadeDistance:Number=0) {
			_panesList = new Vector.<DisplayObject>();
			_container = new Sprite();
			addChild(_container);
			_containerMask = new Shape();
			_containerMask.cacheAsBitmap = true;
			addChild(_containerMask);
			_easeTimer = new Timer(20);
			_easeTimer.addEventListener(TimerEvent.TIMER, onEaseTimer);
			_easer = new CubicEaser(0);
			_spacing = spacing;
			_fadeDistance = fadeDistance;
			setDimensions(width, height);
		}
		
		protected function onEaseTimer(evt:TimerEvent):void {
			var timeNow:Number = getTimer();
			if (timeNow>_easer.getTargetTime()) _easeTimer.stop();
			_currPaneNum = _easer.getValue(timeNow);
			update();
		}
		
		public function setPanesList(list:Vector.<DisplayObject>):void {
			clearAllPanes(false);
			for (var i:int = 0; i<list.length; i++) appendPane(list[i], false);
			update();
		}
		
		public function appendPane(content:DisplayObject, doUpdate:Boolean=true):void {
			var contentMask:Shape = new Shape();
			contentMask.graphics.beginFill(0x0000ff, 0.5);
			contentMask.graphics.drawRect(0, 0, _width, _height);
			contentMask.graphics.endFill();
			var pane:Sprite = new Sprite();
			pane.addChild(content);
			pane.addChild(contentMask);
			content.mask = contentMask;
			_container.addChild(pane);	
			if (doUpdate) update();
		}
		
		protected function clearAllPanes(doUpdate:Boolean=true):void {
			if (_easeTimer.running) _easeTimer.stop();
			_easer.init(0);
			_currPaneNum = 0;
			_paneNum = 0;
			_panesList.length = 0;
			removeChild(_container);
			_container = new Sprite();
			_container.cacheAsBitmap = true;
			_container.mask = _containerMask;
			addChild(_container);
			if (doUpdate) update();
		}
		
		public function update():void {
			var n:int = _container.numChildren;
			var num:Number = (_currPaneNum%n + n)%n;
			var num0:int = (Math.floor(num)%n + n)%n;
			var num1:int = (Math.ceil(num)%n + n)%n;
			var i:int;
			var pane:Sprite;
			for (i=0; i<n; i++) {
				pane = _container.getChildAt(i) as Sprite;
				if (i==num0) {
					pane.x = -(_width+_spacing)*(num-num0);
					pane.visible = true;
				}
				else if (i==num1) {
					pane.x = -(_width+_spacing)*(num-num0-1);
					pane.visible = true;
				}
				else pane.visible = false;				
			}
			dispatchEvent(new Event(ScrollablePanes.ON_UPDATE));
		}
		
		// currPaneNum is the pane currently display, this can be a decimal value
		//   in the range [0, n) during easing transitions, after easing, it equals paneNum
		// paneNum is the pane number currently shown, or, if easing is in effect,
		//   the target of the easing transition
		
		public function get currPaneNum():Number {
			var n:int = _container.numChildren;
			return (_currPaneNum%n + n)%n;
		}
		
		public function get paneNum():int {
			var n:int = _container.numChildren;
			return (_paneNum%n + n)%n;
		}
		
		public function set paneNum(num:int):void {
			setPaneNum(num, 0);
		}
		
		public function incrementPaneNum(delta:int, easeTime:Number=0):void {
			if (_container.numChildren>1) setPaneNum(_paneNum+delta, easeTime);
		}
		
		public function setPaneNum(num:int, easeTime:Number=0):void {
//			var n:int = _container.numChildren;
//			if (num<0) num = 0;
//			else if (num>=n) num = n;
			
			if (easeTime>0) {
				var timeNow:Number = getTimer();
				_paneNum = num;
				_easer.setTarget(timeNow, null, timeNow+easeTime, _paneNum);
				_easeTimer.start();				
			}
			else {
				if (_easeTimer.running) _easeTimer.stop();
				_currPaneNum = _paneNum = num;
				_easer.init(_currPaneNum);
			}
			
			update();
		}
		
		public function get numPanes():int {
			return _container.numChildren;			
		}
				
		public function setDimensions(width:Number, height:Number):void {
			_width = width;
			_height = height;
			redrawMasks();
			update();
		}
		
		override public function get width():Number {
			return _width;
		}
		
		override public function set width(arg:Number):void {
			_width = arg;
			redrawMasks();
			update();
		}
		
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(arg:Number):void {
			_height = arg;
			redrawMasks();
			update();
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(arg:Number):void {
			_spacing = arg;
			update();
		}
		
		public function get fadeDistance():Number {
			return _fadeDistance;
		}
		
		public function set fadeDistance(arg:Number):void {
			_fadeDistance = arg;
			redrawMasks();
			update();
		}
		
		protected function redrawMasks():void {
			with (_containerMask.graphics) {
				clear();
				
				beginFill(0x00ff00);
				drawRect(0, 0, _width, _height);
				endFill();
				
				if (_fadeDistance>0) {
					var m:Matrix = new Matrix();
					
					m.createGradientBox(_fadeDistance, _height, 0, -_fadeDistance, 0);
					moveTo(-_fadeDistance, 0);
					beginGradientFill("linear", [0x00ff00, 0x00ff00], [0, 1], [0, 0xff], m);
					drawRect(-_fadeDistance, 0, _fadeDistance, _height);
					endFill();
					
					m.createGradientBox(_fadeDistance, _height, 0, _width, 0);
					moveTo(_width, 0);
					beginGradientFill("linear", [0x00ff00, 0x00ff00], [1, 0], [0, 0xff], m);
					drawRect(_width, 0, _fadeDistance, _height);
					endFill();
				}
			}
			
			// 2/4/10: I don't know what the following bit of code is for, but I think it might
			// be a surviving piece of debugging/testing work			
//			for (var i:int = 0; i<_container.numChildren; i++) {
//				with (((_container.getChildAt(i) as Sprite).getChildAt(1) as Shape).graphics) {
//					clear();
//					beginFill(0xffffff, 0.8);
//					drawRect(0, 0, _width, _height);
//					endFill();
//				}
//			}
		}
		
	}
	
}

