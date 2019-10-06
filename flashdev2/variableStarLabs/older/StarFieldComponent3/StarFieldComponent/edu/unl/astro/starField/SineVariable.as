
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class SineVariable extends EventDispatcher implements IStar {
		
		private var _paramsObj:StarParamsObject;
		
		private var _peak:Number;
		private var _dip:Number;
		private var _period:Number;
		private var _phaseOffset:Number;
		
		public function SineVariable(initX:Number, initY:Number, peak:Number, dip:Number, period:Number, phaseOffset:Number):void {
//			if ((initX is Number) && (initY is Number)) setPosition({x: initX, y: initY}, true);
//			if (initMagnitude is Number) setMagnitude(initMagnitude, true);
			
			_paramsObj = new StarParamsObject(initX, initY, peak);
			
			_peak = peak;
			_dip = dip;
			_period = period;
			_phaseOffset = phaseOffset;			
		}
		
		public function getParamsObject(epoch:Number):StarParamsObject {
			var sine:Number = Math.sin((Math.PI/_period)*(epoch - _phaseOffset));
			_paramsObj.magnitude = _peak + _dip*sine*sine;
			
			return _paramsObj;
		}
		
	}
	
}
