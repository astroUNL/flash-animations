
package edu.unl.astro.starField {
	
	final public class EclipsingBinary extends Star {
		
		private var _argument:Number = 162.8*(Math.PI/180);
		private var _inclination:Number = 85.66*(Math.PI/180);
		private var _eccentricity:Number = 0.33;
		private var _separation:Number = 10.87*EclipsingBinary.SOLAR_RADIUS;
		private var _phaseOffset:Number = 0;
		private var _peakMagnitude:Number = 0;
		private var _mass1:Number = 1.9*EclipsingBinary.SOLAR_MASS;
		private var _mass2:Number = 1.4*EclipsingBinary.SOLAR_MASS;
		private var _radius1:Number = 1.7*EclipsingBinary.SOLAR_RADIUS;
		private var _radius2:Number = 1.5*EclipsingBinary.SOLAR_RADIUS;
		private var _temperature1:Number = 8730;
		private var _temperature2:Number = 6530;
		
		private var _C1:Number;
		private var _J1:Number;
		private var _J2:Number;
		private var _J3:Number;
		private var _J4:Number;
		private var _R12:Number;
		private var _R22:Number;
		private var _Z0:Number;
		private var _Z1:Number;
		private var _Z2:Number;
		private var _Z3:Number;
		private var _H1:Number;
		private var _H2:Number;
		private var _maxVisFlux:Number;
		private var _minVisMag:Number;
		private var _period:Number;
		private var _distanceModulus:Number;
		
		public static const SOLAR_MASS:Number = 1.98892e30; // in kg
		public static const SOLAR_RADIUS:Number = 6.955e8; // in m
		public static const PRESETS:Object = {TW_Cas: {argument: 0, inclination: 74.7, eccentricity: 0, separation: 8.17, mass1: 2.5, radius1: 2.0, temperature1: 10500, mass2: 1.1, radius2: 2.6, temperature2: 5400},
											  AG_Phi: {argument: 0, inclination: 87.624, eccentricity: 0, separation: 4.22, mass1: 1.53, radius1: 1.7, temperature1: 7500, mass2: 0.24, radius2: 1.0, temperature2: 5400},
											  V477_Cyg: {argument: 162.8, inclination: 85.66, eccentricity: 0.33, separation: 10.87, mass1: 1.9, radius1: 1.7, temperature1: 8730, mass2: 1.4, radius2: 1.5, temperature2: 6530},
											  CW_CMa: {argument: 0, inclination: 83.3, eccentricity: 0, separation: 11.92, mass1: 2.6, radius1: 2.1, temperature1: 10800, mass2: 2.5, radius2: 1.9, temperature2: 10300},
											  EK_Cep: {argument: 49.8, inclination: 89.16, eccentricity: 0.11, separation: 16.58, mass1: 2.0, radius1: 1.6, temperature1: 9000, mass2: 1.1, radius2: 1.3, temperature2: 5690},
											  V526_Sgr: {argument: 254.8, inclination: 87.3, eccentricity: 0.22, separation: 10.43, mass1: 2.4, radius1: 1.9, temperature1: 10100, mass2: 1.8, radius2: 1.6, temperature2: 8450},
											  T_LMi: {argument: 0, inclination: 86.3, eccentricity: 0, separation: 11.97, mass1: 2.3, radius1: 1.9, temperature1: 9860, mass2: 0.23, radius2: 2.4, temperature2: 5060}};
										
		public function EclipsingBinary(...argsList):void {
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		override protected function update():void {
			calculateConstants();
			super.update();
		}
		
		override protected function loadSettingsFromObjectsList(objectsList):void {
			_callUpdate = false;
			var settingsObj:Object;
			for (var i:int = 0; i<objectsList.length; i++) {
				if (objectsList[i] is Object) {
					settingsObj = objectsList[i];
					if (settingsObj.x is Number) x = settingsObj.x;
					if (settingsObj.y is Number) y = settingsObj.y;
					if (settingsObj.argument is Number) argument = settingsObj.argument;
					if (settingsObj.inclination is Number) inclination = settingsObj.inclination;
					if (settingsObj.eccentricity is Number) eccentricity = settingsObj.eccentricity;
					if (settingsObj.separation is Number) separation = settingsObj.separation;
					if (settingsObj.phaseOffset is Number) phaseOffset = settingsObj.phaseOffset;
					if (settingsObj.peakMagnitude is Number) peakMagnitude = settingsObj.peakMagnitude;
					if (settingsObj.mass1 is Number) mass1 = settingsObj.mass1;
					if (settingsObj.mass2 is Number) mass2 = settingsObj.mass2;
					if (settingsObj.radius1 is Number) radius1 = settingsObj.radius1;
					if (settingsObj.radius2 is Number) radius2 = settingsObj.radius2;
					if (settingsObj.temperature1 is Number) temperature1 = settingsObj.temperature1;
					if (settingsObj.temperature2 is Number) temperature2 = settingsObj.temperature2;
				}
			}
			_callUpdate = true;
			update();						
		}
		
		override public function get magnitude():Number {
			// the code used here and in calculateConstants() was copied and adapted from Lightcurve Component II (v010)
			var ma:Number = 2*Math.PI*(epoch - _phaseOffset)/_period;
			var ea0:Number = 0;
			var ea1:Number = ma;
			var counter:int = 0;
			do {
				ea0 = ea1;
				ea1 = ea0+(ma+_eccentricity*Math.sin(ea0)-ea0)/(1-_eccentricity*Math.cos(ea0));
				counter++;
			} while (Math.abs(ea1-ea0)>0.001 && counter<100);
			if (counter>=100) throw new Error("iteration limit reached in EclipsingBinary, maybe eccentricity is too high");
			var ta:Number = 2*Math.atan(_C1*Math.tan(ea1/2));
			var cosTa:Number = Math.cos(ta);
			var cosTaArg:Number = Math.cos(ta + (_argument));
			var d:Number = Math.sqrt((_J1*cosTaArg*cosTaArg + _J2)/(1 + _J3*cosTa + _J4*cosTa*cosTa));
			if (d==0) d = 1e-8;
			var ca:Number = _Z0*d + _Z1/d;
			var cb:Number = _Z2*d + _Z3/d;
			if (ca<-1) ca = -1;
			else if (ca>1) ca = 1;
			if (cb<-1) cb = -1;
			else if (cb>1) cb = 1;
			var alpha:Number = Math.acos(ca);
			var beta:Number = Math.acos(cb);
			var overlap:Number = _R22*(alpha - ca*Math.sin(alpha)) + _R12*(beta - cb*Math.sin(beta));
			var star2InFront:Boolean = (((ta + _argument)%(2*Math.PI) + (2*Math.PI))%(2*Math.PI)) < Math.PI;
			var visFlux:Number = (star2InFront) ? _maxVisFlux - _H1*overlap : _maxVisFlux - _H2*overlap;
			var visMag:Number = -18.9669559998301 - (2.5/Math.LN10)*Math.log(visFlux);
			return (_distanceModulus + visMag);
		}
		
		override public function set magnitude(arg:Number):void {
			throw new Error("magnitude is read-only for an instance of EclipsingBinary");
		}

		public function get argument():Number {
			return _argument*(180/Math.PI);
		}
		
		public function set argument(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg)) return;
			_argument = arg*(Math.PI/180);
			if (_callUpdate) update();
		}
		
		public function get inclination():Number {
			return _inclination*(180/Math.PI);			
		}
		
		public function set inclination(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg)) return;
			_inclination = arg*(Math.PI/180);
			if (_callUpdate) update();
		}
		
		public function get eccentricity():Number {
			return _eccentricity;			
		}
		
		public function set eccentricity(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<0 || arg>=1) return;
			_eccentricity = arg;			
			if (_callUpdate) update();
		}
		
		public function get separation():Number {
			return _separation/EclipsingBinary.SOLAR_RADIUS;
		}
		
		public function set separation(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0) return;
			_separation = arg*EclipsingBinary.SOLAR_RADIUS;
			if (_callUpdate) update();		
		}
		
		public function get phaseOffset():Number {
			return _phaseOffset;
		}
		
		public function set phaseOffset(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_phaseOffset = arg;
			if (_callUpdate) update();	
		}
		
		public function get peakMagnitude():Number {
			return _peakMagnitude;			
		}
		
		public function set peakMagnitude(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_peakMagnitude = arg;
			if (_callUpdate) update();
		}
		
		public function get mass1():Number {
			return _mass1/EclipsingBinary.SOLAR_MASS;			
		}
		
		public function set mass1(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_mass1 = arg*EclipsingBinary.SOLAR_MASS;
			if (_callUpdate) update();
		}
		
		public function get mass2():Number {
			return _mass2/EclipsingBinary.SOLAR_MASS;			
		}
		
		public function set mass2(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_mass2 = arg*EclipsingBinary.SOLAR_MASS;
			if (_callUpdate) update();
		}
		
		public function get radius1():Number {
			return _radius1/EclipsingBinary.SOLAR_RADIUS;			
		}
		
		public function set radius1(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_radius1 = arg*EclipsingBinary.SOLAR_RADIUS;
			if (_callUpdate) update();
		}
		
		public function get radius2():Number {
			return _radius2/EclipsingBinary.SOLAR_RADIUS;			
		}
		
		public function set radius2(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_radius2 = arg*EclipsingBinary.SOLAR_RADIUS;
			if (_callUpdate) update();
		}
		
		public function get temperature1():Number {
			return _temperature1;			
		}
		
		public function set temperature1(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_temperature1 = arg;
			if (_callUpdate) update();
		}
		
		public function get temperature2():Number {
			return _temperature2;			
		}
		
		public function set temperature2(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg) || arg<=0) return;
			_temperature2 = arg;
			if (_callUpdate) update();
		}
		
		public function get distanceModulus():Number {
			return _distanceModulus;
		}
		
		public function get period():Number {
			return _period;
		}
		
		private function getBolometricCorrection(temperature:Number):Number {
			var logTeff:Number = Math.log(temperature)/Math.LN10;
			var k:Object;
			if (logTeff>3.9) k = {a: -100139.4991, b: 116264.1842, c: -53931.97541, d: 12495.04227, e: -1445.868048, f: 66.84924471};
			else if (logTeff<3.7) k = {a: -13884.14899, b: 8595.127427, c: -488.3425525, d: -627.0092238, e: 137.4608131, f: -7.549572042};
			else k = {a: 1439.981506, b: -151.9002581, c: -995.1089203, d: 582.5176671, e: -123.3293641, f: 9.160761128};
			return (k.a + logTeff*(k.b + logTeff*(k.c + logTeff*(k.d + logTeff*(k.e + k.f*logTeff)))));
		}
		
		private function calculateConstants():void {
			_C1 = Math.sqrt((1+_eccentricity)/(1-_eccentricity));
			
			var cosInclination = Math.cos(_inclination);
			var J0:Number = _separation*(1-_eccentricity*_eccentricity);
			
			_J1 = J0*J0*(1-cosInclination*cosInclination);
			_J2 = J0*J0*cosInclination*cosInclination;
			_J3 = 2*_eccentricity;
			_J4 = _eccentricity*_eccentricity;
			
			_R12 = _radius1*_radius1;
			_R22 = _radius2*_radius2;
			
			_Z0 = 1/(2*_radius2);
			_Z1 = (_R22-_R12)*_Z0;
			_Z2 = 1/(2*_radius1);
			_Z3 = (_R12-_R22)*_Z2;
			
			var BC1:Number = getBolometricCorrection(_temperature1);
			var BC2:Number = getBolometricCorrection(_temperature2);
			
			_H1 = 1.89553328524593e-43*Math.pow(_temperature1, 4)*Math.pow(10, BC1/2.5);
			_H2 = 1.89553328524593e-43*Math.pow(_temperature2, 4)*Math.pow(10, BC2/2.5);
			
			_maxVisFlux = (_R12*_H1 + _R22*_H2)*Math.PI;
			_minVisMag = -18.9669559998301 - (2.5/Math.LN10)*Math.log(_maxVisFlux);
			
			_period = Math.sqrt(4*Math.PI*Math.PI*_separation*_separation*_separation/(6.67300e-11*(_mass1 + _mass2)))/(24*60*60);
			
			_distanceModulus = _peakMagnitude - _minVisMag;
		}
		
	}
	
}
