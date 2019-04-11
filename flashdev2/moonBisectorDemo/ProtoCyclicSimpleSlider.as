
// search for "cyclic modification"

package {
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.TextFormat;
	import flash.events.FocusEvent;
	
	public class ProtoCyclicSimpleSlider extends MovieClip {
		
		public var _controller:ProtoSliderLogic;
		protected var _active:Boolean = false;
		protected var _grabberXOffset:Number;
		protected var _barTimeLast:Number;
		protected var _barWaitTime:Number;
		protected var _continuousChangeDelay:Number = 500;
		protected var _continuousChangeRate:Number = 50/1000;		
		
		
		public function ProtoCyclicSimpleSlider() {
			
			stop();
			
			valueField.restrict = "0-9.Ee+\\-";
			
			_controller = new ProtoSliderLogic({scalingMode: "linear", valueFormat: "fixed digits", valueDigits: 1, minValue: 1, maxValue: 10, minParameter: 0, maxParameter: 120, value: 5});
			
			updateSync();
						
			grabberMC.addEventListener("mouseDown", grabberOnMouseDown);
			barMC.addEventListener("mouseDown", barOnMouseDown);
			
			barMC.tabEnabled = false;
			barMC.useHandCursor = false;
			
			valueField.embedFonts = true;
			valueField.addEventListener("change", valueFieldOnChange);
			valueField.addEventListener("focusOut", valueFieldOnFocusOut);
			
			barMC.focusRect = false;
			grabberMC.focusRect = false;
		}	
		
		public function setScalingMode(mode:String):void {
			_controller.setScalingMode(mode);
			updateSync();
		}
		
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
		
		public function setValueRange(minValue:*, maxValue:*):void {
			_controller.setValueAndParameterRanges(minValue, maxValue, 0, 120);
			updateSync();			
		}
		
		public function setRangeType(type:String, values:Array=null):void {
			_controller.setRangeType(type, values);
			updateSync();			
		}
		
		public function getValueIndex():int {
			// useful only for discrete sets
			return _controller.getClosestIndex();
		}
			
		public function valueFieldOnMouseDown(...ignored):void {
			setActiveState(false);
			setValue(parseFloat(valueField.text), true);			
		}
		
		public function valueFieldOnChange(...ignored):void {
			setActiveState(true);
		}
		
		public function valueFieldOnFocusOut(evt:FocusEvent):void {
			if (_active) {
				setActiveState(false);
				if (stage.focus==grabberMC || stage.focus==barMC) updateSync();					
				else setValue(parseFloat(valueField.text), true);
			}
		}
		
		public function valueFieldOnKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.ENTER) {
				setActiveState(false);
				setValue(parseFloat(valueField.text), true);
			}	
		}
		
		public function barOnMouseDown(...ignored):void {
			stage.focus = barMC;
			
			var mValue:Number = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX)).value;
			
			if (mValue<_controller.value) incrementValue(-1, true);
			else if (mValue>_controller.value) incrementValue(1, true);

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
			_barTimeLast = timeNow;
		}
		
		public function grabberOnMouseDown(...ignored):void {
			stage.focus = grabberMC;
			_grabberXOffset = mouseX - grabberMC.x;
			stage.addEventListener("mouseUp", grabberOnMouseUp);
			stage.addEventListener("mouseMove", grabberOnMouseMove);
		}
		
		public function grabberOnMouseUp(...ignored):void {
			stage.removeEventListener("mouseUp", grabberOnMouseUp);
			stage.removeEventListener("mouseMove", grabberOnMouseMove);
		}
		
		public function grabberOnMouseMove(evt:MouseEvent):void {
			
			// cyclic modification
//			var vObj:Object = _controller.getValueObjectFromValue(_controller.getValueFromParameter(mouseX-_grabberXOffset));
			var v:Number = _controller.getValueFromParameter(mouseX-_grabberXOffset);
			var r:Number = _controller._maxV - _controller._minV;
			v = _controller._minV + ((v - _controller._minV)%r + r)%r;
			var vObj:Object = _controller.getValueObjectFromValue(v);

			if (vObj.value!=_controller.value) setValueByValueObject(vObj, true);
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
			valueField.text = _controller.valueString;
		}
		
		public function setValue(arg:Number, doEvent:Boolean=false):void {
			if (!isNaN(arg) && isFinite(arg)) _controller.value = arg;
			updateSync();
			if (doEvent) dispatchEvent(new Event("sliderChange"));
		}
		
		public function incrementValue(ticks:int, doEvent:Boolean=false):void {
			_controller.incrementValue(ticks);
			updateSync();
			if (doEvent) dispatchEvent(new Event("sliderChange"));
		}		
		
		public function setValueByValueObject(vObj:Object, doEvent:Boolean=false):void {
			_controller.setValueByValueObject(vObj);
			updateSync();
			if (doEvent) dispatchEvent(new Event("sliderChange"));
		}
		
		public function setEnabled(arg:Boolean):void {
			
			setActiveState(false);
			
			var tf:TextFormat = valueField.defaultTextFormat;
			
			if (arg) {
				valueField.selectable = true;
				gotoAndStop(1);
				tf.color = 0x000000;
				grabberMC.addEventListener("mouseDown", grabberOnMouseDown);
				barMC.addEventListener("mouseDown", barOnMouseDown);
			}
			else {
				valueField.selectable = false;
				gotoAndStop(3);				
				tf.color = 0x363636;
				grabberMC.removeEventListener("mouseDown", grabberOnMouseDown);
				barMC.removeEventListener("mouseDown", barOnMouseDown);
			}
			
			valueField.setTextFormat(tf);
			valueField.defaultTextFormat = tf;
		}
		
		protected function setActiveState(state:Boolean):void {
			// the active state means the text field is being actively edited, and the
			//   displayed value may not correspond to the slider value
			// in the inactive state the text field displays the slider value
			if (state==_active) {
				//trace("WARNING, redundant setting of active state");
				return;
			}
			_active = state;
			var tf:TextFormat = valueField.defaultTextFormat;
			if (_active) {
				gotoAndStop(2);
				tf.italic = true;
				valueField.addEventListener("keyDown", valueFieldOnKeyDown);
				valueField.removeEventListener("change", valueFieldOnChange);
				stage.addEventListener("mouseDown", valueFieldOnMouseDown);	
			}
			else {
				gotoAndStop(1);
				tf.italic = false;
				valueField.removeEventListener("keyDown", valueFieldOnKeyDown);
				valueField.addEventListener("change", valueFieldOnChange);
				stage.removeEventListener("mouseDown", valueFieldOnMouseDown);	
			}
			valueField.setTextFormat(tf);
			valueField.defaultTextFormat = tf;
		}
		
	}	
}

