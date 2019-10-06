package
{
	public class EclipsingBinary extends Star implements IStar {
		private static const solarRadius:Number = 6.96e8;
		
		public var numCurvePoints:uint = 100;
		
		// these default values are those for V526
		public var longitude:Number = 254.8;
		public var inclination:Number = 87.3;
		public var phaseOffset:Number = 0.2;
		public var separation:Number = 10.43;
		public var eccentricity:Number = 0.22;
		public var mass1:Number = 2.4;
		public var radius1:Number = 1.9;
		public var temp1:Number = 10100;
		public var mass2:Number = 1.8;
		public var radius2:Number = 1.6;
		public var temp2:Number = 8450;
		
		public function EclipsingBinary(initObj:* = undefined):void
		{
			if (initObj is Object) setParameters(initObj);
		}
		
		public function setParameters(paramsObj:Object):void
		{
			for (var x in paramsObj) this[x] = paramsObj[x];
		}
		
		public function getLightCurveTable(numPoints:uint = 100):Array
		{
			if ((numPoints%2) != 0) numPoints++;
			return this.getMagnitudeTable(this.getOverlapTable(this.getPositionTable(numPoints)));
		}
		
		
		
		
		private function getPositionTable(np:uint):Array
		{
			var pT:Array;
			
			var cos = Math.cos;
			var sin = Math.sin;
			var tan = Math.tan;
			var atan = Math.atan;
			var abs = Math.abs;
		
			var n = np/2;
			var step = (2*Math.PI)/np;
			var e = this.eccentricity;
			if (isNaN(e) || !isFinite(e) || e>=1 || e<0) e = 0;
			
			var k1 = Math.sqrt((1+e)/(1-e));
			var k2 = this.solarRadius*(1-e*e);
			
			pT[0] = {x: k2/(1+e), y: 0};
			pT[n] = {x: -k2/(1-e), y: 0};
			
			for (var i=1; i<n; i++)
			{
				var ma = i*step;
				var ea0 = 0;
				var ea1 = ma + e*sin(ma);
				do {
					ea0 = ea1;
					ea1 = ma + e*sin(ea0);
				} while (abs(ea1-ea0)>0.001);
				var ta = 2*atan(k1*tan(ea1/2));
				var k3 = k2/(1+e*cos(ta));
				var fpT = pT[i];
				var spT = pT[np-i];
				spT.x = fpT.x = k3*cos(ta);
				fpT.y = k3*sin(ta);
				spT.y = -fpT.y;
			}
			
			return pT;
		}
	
		private function getOverlapTable(pt:Array):Array
		{
			var oT:Array;
			
			var acos = Math.acos;
			var sin = Math.sin;
			var sqrt = Math.sqrt;
			
			var a = this.separation;
			var _ct = a*Math.cos((Math.PI/180)*(90-this.longitude));
			var _st = a*sin((Math.PI/180)*(90-this.longitude));
			var cp = Math.cos((Math.PI/180)*(90-this.inclination));
			var sp = sin((Math.PI/180)*(90-this.inclination));
			var k0 = -_st;
			var k1 = _ct;
			var k3 = _ct*sp;
			var k4 = _st*sp;
			var k6 = _ct*cp;
			var k7 = _st*cp;
			
			var r1 = this.solarRadius*this.radius1;
			var r2 = this.solarRadius*this.radius2;
			var r12 = r1*r1;
			var r22 = r2*r2;
			var R = r1 + r2;
			var RSQRD = R*R;
			
			var j0 = 1/(2*r2);
			var j1 = (r22-r12)*j0;
			var j2 = 1/(2*r1);
			var j3 = (r12-r22)*j2;
		
			var np = pT.length;
			
			var closestIndex = 0;
			var minD2 = Number.POSITIVE_INFINITY;
			
			for (var i=0; i<np; i++)
			{
				var p = pT[i];
				var dx = k0*p.x + k1*p.y;
				var dy = k3*p.x + k4*p.y;
				var dz = k6*p.x + k7*p.y;
				var d2 = dx*dx + dy*dy;
				if (dz>0 && d2<minD2)
				{
					minD2 = d2;
					closestIndex = i;
				}
				if (d2>=RSQRD) oT.push(0);
				else
				{
					var d = sqrt(d2);
					if (d==0) d = 1e-8;
					var ca = j0*d + j1/d;
					var cb = j2*d + j3/d;
					if (ca<-1) ca = -1;
					else if (ca>1) ca = 1;
					if (cb<-1) cb = -1;
					else if (cb>1) cb = 1;
					var alpha = acos(ca);
					var beta = acos(cb);
					var o = r22*(alpha - ca*sin(alpha)) + r12*(beta - cb*sin(beta));
					if (dz<0) oT.push(o); // star 1 in front
					else oT.push(-o);
				}
			}
			
			/*
			// The closest approach of star 1 to star 2 (where star 2 is in front) is given by closestIndex,
			// but only with an accuracy of 1/numCurvePoints. The code below attempts to find a fractional index
			// that gives the closest approach more accurately.
			
			// To get a better estimate of the closest approach, we will look at refinement-1 fractional indices
			// in the interval (closestIndex-1, closestIndex+1) -- ie. the fractional precision is 2/refinement.
			
			var refinement = 15;
			
			var cos = Math.cos;
			var tan = Math.tan;
			var atan = Math.atan;
			var abs = Math.abs;
			var e = this.eccentricity;
			var q1 = sqrt((1+e)/(1-e));
			var q2 = this.solarRadius*(1-e*e);
			var q4 = np/(2*Math.PI);
			var step = 2/(q4*refinement);
			var start = (closestIndex-1)/q4;	
			var refinedIndex = closestIndex;
			
			for (var i=1; i<refinement; i++)
			{
				var ma = start + i*step;
				var ea0 = 0;
				var ea1 = ma + e*sin(ma);
				do {
					ea0 = ea1;
					ea1 = ma + e*sin(ea0);
				} while (abs(ea1-ea0)>0.001);
				var ta = 2*atan(q1*tan(ea1/2));
				var q3 = q2/(1+e*cos(ta));
				var px = q3*cos(ta);
				var py = q3*sin(ta);
				var dx = k0*px + k1*py;
				var dy = k3*px + k4*py;
				var d2 = dx*dx + dy*dy;
				if (d2<minD2)
				{
					minD2 = d2;
					refinedIndex = ma*q4;
				}
			}
			
			this._closestIndex = (refinedIndex%np + np)%np;
			*/
			
			return oT;
		}
		
		private function generateMagnitudeTable():Array
		{
			// where some numbers come from:
			//   -18.9669559998301 = 4.83 + 2.5*log10(solarVisualFlux in W/m^2 at 10 parsecs)
			//   1.52183774688135e+18 = Pi * (solarRadius in meters)^2
			//   1.89553328524593e-43 = [stefan-boltzmann constant] / [Pi * (10 parsecs in meters)^2]
			
			var log = Math.log;
			
			this._visualMagnitudeTable = [];
			this._visualFluxTable = [];
			var vMT = this._visualMagnitudeTable;
			var vFT = this._visualFluxTable;
			var oT = this._overlapTable;
			var c = this._c;
			var np = this._numCurvePoints;
			
			var logTeff = log(c.temperature1)/Math.LN10;
			if (logTeff>3.9) var k = {a: -100139.4991, b: 116264.1842, c: -53931.97541, d: 12495.04227, e: -1445.868048, f: 66.84924471};
			else if (logTeff<3.7) var k = {a: -13884.14899, b: 8595.127427, c: -488.3425525, d: -627.0092238, e: 137.4608131, f: -7.549572042};
			else var k = {a: 1439.981506, b: -151.9002581, c: -995.1089203, d: 582.5176671, e: -123.3293641, f: 9.160761128};
			var BC1 = k.a + logTeff*(k.b + logTeff*(k.c + logTeff*(k.d + logTeff*(k.e + k.f*logTeff))));
			
			var logTeff = log(c.temperature2)/Math.LN10;
		
			if (logTeff>3.9) var k = {a: -100139.4991, b: 116264.1842, c: -53931.97541, d: 12495.04227, e: -1445.868048, f: 66.84924471};
			else if (logTeff<3.7) var k = {a: -13884.14899, b: 8595.127427, c: -488.3425525, d: -627.0092238, e: 137.4608131, f: -7.549572042};
			else var k = {a: 1439.981506, b: -151.9002581, c: -995.1089203, d: 582.5176671, e: -123.3293641, f: 9.160761128};
			var BC2 = k.a + logTeff*(k.b + logTeff*(k.c + logTeff*(k.d + logTeff*(k.e + k.f*logTeff))));
			
			var j1 =  1.89553328524593e-43*Math.pow(c.temperature1, 4)*Math.pow(10, BC1/2.5);
			var j2 = -1.89553328524593e-43*Math.pow(c.temperature2, 4)*Math.pow(10, BC2/2.5);
			
			var fullVisFlux = (c.radius1*c.radius1*j1 - c.radius2*c.radius2*j2)*1.52183774688135e+18;
			
			var minVisFlux = Number.POSITIVE_INFINITY;
			
			// if o<0 then star 2 is in front, otherwise star 1 is in front or there is no overlap
			for (var i=0; i<np; i++) {
				var o = oT[i];
				if (o<0) var visFlux = fullVisFlux + j1*o;
				else var visFlux = fullVisFlux + j2*o;
				if (visFlux<minVisFlux) minVisFlux = visFlux;
				var visMag = -18.9669559998301 - (2.5/Math.LN10)*log(visFlux);
				vFT.push(visFlux);
				vMT.push(visMag);
			}
			
			this._noEclipse = fullVisFlux == minVisFlux;
			
			this._maxVisFlux = fullVisFlux;
			this._minVisFlux = minVisFlux;
			
			if (this._noEclipse) {
				this._minVisMag = -18.9669559998301 - (2.5/Math.LN10)*log(this._maxVisFlux);
				this._maxVisMag = this._minVisMag + 3;
			}
			else {
				this._minVisMag = -18.9669559998301 - (2.5/Math.LN10)*log(this._maxVisFlux);
				this._maxVisMag = -18.9669559998301 - (2.5/Math.LN10)*log(this._minVisFlux);
				if ((this._maxVisMag-this._minVisMag) < this.minMagDiff) {
					this._maxVisMag = this._minVisMag + this.minMagDiff;
				}
			}
		}
	
		
	}
	
	
}
