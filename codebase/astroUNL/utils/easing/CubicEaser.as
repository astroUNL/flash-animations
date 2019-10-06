
// 1/22/10 - added startValue and startTime

package astroUNL.utils.easing {
	
	
	public class CubicEaser {
		
		public var slope0:Number = 0;
		public var slope1:Number = 0;
		public var splinePointsList:Array;
		public var targetValue:Number;
		public var targetTime:Number;
		public var parametersList:Array;
		
		public var startValue:Number;
		public var startTime:Number;
		
		public function CubicEaser(initValue:Number) {
			init(initValue);			
		}
		
		public function init(initValue:Number):void {
			setTarget(0, initValue, 1, initValue);
		}
		
		public function setTarget(xStart:Number, yStart:*, xTarget:Number, yTarget:Number):Object {
			// if yStart is null the component will use the y value associated with
			// xStart given the current parameters, it will also use the same slope so
			// the easing will be smooth
			
			// if yStart is defined the slope there will be zero			
			if (!(yStart is Number)) {
				yStart = getValue(xStart);
				slope0 = getDerivative(xStart);
			}
			else {
				slope0 = 0;
			}
			
			startTime = xStart;
			startValue = yStart;
			
			splinePointsList = [{x: xStart, y: yStart}, {x: xTarget, y: yTarget}];
			
			doComputations();
			
			targetTime = xTarget;			
			targetValue = yTarget;
			
			return {a: parametersList[0].a, b: parametersList[0].b, c: parametersList[0].c, d: parametersList[0].d};
		}
		
		public function getTargetValue():Number {
			return targetValue;			
		}
	
		public function getTargetTime():Number {
			return targetTime;			
		}
		
		public function getValue(x:Number):Number {
			var cL:Array = parametersList;
			var n:int = cL.length;
			for (var i:int = 0; i<n; i++) {
				if (x<cL[i].xUpper) break;			
			}
			if (i<n) return (cL[i].d + x*(cL[i].c + x*(cL[i].b + x*cL[i].a)));
			else return targetValue;
		}
		
		public function getDerivative(x:Number):Number {
			var cL:Array = parametersList;
			var n:int = cL.length;
			for (var i:int = 0; i<n; i++) {
				if (x<cL[i].xUpper) break;			
			}
			if (i<n) return cL[i].c + x*(2*cL[i].b + 3*x*cL[i].a);
			else return 0;
		};
		
		
		protected function doComputations():void {
			splinePointsList.sortOn("x", Array.NUMERIC);
			
			var i:int;
			var k:int;
			var sig:Number;
			var p:Number;
			
			var pL:Array = splinePointsList;
			var n:int = pL.length;
			var n_1:int = n - 1;
			var n_2:int = n - 2;
	
			var m0:Number = this.slope0;
			var m1:Number = this.slope1;
	
			var uL:Array = [];
			var y2L:Array = [];
	
			pL[0].d2 = -0.5;
			uL[0] = (3/(pL[1].x-pL[0].x))*(((pL[1].y-pL[0].y)/(pL[1].x-pL[0].x)) - m0);
			
			for (i=1; i<n_1; i++) {
				sig = (pL[i].x - pL[i-1].x)/(pL[i+1].x-pL[i-1].x);
				p = sig*pL[i-1].d2 + 2;
				pL[i].d2 = (sig - 1)/p;
				uL[i] = ((pL[i+1].y-pL[i].y)/(pL[i+1].x-pL[i].x)) - ((pL[i].y-pL[i-1].y)/(pL[i].x-pL[i-1].x));
				uL[i] = ((6*uL[i]/(pL[i+1].x-pL[i-1].x)) - sig*uL[i-1])/p;
			}
	
			var qn:Number = 0.5;
			var un:Number = (3/(pL[n_1].x-pL[n_2].x))*(m1-(pL[n_1].y-pL[n_2].y)/(pL[n_1].x-pL[n_2].x));
	
			pL[n_1].d2 = (un-qn*uL[n_2])/(qn*pL[n_2].d2+1);
	
			for (k=n_2; k>=0; k--) {
				pL[k].d2 = pL[k].d2*pL[k+1].d2 + uL[k];
			}
	
			var cL:Array = [];
			
			var p1:Object, p2:Object, p1d2:Number, p2d2:Number, p1x:Number, p2x:Number, p1y:Number, p2y:Number, h:Number, a:Number, b:Number, c:Number, d:Number;
	
			for (i=0; i<n_1; i++) {
				
				p1 = pL[i];
				p2 = pL[i+1];
				
				p1d2 = p1.d2;
				p2d2 = p2.d2;
				p1x = p1.x;
				p2x = p2.x;
				p1y = p1.y;
				p2y = p2.y;
				
				h = p2x - p1x;
				
				a = (p2d2-p1d2)/(6*h);
				b = (3*p2x*p1d2-3*p2d2*p1x)/(6*h);
				c = (-6*p1y+2*p2x*p2d2*p1x-p2x*p2x*p2d2-2*p2x*p1d2*p1x+p1d2*p1x*p1x-2*p2x*p2x*p1d2+6*p2y+2*p2d2*p1x*p1x)/(6*h);
				d = (-2*p2d2*p2x*p1x*p1x+2*p1d2*p2x*p2x*p1x+p2d2*p2x*p2x*p1x-6*p2y*p1x+6*p1y*p2x-p1d2*p2x*p1x*p1x)/(6*h);
			
				//trace(i);
				//trace(" a: "+a);
				//trace(" b: "+b);
				//trace(" c: "+c);
			//trace(" d: "+d);
			
			//trace("p1d2: "+p1d2);
			//trace("p2d2: "+p2d2);
				
				cL.push({xUpper: p2x, a: a, b: b, c: c, d: d});
			}
			
			parametersList = cL;
		}
		
	}
	
	/*
	
	
	
function CubicEasingClass(initValue) {
	this.slope1 = 0;
	this.init(initValue);
}

var p = CubicEasingClass.prototype = new Object();

p.init = function(initValue) {
	this.setTarget(0, initValue, 1, initValue);	
};

p.setTarget = function(xStart, yStart, xTarget, yTarget) {
	// if yStart is null the component will use the y value associated with
	// xStart given the current parameters, it will also use the same slope so
	// the easing will be smooth
	
	// if yStart is defined the slope there will be zero
	
	if (yStart==null) {
		yStart = this.getValue(xStart);
		this.slope0 = this.getDerivative(xStart);
	}
	else {
		this.slope0 = 0;
	}
	
	this.splinePointsList = [{x: xStart, y: yStart}, {x: xTarget, y: yTarget}];
	
	this.doComputations();
	
	this.targetValue = yTarget;
};

p.getValue = function(x) {
	var cL = this.parametersList;
	var n = cL.length;
	for (var i=0; i<n; i++) {
		if (x<cL[i].xUpper) break;			
	}
	if (i<n) {
		var v = (cL[i].d + x*(cL[i].c + x*(cL[i].b + x*cL[i].a)));
	}
	else {
		var v = this.targetValue;
	}
	return v;
};	

p.getDerivative = function(x) {
	var cL = this.parametersList;
	var n = cL.length;
	for (var i=0; i<n; i++) {
		if (x<cL[i].xUpper) break;			
	}
	if (i<n) return cL[i].c + x*(2*cL[i].b + 3*x*cL[i].a);
	else return 0;
};

p.doComputations = function() {
	
	var pL = this.splinePointsList;
	
	pL.sort(this.pointsCompareFunc);
	var n = pL.length;
	var n_1 = n - 1;
	var n_2 = n - 2;
	
	var m0 = this.slope0;
	var m1 = this.slope1;
	
	var uL = [];
	var y2L = [];
	
	pL[0].d2 = -0.5;
	uL[0] = (3/(pL[1].x-pL[0].x))*(((pL[1].y-pL[0].y)/(pL[1].x-pL[0].x)) - m0);
	
	for (var i=1; i<n_1; i++) {
		var sig = (pL[i].x - pL[i-1].x)/(pL[i+1].x-pL[i-1].x);
		var p = sig*pL[i-1].d2 + 2;
		pL[i].d2 = (sig - 1)/p;
		uL[i] = ((pL[i+1].y-pL[i].y)/(pL[i+1].x-pL[i].x)) - ((pL[i].y-pL[i-1].y)/(pL[i].x-pL[i-1].x));
		uL[i] = ((6*uL[i]/(pL[i+1].x-pL[i-1].x)) - sig*uL[i-1])/p;
	}
	
	var qn = 0.5;
	var un = (3/(pL[n_1].x-pL[n_2].x))*(m1-(pL[n_1].y-pL[n_2].y)/(pL[n_1].x-pL[n_2].x));
	
	pL[n_1].d2 = (un-qn*uL[n_2])/(qn*pL[n_2].d2+1);
	
	for (var k=n_2; k>=0; k--) {
		pL[k].d2 = pL[k].d2*pL[k+1].d2 + uL[k];
	}
	
	var cL = [];
	
	for (var i=0; i<n_1; i++) {
		
		var p1 = pL[i];
		var p2 = pL[i+1];
		
		var p1d2 = p1.d2;
		var p2d2 = p2.d2;
		var p1x = p1.x;
		var p2x = p2.x;
		var p1y = p1.y;
		var p2y = p2.y;
		
		var h = p2x - p1x;
		
		var a = (p2d2-p1d2)/(6*h);
		var b = (3*p2x*p1d2-3*p2d2*p1x)/(6*h);
		var c = (-6*p1y+2*p2x*p2d2*p1x-p2x*p2x*p2d2-2*p2x*p1d2*p1x+p1d2*p1x*p1x-2*p2x*p2x*p1d2+6*p2y+2*p2d2*p1x*p1x)/(6*h);
		var d = (-2*p2d2*p2x*p1x*p1x+2*p1d2*p2x*p2x*p1x+p2d2*p2x*p2x*p1x-6*p2y*p1x+6*p1y*p2x-p1d2*p2x*p1x*p1x)/(6*h);
	
		//trace(i);
		//trace(" a: "+a);
		//trace(" b: "+b);
		//trace(" c: "+c);
		//trace(" d: "+d);
		
		cL.push({xUpper: p2x, a: a, b: b, c: c, d: d});
	}
	
	this.parametersList = cL;
};

p.pointsCompareFunc = function(a, b) {
	if (a.x<b.x) return -1;
	else if (a.x>b.x) return 1;
	else return 0;	
};*/
		
}
