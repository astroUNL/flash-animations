
package {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.TextFormat;
	import flash.events.FocusEvent;
	
	import astroUNL.utils.PhaseDisc;
	
	
	public class ProtoSimpleSliderMoonPhase extends MovieClip {
		
		public var _controller:ProtoSliderLogicCyclic;
		protected var _grabberXOffset:Number;
		protected var _barTimeLast:Number;
		protected var _barWaitTime:Number;
		protected var _continuousChangeDelay:Number = 500;
		protected var _continuousChangeRate:Number = 50/1000;		
		
		protected const _maxParam:Number = 200;
		protected const _minValue:Number = 0;
		protected const _maxValue:Number = 2*Math.PI;
		
		protected var _focusIndicator:NAAP_focusRectSkin;
		
		
		public function ProtoSimpleSliderMoonPhase() {
			
			stop();
			
			focusIndicator.visible = false;
			
			_controller = new ProtoSliderLogicCyclic({scalingMode: "linear", valueFormat: "fixed digits", valueDigits: 2, minValue: _minValue, maxValue: _maxValue, minParameter: 0, maxParameter: _maxParam, value: 0});
			
			updateSync();
			
			grabberMC.addEventListener("mouseDown", grabberOnMouseDown);
			barMC.addEventListener("mouseDown", barOnMouseDown);
			
			tabEnabled = true;
			mouseEnabled = true;
			
			tabChildren = false;
			
			barMC.tabEnabled = false;
			grabberMC.tabEnabled = false;
				
			focusRect = false;
			barMC.focusRect = false;
			grabberMC.focusRect = false;
			
			
						
			
			// add the moon phase icons
			var i:int;
			var initObj:Object = {radius: 4.5, lightColor: 0xb8b8b8, darkColor: 0x000000};
			var discY:Number = 19;
			var angle:Number;
			var disc:PhaseDisc;
			for (i=0; i<8; i++) {
				angle = (i/8)*2*Math.PI;
				initObj.phaseAngle = Math.PI - angle;
				disc = new PhaseDisc(initObj);
				disc.x = _controller.getParameterFromValue(angle);
				disc.y = discY;
				disc.buttonMode = true;
				disc.tabEnabled = false;
				disc.addEventListener(MouseEvent.CLICK, onPhaseDiscClicked);
				addChild(disc);
			}
			angle = 2*Math.PI;
			initObj.phaseAngle = Math.PI - angle;
			disc = new PhaseDisc(initObj);
			disc.x = _maxParam;
			disc.y = discY;
			disc.buttonMode = true;
			disc.tabEnabled = false;
			disc.addEventListener(MouseEvent.CLICK, onPhaseDiscClicked);
			addChild(disc);
			
			addEventListener(FocusEvent.FOCUS_IN, onFocusInFunc);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOutFunc);
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChangeFunc);
			addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onMouseFocusChangeFunc);			
		}	
		
		protected function onMouseFocusChangeFunc(evt:FocusEvent):void {
			if (stage.focus==this) stage.focus = null;
		}
		
		protected function onKeyFocusChangeFunc(evt:FocusEvent):void {
			if (evt.keyCode==Keyboard.LEFT || evt.keyCode==Keyboard.RIGHT 
					|| evt.keyCode==Keyboard.UP || evt.keyCode==Keyboard.DOWN) evt.preventDefault();
		}
		
		protected function onFocusInFunc(evt:FocusEvent):void {
			focusIndicator.visible = true;
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc, false, 0, true);
		}
		
		protected function onFocusOutFunc(evt:FocusEvent):void {
			focusIndicator.visible = false;
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc, false);
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.LEFT || evt.keyCode==Keyboard.DOWN) {
				if (evt.shiftKey) setValue(_snapInterval*(Math.round(_controller.value/_snapInterval) - 1), true);
				else incrementValue(-1, true);
			}
			else if (evt.keyCode==Keyboard.RIGHT || evt.keyCode==Keyboard.UP) {
				if (evt.shiftKey) setValue(_snapInterval*(Math.round(_controller.value/_snapInterval) + 1), true);
				else incrementValue(1, true);
			}
		}
		
		protected var _snapInterval:Number = 2*Math.PI/8;
		
		
		protected function onPhaseDiscClicked(evt:MouseEvent):void {
			setValue(Math.PI-(evt.target as PhaseDisc).phaseAngle, true);
		}
		
//		public function setScalingMode(mode:String):void {
//			_controller.setScalingMode(mode);
//			updateSync();
//		}
		
		public function setValueFormat(mode:String, digits:int):void {
			_controller.setValueFormat(mode, digits);
			updateSync();
		}
		
		public function get min():Number {
			return _controller._minV;			
		}
		
		public function get max():Number {
			return _controller._maxV;			
		}
		
//		public function setValueRange(minValue:*, maxValue:*):void {
//			_controller.setValueAndParameterRanges(minValue, maxValue, 0, _maxParam);
//			updateSync();			
//		}
		
		public function getValueIndex():int {
			// useful only for discrete sets
			return _controller.getClosestIndex();
		}
		
		
		public function barOnMouseDown(...ignored):void {			
			if (_controller._cyclic && (mouseX<=_controller._minP || mouseX>=_controller._maxP)) {
				if (mouseX<=_controller._minP) incrementValue(-1, true);
				else incrementValue(1, true);
			}
			else {
				var mValue:Number = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX)).value;
				if (mValue<_controller.value) incrementValue(-1, true);
				else if (mValue>_controller.value) incrementValue(1, true);
			}
			
			_barTimeLast = getTimer();
			_barWaitTime = _barTimeLast + _continuousChangeDelay;
			
			stage.addEventListener("enterFrame", barOnEnterFrame);
			stage.addEventListener("mouseUp", barOnMouseUp);
		}
		
		public function barOnMouseUp(...ignored):void {
			stage.removeEventListener("enterFrame", barOnEnterFrame);
			stage.removeEventListener("mouseUp", barOnMouseUp);
		}
		
		public function barOnEnterFrame(...ignored):void {
			var timeNow:Number = getTimer();
			if (timeNow>_barWaitTime) {
				var ticks:int = _continuousChangeRate*(timeNow-_barTimeLast);
				
				if (_controller._cyclic && (mouseX<=_controller._minP || mouseX>=_controller._maxP)) {
					if (mouseX<=_controller._minP) incrementValue(-ticks, true);
					else incrementValue(ticks, true);
				}
				else {
					var mValueObj:Object = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX));
					var nValueObj:Object;
					if (mValueObj.value<_controller.value) {
						nValueObj = _controller.getIncrementedValueObject(null, -ticks);
						if (nValueObj.value<=mValueObj.value) setValueByValueObject(mValueObj, true);
						else setValueByValueObject(nValueObj, true);
					}
					else if (mValueObj.value>_controller.value) {
						nValueObj = _controller.getIncrementedValueObject(null, ticks);
						if (nValueObj.value>=mValueObj.value) setValueByValueObject(mValueObj, true);
						else setValueByValueObject(nValueObj, true);
					}
				}
			}		
			_barTimeLast = timeNow;
		}
		
		public function grabberOnMouseDown(...ignored):void {
			_grabberXOffset = mouseX - grabberMC.x;
			stage.addEventListener("mouseUp", grabberOnMouseUp);
			stage.addEventListener("mouseMove", grabberOnMouseMove);
		}
		
		public function grabberOnMouseUp(...ignored):void {
			stage.removeEventListener("mouseUp", grabberOnMouseUp);
			stage.removeEventListener("mouseMove", grabberOnMouseMove);
		}
				
		public function grabberOnMouseMove(evt:MouseEvent):void {
			var vObj:Object;
			if (evt.shiftKey) {
				// not using offset when snapping
				vObj = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX));
				var snapValue:Number = _snapInterval*Math.round(vObj.value/_snapInterval);
				if (snapValue!=_controller.value) setValue(snapValue, true);
			}
			else {
				vObj = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX-_grabberXOffset));
				if (vObj.value!=_controller.value) setValueByValueObject(vObj, true);
			}
			evt.updateAfterEvent();
		}
		
		public function get value():Number {
			return _controller.value;			
		}
		
		public function set value(arg:Number):void {
			if (!isNaN(arg) && isFinite(arg)) _controller.value = arg;
			updateSync();			
		}
		
		public function updateSync():void {
//			trace("updateSync!");
//			trace(" parameter: "+_controller.parameter);
//			trace(" value: "+_controller.value);
//			trace(" valueString: "+_controller.valueString);
			
			grabberMC.x = _controller.parameter;
		}
		
		public function setValue(arg:Number, doEvent:Boolean=false):void {
			if (!isNaN(arg) && isFinite(arg)) _controller.value = arg;
			updateSync();
			if (doEvent) dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function incrementValue(ticks:int, doEvent:Boolean=false):void {
			_controller.incrementValue(ticks);
			updateSync();
			if (doEvent) dispatchEvent(new Event(Event.CHANGE));
		}		
		
		public function setValueByValueObject(vObj:Object, doEvent:Boolean=false):void {
			_controller.setValueByValueObject(vObj);
			updateSync();
			if (doEvent) dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function setEnabled(arg:Boolean):void {			
			if (arg) {
				tabEnabled = true;
				mouseEnabled = true;
				mouseChildren = true;
				grabberMC.addEventListener("mouseDown", grabberOnMouseDown);
				barMC.addEventListener("mouseDown", barOnMouseDown);
			}
			else {
				if (stage.focus==this) stage.focus = null;
				tabEnabled = false;
				mouseEnabled = false;
				mouseChildren = false;
				grabberMC.removeEventListener("mouseDown", grabberOnMouseDown);
				barMC.removeEventListener("mouseDown", barOnMouseDown);
			}			
		}
		
	}	
}

