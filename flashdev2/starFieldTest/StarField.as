package {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	 
	public class StarField extends Sprite {
		
		private var _width:Number;
		private var _height:Number;
		
		private var _noiseMean:Number;
		private var _noiseSigma:Number;
		private var _noiseSeed:uint;
		
		private var _saturationMagnitude:Number;
		private var _bitDepth:uint;
		private var _peakValue:Number; // = 2^bitDepth
		private var _psfRadius:uint;
		private var _psfData:Array;
		
		private var _starsList:Array;
		
		private var _noiseData:Array;
		private var _fieldData:Array; // noise plus stars
		
		private var _fieldBMD:BitmapData;
		private var _fieldBM:Bitmap;
		
		private var _lock:Boolean = false;
		
		public function StarField(initObj:* = undefined):void {
			if (initObj is Object) {
				if ((initObj.width is Number) && (initObj.height is Number)) setDimensions(initObj.width, initObj.height);
				else setDimensions(300, 300);
			}
			
			_starsList = [];
			lock();
			bitDepth = 16;
			saturationMagnitude = 3;
			setNoiseParameters(5000, 3000, 100);
			psfRadius = 7;
			
			addStar("star1", 1, 50, 50);
			addStar("star2", 2, 100, 50);
			addStar("star3", 3, 150, 50);
			addStar("star4", 4, 200, 50);
			addStar("star5", 5, 250, 50);
			unlock();
		}
		
		public function lock():void {
			_lock = true;
		}
		
		public function unlock():void {
			_lock = false;
			update();		
		}
		
		private function update():void {
			if (_lock) return;
			var startTimer:Number = getTimer();
			calculateNoiseData();
			calculateFieldData();
			generateBitmap();
			trace("update: "+(getTimer()-startTimer));
		}
		
		private function generateBitmap():void {
			var g:uint;
			for (var x:uint = 0; x<_width; x++) {
				for (var y:uint = 0; y<_height; y++) {
					g = uint(0xff*_fieldData[x][y]/_peakValue);
					//g = uint(0xff*Math.pow((_fieldData[x][y]/_peakValue), 0.5));
					_fieldBMD.setPixel(x, y, g | (g << 8) | (g << 16));
				}
			}
		}
		
		public function addStar(name:String, mag:Number, x:uint, y:uint, options:* = null):void {
			_starsList.push({name: name, mag: mag, x: x, y: y, options: options});
			update();
		}
		
		public function removeAllStars():void {
			_starsList = [];
			update();
		}
		
		public function get saturationMagnitude():Number {
			return _saturationMagnitude;			
		}
		
		public function set saturationMagnitude(mag:Number):void {
			_saturationMagnitude = mag;
		}
		
		public function get bitDepth():uint {
			return _bitDepth;			
		}
		
		public function set bitDepth(depth:uint):void {
			if (depth>32 || depth<2) return;
			else {
				_bitDepth = depth;
				_peakValue = Math.pow(2, _bitDepth) - 1;
			}
		}
		
		public function get psfRadius():uint {
			return _psfRadius;
		}
	
		public function set psfRadius(radius:uint):void {
			// - the radius parameter specifies the radius of the psf in pixels
			// - the psf used is the airy pattern out to the first trough (r = 3.831705970256774), the
			//   formula for which is 4*(J1(r)/r)^2
			// - what this function does is create a pixel array of psf values
			// - note that the psf is centered at the shared corner of the middle pixels, and the
			//   values are determined at the pixel centers
			// - the _psfData array is 2*radius by 2*radius
			// - the psf calculated here has a peak value of 1 and needs to be scaled depending on magnitude and scale
			
			var startTimer:Number = getTimer();
			
			var i:uint;
			var j:uint;
			
			var r2:Number;
			var J1_r:Number;
			var x:Number;
			var y:Number;
			var a:Number;
			
			var n:uint = 2*radius;
			var scale:Number = 3.831705970256774/radius;
		
			_psfRadius = radius;
			_psfData = [];
			for (i=0; i<n; i++) _psfData[i] = [];
			
			// the way this works is to determine the values in a 45° slice and then mirror them into the array
			
			for (i=0; i<radius; i++) {
				x = scale*(i + 0.5);		
				for (j=0; j<=i; j++) {
					y = scale*(j + 0.5);
					r2 = x*x + y*y;
					if (r2>=14.681970642501405) a = -1;
					else {
						J1_r = J1(Math.sqrt(r2));
						a = 4*J1_r*J1_r/r2;
					}
					_psfData[radius+i][radius-1-j] = a;
					_psfData[radius+j][radius-1-i] = a;
					_psfData[radius-1-j][radius-1-i] = a;
					_psfData[radius-1-i][radius-1-j] = a;
					_psfData[radius-1-i][radius+j] = a;
					_psfData[radius-1-j][radius+i] = a;
					_psfData[radius+j][radius+i] = a;
					_psfData[radius+i][radius+j] = a;					
				}
			}
			
			trace("set psfRadius: "+(startTimer-getTimer()));
		}
		
		public function getValueAt(x:uint, y:uint):uint {
			var tmp:Number = _fieldData[x][y];
			if (tmp<0) tmp = 0;
			return uint(tmp);
		}		
		
		public function getApertureMaskData(maskParams:Object):Object {
			// - expected maskParams properties:
			//     x, y - center coordinates, of type uint
			//     innerRadius, outerRadius - of type uint
			// - the returned object will have the following properties:
			//     starSum, uint
			//     backgroundSum, uint
			//     numStarPixels, uint
			//     numBackgroundPixels, uint
			//     cropped, Boolean
			//     starAverage, Number
			//     backgroundAverage, Number
			
			var cropped:Boolean = false;
			
			var left = maskParams.x - maskParams.outerRadius;
			if (left<0) {
				left = 0;
				cropped = true;
			}
			
			var right = maskParams.x + maskParams.outerRadius + 1;
			if (right>_width) {
				right = _width;
				cropped = true;				
			}
			
			var top = maskParams.y - maskParams.outerRadius;
			if (top<0) {
				top = 0;
				cropped = true;
			}
			
			var bottom = maskParams.y + maskParams.outerRadius + 1;
			if (bottom>_height) {
				bottom = _height;
				cropped = true;
			}
			
			var starSum:uint = 0;
			var bkgdSum:uint = 0;
			var numStarPixels:uint = 0;
			var numBkgdPixels:uint = 0;
			
			var x2:uint;
			var d2:uint;
			
			var inner2:uint = maskParams.innerRadius*maskParams.innerRadius;
			var outer2:uint = maskParams.outerRadius*maskParams.outerRadius;
			
			for (var x:uint = left; x<right; x++) {
				x2 = x*x;
				for (var y:uint = top; y<bottom; y++) {
					d2 = x2 + y*y;
					if (d2<=inner2) {
						starSum += _fieldData[x][y];
						numStarPixels++;
					}
					else if (d2<=outer2) {
						bkgdSum += _fieldData[x][y];
						numBkgdPixels++;
					}
				}
			}
			
			var dataObj:Object = {};
			dataObj.starSum = starSum;
			dataObj.backgroundSum = bkgdSum;
			dataObj.numStarPixels = numStarPixels;
			dataObj.numBackgroundPixels = numBkgdPixels;
			dataObj.cropped = cropped;
			dataObj.starAverage = starSum/numStarPixels;
			dataObj.backgroundAverage = bkgdSum/numBkgdPixels;
			
			return dataObj;
		}
		
		private function clearField():void {
			var startTimer:Number = getTimer();
			var i:Number, j:Number;
			var w:Number = _width;
			var h:Number = _height;
			var column:Array;
			for (i=0; i<w; i++) {
				column = _fieldData[i];
				for (j=0; j<h; j++) column[j] = 0;
			}
			trace("clearFieldData: "+(getTimer()-startTimer));
		}
		
		public function setNoiseParameters(mean:Number, sigma:Number, seed:uint):void {
			_noiseMean = mean;
			_noiseSigma = sigma;
			_noiseSeed = seed;
			update();		
		}
		
		private function calculateNoiseData():void {
			var startTimer:Number = getTimer();
			_noiseData = [];
			var f:Number;
			var x1:Number;
			var x2:Number;
			var column:Array;
			var h:uint = _height;
			var seed:uint = _noiseSeed;
			if ((h%2)==1) h += 1;
			for (var i:uint = 0; i<_width; i++) {
				column = [];
				for (var j:uint = 0; j<h; j+=2) {
					do {
						x1 = 2*(seed/2147483647) - 1;
						seed = (seed*16807)%2147483647;
						x2 = 2*(seed/2147483647) - 1;
						seed = (seed*16807)%2147483647;
						f = x1*x1 + x2*x2;
					} while (f>=1);
					f = Math.sqrt((-2*Math.log(f))/f);
					column[j] = _noiseMean + _noiseSigma*x1*f;
					column[j+1] = _noiseMean + _noiseSigma*x2*f;
				}
				_noiseData.push(column);
			}
			trace("calculateNoise: "+(getTimer()-startTimer));
		}
		
		private function calculateFieldData():void {
			var startTimer = getTimer();
			
			var x:uint;
			var y:uint;
			var i:uint;
			var j:uint;
			var k:uint;
			
			var m:Number;
			var f:Number;
			
			var left:int;
			var top:int;
			
			var n:uint = 2*_psfRadius;
			
			var column:Array;
			
			_fieldData = [];
			for (x=0; x<_width; x++) {
				column = [];
				for (y=0; y<_height; y++) column[y] = 0;
				_fieldData.push(column);
			}
			
			for (i=0; i<_starsList.length; i++) {
				f = _peakValue*Math.pow(10, (_saturationMagnitude-_starsList[i].mag)/2.5);
				left = _starsList[i].x - _psfRadius;
				top = _starsList[i].y - _psfRadius;
				for (j=0; j<n; j++) {
					x = left + j;
					if (x<0 || x>=_width) continue;
					for (k=0; k<n; k++) {
						y = top + k;
						if (_psfData[j][k]<=0 || y<0 || y>=_height) continue;
						_fieldData[x][top+k] += f*_psfData[j][k];
					}
				}
			}
			
			var v:Number;
			for (x=0; x<_width; x++) {
				for (y=0; y<_height; y++) {
					v = _noiseData[x][y] + _fieldData[x][y];
					if (v>_peakValue) v = _peakValue;
					else if (v<0) v = 0;
					_fieldData[x][y] = uint(v);
				}
			}
			
			trace("calculateFieldData: "+(getTimer()-startTimer));
		}
		
		public function setDimensions(w:Number, h:Number):void {
			_width = w;
			_height = h;
			_fieldBMD = new BitmapData(w, h, false, 0xff0000);
			_fieldBM = new Bitmap(_fieldBMD);
			addChild(_fieldBM);
		}
		
		private function J1(x:Number):Number {
			// calculates the Bessel function J1 according to the method in Numerical Recipes in C
			var y:Number;
			var ans1:Number;
			var ans2:Number;
			var ans:Number;
			var ax:Number = Math.abs(x);
			if (ax<8.0) {
				y = x*x;
				ans1 = x*(72362614232.0 + y*(-7895059235.0 + y*(242396853.1
					+ y*(-2972611.439 + y*(15704.48260 + y*(-30.16036606))))));
				ans2 = 144725228442.0 + y*(2300535178.0 + y*(18583304.74
					+ y*(99447.43394 + y*(376.9991397 + y*1.0))));
				ans = ans1/ans2;
			}
			else {
				var z:Number = 8.0/ax;
				y = z*z;
				var xx:Number = ax - 2.356194491;
				ans1 = 1.0 + y*(0.183105e-2 + y*(-0.3516396496e-4
					+ y*(0.2457520174e-5 + y*(-0.240337019e-6))));
				ans2 = 0.04687499995 + y*(-0.2002690873e-3
					+ y*(0.8449199096e-5 + y*(-0.88228987e-6
					+ y*0.105787412e-6)));
				ans = Math.sqrt(0.636619772/ax)*(Math.cos(xx)*ans1 - z*Math.sin(xx)*ans2);
				if (x<0.0) ans = -ans;
			}
			return ans;
		}
	}	
}