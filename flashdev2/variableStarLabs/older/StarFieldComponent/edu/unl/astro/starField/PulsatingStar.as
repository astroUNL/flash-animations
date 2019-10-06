
package edu.unl.astro.starField {
		
	final public class PulsatingStar extends Star {
		
		private var _phaseOffset:Number = 0;
		private var _period:Number = 3;
		private var _functionUsed:String = PulsatingStar.COSINE;
		private var _centerMagnitude:Number = 0;
		private var _fourierTermsList:Array = [];
		
		public static const COSINE = "cos";
		public static const SINE = "sin";
		public static const PRESETS:Object = {del_Cep: {period: 5.366341, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 3.988, fourierTermsList: [{A: 3.496E-01, phi: 2.491}, {A: 1.385E-01, phi: 3.084}, {A: 5.499E-02, phi: 3.811}, {A: 2.277E-02, phi: 4.083}, {A: 9.765E-03, phi: 4.709}]},
											  RT_Mus: {period: 3.08617, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 9.03, fourierTermsList: [{A: 0.331, phi: 0.0277}, {A: 0.131, phi: 4.13}, {A: 0.0503, phi: 2.24}, {A: 0.0416, phi: 6.16}]},
											  AS_Per: {period: 4.972516, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 9.760, fourierTermsList: [{A: 3.583E-01, phi: 2.468}, {A: 1.443E-01, phi: 3.084}, {A: 5.731E-02, phi: 3.650}, {A: 2.603E-02, phi: 3.695}, {A: 2.110E-02, phi: 4.625}]},
											  S_Nor: {period: 9.75411, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 6.4354, fourierTermsList: [{A: 0.2874, phi: 3.1842}, {A: 0.0191, phi: 4.6142}, {A: 0.0296, phi: 2.7042}, {A: 0.0144, phi: 3.3482}, {A: 0.0180, phi: 3.0182}, {A: 0.0159, phi: 3.4322}]},
											  PZ_Aql: {period: 8.7513, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 11.7, fourierTermsList: [{A: 0.365, phi: 4.66}, {A: 0.0459, phi: 1.75}, {A: 0.0208, phi: 2.76}, {A: 0.0188, phi: 5.98}]},
											  MT_Tel: {period: 0.316897, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 9.01, fourierTermsList: [{A: 2.60e-1, phi: 1.93}, {A: 7.35e-2, phi: 1.89}, {A: 1.66e-2, phi: 1.85}, {A: 1.00e-2, phi: 1.95}, {A: 5.60e-3, phi: 1.35}, {A: 4.89e-3, phi: 1.48}, {A: 4.53e-3, phi: 1.62}, {A: 1.51e-3, phi: 1.11}]},
											  RR_Leo: {period: 0.4523933, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 10.83, fourierTermsList: [{A: 4.55e-1, phi: 6.91e-1}, {A: 2.28e-1, phi: 5.16}, {A: 1.61e-1, phi: 3.69}, {A: 9.91e-2, phi: 2.33}, {A: 7.79e-2, phi: 1.02}, {A: 4.91e-2, phi: 5.81}, {A: 3.27e-2, phi: 4.45}, {A: 3.14e-2, phi: 2.97}]},
											  VX_Her: {period: 0.45537282, functionUsed: PulsatingStar.COSINE, actualCenterMagnitude: 10.78, fourierTermsList: [{A: 4.58e-1, phi: 4.51}, {A: 2.12e-1, phi: 2.61e-1}, {A: 1.64e-1, phi: 2.56}, {A: 1.06e-1, phi: 4.96}, {A: 7.33e-2, phi: 1.07}, {A: 5.92e-2, phi: 3.57}, {A: 3.62e-2, phi: 6.07}, {A: 2.70e-2, phi: 2.20}]}};
		
		public function PulsatingStar(...argsList):void {
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		override protected function loadSettingsFromObjectsList(objectsList):void {
			_callUpdate = false;
			var settingsObj:Object;
			for (var i:int = 0; i<objectsList.length; i++) {
				if (objectsList[i] is Object) {
					settingsObj = objectsList[i];
					if (settingsObj.x is Number) x = settingsObj.x;
					if (settingsObj.y is Number) y = settingsObj.y;
					if (settingsObj.phaseOffset is Number) phaseOffset = settingsObj.phaseOffset;
					if (settingsObj.period is Number) period = settingsObj.period;
					if (settingsObj.functionUsed is String) functionUsed = settingsObj.functionUsed;
					if (settingsObj.centerMagnitude is Number) centerMagnitude = settingsObj.centerMagnitude;
					if (settingsObj.fourierTermsList is Array) fourierTermsList = settingsObj.fourierTermsList;
				}
			}
			_callUpdate = true;
			update();						
		}
		
		override public function get magnitude():Number {
			var func:Function = Math[_functionUsed];
			var sum:Number = _centerMagnitude;
			var t:Number = (2*Math.PI)*(epoch - _phaseOffset)/_period;
			for (var i:int = 0; i<_fourierTermsList.length; i++)	sum += _fourierTermsList[i].A*func((i+1)*t + _fourierTermsList[i].phi);
			return sum;
		}
		
		override public function set magnitude(arg:Number):void {
			throw new Error("magnitude is read-only for an instance of PulsatingStar");
		}
		
		public function get phaseOffset():Number {
			return _phaseOffset;
		}
		
		public function set phaseOffset(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_phaseOffset = arg;
			if (_callUpdate) update();
		}
		
		public function get period():Number {
			return _period;
		}
		
		public function set period(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_period = arg;
			if (_callUpdate) update();
		}
		
		public function get functionUsed():String {
			return _functionUsed;
		}
		
		public function set functionUsed(arg:String):void {
			if (arg!=PulsatingStar.COSINE && arg!=PulsatingStar.SINE) return;
			_functionUsed = arg;
			if (_callUpdate) update();
		}
		
		public function get centerMagnitude():Number {
			return _centerMagnitude;
		}
		
		public function set centerMagnitude(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_centerMagnitude = arg;
			if (_callUpdate) update();
		}
		
		public function get fourierTermsList():Array {
			var copyList:Array = [];
			for (var i:int = 0; i<_fourierTermsList.length; i++) {
				copyList[i] = {A: _fourierTermsList[i].A, phi: _fourierTermsList[i].phi};
			}
			return copyList;
		}
		
		public function set fourierTermsList(arg:Array):void {
			var obj:Object;
			var copyList:Array = [];
			for (var i:int = 0; i<arg.length; i++) {
				obj = {};
				obj.A = arg[i].A;
				obj.phi = arg[i].phi;
				if (!(obj.A is Number) || isNaN(obj.A) || !isFinite(obj.A) ||
					!(obj.phi is Number) || isNaN(obj.phi) || !isFinite(obj.phi)) break;
				copyList[i] = obj;
			}
			_fourierTermsList = copyList;
			if (_callUpdate) update();
		}
		
	}
		
}
