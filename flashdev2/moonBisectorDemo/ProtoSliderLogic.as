package {
	
	public class ProtoSliderLogic {
		
		public var _sMode:int;
		public var _pMode:int;
		public var _rMode:int = 0;
		public var _digs:int;
		public var _lowerSigLimit:int;
		public var _upperSigLimit:int;
		public var _ticksPerMag:int;
		public var _minIncrement:Number;
		
		public var _minV:Number;
		public var _maxV:Number;
		public var _minP:Number;
		public var _maxP:Number;
		
		public var _logMinV:Number;
		public var _scale:Number;
		
		public var _valueObject:Object;
		
		public var _finiteSet:Array;
		
		public var refresh:Function;
		
		function ProtoSliderLogic(initObject:Object) {
			refresh = function():void {};
			
			var s:Boolean;
			
			s = setScalingMode(initObject.scalingMode);
			if (!s) setScalingMode("linear");
			
			s = setValueFormat(initObject.valueFormat, initObject.valueDigits);
			if (!s) setValueFormat("fixed digits", 1);
			
			s = setValueAndParameterRanges(initObject.minValue, initObject.maxValue, initObject.minParameter, initObject.maxParameter);
			if (!s) setValueAndParameterRanges(1, 100, 0, 1);
			
			refresh = refreshFunc;
			
			var initValue:Number = Number(initObject.value);
			if (isFinite(initValue) && !isNaN(initValue)) value = initValue;
			else value = _minV+(_maxV-_minV)/2;
		}
		
		public function setScalingMode(mode:String):Boolean {
			var success:Boolean = false;
			if (mode=="linear") {
				_sMode = 0;
				success = true;
			}
			else if (mode=="logarithmic") {
				_sMode = 1;
				success = true;
			}
			if (success) {
				calculateScale();
				refresh();
			}
			return success;
		}
		
		public function setValueFormat(mode:String, digits:int):Boolean {
			var success:Boolean = false;
			var x:int;
			if (mode=="significant digits") {
				_pMode = 0;
				x = Math.abs(digits);
				if (x==0) x = 1;
				_digs = x;
				_lowerSigLimit = Math.pow(10, x-1);
				_upperSigLimit = Math.pow(10, x);
				_ticksPerMag = 9*_lowerSigLimit;
				success = true;
			}
			else if (mode=="fixed digits") {
				_pMode = 1;
				x = digits;
				_digs = x;
				_minIncrement = Math.pow(10, -x);
				success = true;
			}
			if (success) refresh();
			return success;
		}
		
		
		public function setRangeType(type:String, values:Array=null):void {
			if (type=="continuous") {
				_rMode = 0;
				
			}
			else if (type=="finite set") {
				_rMode = 1;
				
				_finiteSet = [];
				for (var i:int = 0; i<values.length; i++) _finiteSet.push(values[i]);
				
				_finiteSet.sort(Array.NUMERIC);
				
				_minV = _finiteSet[0];
				_maxV = _finiteSet[_finiteSet.length-1];
				
				calculateScale();				
			}
			
			refresh();
		}
				
		public function setValueAndParameterRanges(minValue:*=null, maxValue:*=null, minParameter:*=null, maxParameter:*=null):Boolean {
			if (!(minValue is Number)) minValue = _minV;
			if (!(maxValue is Number)) maxValue = _maxV;
			if (!(minParameter is Number)) minParameter = _minP;
			if (!(maxParameter is Number)) maxParameter = _maxP;
			
			if (minValue>=maxValue || minParameter>=maxParameter ||
				isNaN(minValue) || isNaN(maxValue) || isNaN(minParameter) || isNaN(maxParameter) ||
				!isFinite(minValue) || !isFinite(maxValue) || !isFinite(minParameter) || !isFinite(maxParameter)) return false;
			
			_minV = minValue;
			_maxV = maxValue;
			_minP = minParameter;
			_maxP = maxParameter;
			
			calculateScale();
			refresh();
			
			return true;
		}
						
		public function get parameter():Number {
			return getParameterFromValue(_valueObject.value);
		}
		
		public function set parameter(arg:Number):void {
			value = getValueFromParameter(arg);
		}
		
		public function get value():Number {
			return _valueObject.value;
		}
		
		public function set value(arg:Number):void {
			setValueByValueObject(getValueObjectFromValue(arg));
		}		
		
		public function setValueByValueObject(valueObj:Object):void {
			_valueObject = valueObj;
		}
		
		public function incrementValue(numTicks:int):void {
			var vObj:Object = getIncrementedValueObject(null, numTicks);
			setValueByValueObject(vObj);
		}

		public function get valueString():String {
			return getValueStringFromValueObject(_valueObject);
		}

		public function getValueStringFromValueObject(valueObj:Object):String {
			// this function returns the string form of the value passed to it based on the
			// current precision settings
			var f:int;
			if (_pMode==0) f = _digs - valueObj.mag - 1;
			else f = _digs;
			if (f>0) return valueObj.value.toFixed(f);
			else return String(Math.round(valueObj.value));
		}

		public function getClosestIndex():int {
			if (_valueObject.closestIndex is int) return _valueObject.closestIndex;
			else return -1;
		}
		
		public function getValueObjectFromValue(x:Number):Object {
			// this function takes a number, x, and returns the closest valid slider value based on the current
			// settings (precision and range); this function returns an object with a value property, as well
			// as mag and sig properties when in the significant digits mode
			var vObj:Object = {};
			if (_rMode==0) {
				// continuous (ordinary) mode
				// restrict the value to the range
				
				if (x<_minV) x = _minV;
				else if (x>_maxV) x = _maxV;
				
				
			}
			else {
				// discrete set mode
				// restrict the value to one of the members of the set
				
				var delta:Number;
				var closestValue:Number = Number.NaN;
				var closestIndex:int = 0;
				var minDelta:Number = Number.POSITIVE_INFINITY;
				for (var i:int = 0; i<_finiteSet.length; i++) {
					delta = Math.abs(_finiteSet[i] - x);
					if (delta<minDelta) {
						closestValue = _finiteSet[i];
						closestIndex = i;
						minDelta = delta;						
					}					
				}
				
				x = closestValue;
				
				vObj.closestIndex = closestIndex;
			}
			
			var mag:int, sig:int;
			if (_pMode==0) {
				mag = Math.floor(Math.log(x)/Math.LN10);
				sig = Math.round(x*_lowerSigLimit/Math.pow(10, mag));
				if (sig>=_upperSigLimit) {
					sig = _lowerSigLimit;
					mag++;
				}
				vObj.value = (sig/_lowerSigLimit)*Math.pow(10, mag);
				vObj.mag = mag;
				vObj.sig = sig;
			}
			else {
				vObj.value = _minIncrement*Math.round(x/_minIncrement);
			}
			
			return vObj;
		}
		
		public function getIncrementedValueObject(valueObj:*, numTicks:int):Object {
			// this function increments a value (defined by a value object) by the given number of ticks based
			// on the current settings (precision and range); a 'tick' is the minimum increment that can
			// be shown given the precision and value (e.g. in significant digits mode with the value 10.0 a 
			// positive tick would take the value to 10.1 while a negative tick would take it to 9.99);
			// what the function returns is an object with a value property, as well as mag and sig properties
			// when in significant digits mode; if the argument valueObj is null then the current value is used,
			// but note that this function does not change anything
			
			if (!(valueObj is Object)) valueObj = _valueObject;
				
			var vObj:Object = {};
			
			if (_rMode==0) {
				// continuous (ordinary) mode
				
				if (_pMode==0) {
					// significant digits mode
					
					var fracMags:Number = numTicks/_ticksPerMag;
					var deltaMag:int;
					var deltaSig:int;
					
					if (fracMags>=1) {
						deltaMag = Math.floor(fracMags);
						deltaSig = numTicks - deltaMag*_ticksPerMag;
					}
					else if (fracMags<=-1) {
						deltaMag = Math.ceil(fracMags);
						deltaSig = numTicks - deltaMag*_ticksPerMag;
					}
					else {
						deltaMag = 0;
						deltaSig = numTicks;
					}
					
					var newSig:int = valueObj.sig + deltaSig;
					var newMag:int = valueObj.mag + deltaMag;
					
					if (newSig>=_upperSigLimit) {
						newSig = newSig - _ticksPerMag;
						newMag++;
					}
					else if (newSig<_lowerSigLimit) {
						newSig = newSig + _ticksPerMag;
						newMag--;
					}
					
					vObj.value = (newSig/_lowerSigLimit)*Math.pow(10, newMag);
					vObj.sig = newSig;
					vObj.mag = newMag;
				}
				else {
					// fixed decimal places mode
					vObj.value = _minIncrement*Math.round(numTicks+(valueObj.value/_minIncrement));
				}
				
				if (vObj.value<_minV) vObj = getValueObjectFromValue(_minV);
				else if (vObj.value>_maxV) vObj = getValueObjectFromValue(_maxV);
				
			}
			else if (_rMode==1) {
				// discrete set mode
				
				var i:int;
				var delta:Number;
				var closestIndex:int = 0;
				var minDelta:Number = Number.POSITIVE_INFINITY;
				for (i=0; i<_finiteSet.length; i++) {
					delta = Math.abs(_finiteSet[i] - valueObj.value);
					if (delta<minDelta) {
						closestIndex = i;
						minDelta = delta;
					}
				}
				
				i = closestIndex + numTicks;
				if (i<0) i = 0;
				else if (i>=_finiteSet.length) i = _finiteSet.length - 1;
				
				vObj = getValueObjectFromValue(_finiteSet[i]);
			}
			
			return vObj;
		}
		
		public function calculateScale():void {
			if (_sMode==0) {
				_scale = (_maxV - _minV)/(_maxP - _minP);
			}
			else {
				_logMinV = Math.log(_minV);
				_scale = (Math.log(_maxV) - _logMinV)/(_maxP - _minP);
			}
		}		
		
		public function getValueFromParameter(parameter:Number):Number {
			if (_sMode==0) return (parameter - _minP)*_scale + _minV;
			else return Math.exp((parameter - _minP)*_scale + _logMinV);
		}
		
		public function getParameterFromValue(value:Number):Number {
			if (_sMode==0) return _minP + ((value - _minV)/_scale);
			else return _minP + ((Math.log(value) - _logMinV)/_scale);
		}
		
		public function refreshFunc():void {
			value = _valueObject.value;	
		}
		
		public function toString():String {
			var str:String = "ProtoSliderLogic instance:\n";
			str += " _sMode: "+String(_sMode)+"\n";
			str += " _pMode: "+String(_pMode)+"\n";
			str += " _rMode: "+String(_rMode)+"\n";
			str += " _digs: "+String(_digs)+"\n";
			str += " _lowerSigLimit: "+String(_lowerSigLimit)+"\n";
			str += " _upperSigLimit: "+String(_upperSigLimit)+"\n";
			str += " _ticksPerMag: "+String(_ticksPerMag)+"\n";
			str += " _minIncrement: "+String(_minIncrement)+"\n";
			str += " _minV: "+String(_minV)+"\n";
			str += " _maxV: "+String(_maxV)+"\n";
			str += " _minP: "+String(_minP)+"\n";
			str += " _maxP: "+String(_maxP)+"\n";
			str += " _logMinV: "+String(_logMinV)+"\n";
			str += " _scale: "+String(_scale)+"\n";
			str += " value: "+String(value)+"\n";
			str += " valueString: "+valueString+"\n";
			return str;
		}
	}
	
}

