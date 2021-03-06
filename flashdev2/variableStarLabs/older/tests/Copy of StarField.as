﻿
package {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import flash.events.Event;
	
	import flash.events.Event;

	 
	public class StarField extends Sprite {
		
		private var _width:Number;
		private var _height:Number;
		
		private var _noiseMean:Number;
		private var _noiseSigma:Number;
		private var _noiseSeed:uint = 1;
		
		private var _saturationMagnitude:Number;
		private var _bitDepth:uint;
		private var _peakValue:Number; // := 2^bitDepth - 1
		private var _psfRadius:uint;
		private var _psfData:Array;
		
		private var _mappingMode:String = "linear";
		private var _invertMapping:Boolean = false;
		
		private var _starsList:Array = [];
		
		private var _noiseData:Array;
		private var _fieldData:Array; // noise plus stars
		
		private var _fieldBMD:BitmapData;
		private var _fieldBM:Bitmap;
		
		private var _locked:Boolean = false;
		
		public function StarField(initObj:* = undefined):void {
			if (initObj is Object) {
				if ((initObj.width is Number) && (initObj.height is Number)) setDimensions(initObj.width, initObj.height);
				else setDimensions(300, 300);
			}
			
			lock();
			
			bitDepth = 16;
			saturationMagnitude = 3;
			setNoiseParameters(5000, 3000);
			psfRadius = 7;			
			
			addStar({x: 50, y: 50, mag: 1});
			addStar({x: 100, y: 50, mag: 2});
			addStar({x: 150, y: 50, mag: 3});
			addStar({x: 200, y: 50, mag: 4});
			addStar({x: 250, y: 50, mag: 5});
			
			unlock();
			
			
			
			addEventListener(Event.ENTER_FRAME, update);

		}
		
		public function update(...args):void {
			trace("");
			if (_locked) return;
			var startTimer:Number = getTimer();
			shuffleNoiseData();
			generateFieldData();
			generateBitmap();
			trace("update: "+(getTimer()-startTimer));
		}
		
		public function lock():void {
			clearBitmap();
			_locked = true;
		}
		
		public function unlock():void {
			_locked = false;
			update();		
		}
		
		public function setDimensions(w:Number, h:Number):void {
			_width = w;
			_height = h;
			_fieldBMD = new BitmapData(w, h, false, 0xff0000);
			_fieldBM = new Bitmap(_fieldBMD);
			addChild(_fieldBM);
			
			clearBitmap();
			generateNoiseData();
			update();
		}
		
		private function clearBitmap():void {
			_fieldBMD.fillRect(new Rectangle(0, 0, _width, _height), 0x000000);
		}
		
		private function generateBitmap():void {
			var startTimer = getTimer();
			var g:uint;
			
			_fieldBMD.lock();
			if (_mappingMode=="linear") {
				for (var x:uint = 0; x<_width; x++) {
					for (var y:uint = 0; y<_height; y++) {
						g = uint(0xff*_fieldData[x][y]/_peakValue);
						if (_invertMapping) g = _peakValue - g;
						_fieldBMD.setPixel(x, y, g | (g << 8) | (g << 16));
					}
				}
			}
			_fieldBMD.unlock();
			
			/*
			for (var x:uint = 0; x<_width; x++) {
				for (var y:uint = 0; y<_height; y++) {
					g = uint(0xff*_fieldData[x][y]/_peakValue);
					//g = uint(0xff*Math.pow((_fieldData[x][y]/_peakValue), 0.5));
					_fieldBMD.setPixel(x, y, g | (g << 8) | (g << 16));
				}
			}
			*/
			
			trace("generateBitmap: "+(getTimer()-startTimer));
		}
		
		public function addStar(params:Object):void {
			_starsList.push(params);
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
			
			var i:int;
			var j:int;
			
			var r2:Number;
			var J1_r:Number;
			var x:Number;
			var y:Number;
			var a:Number;
			
			var n:int = 2*radius;
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
			
			var starSum:int = 0;
			var bkgdSum:int = 0;
			var numStarPixels:int = 0;
			var numBkgdPixels:int = 0;
			
			var x2:int;
			var d2:int;
			
			var inner2:int = maskParams.innerRadius*maskParams.innerRadius;
			var outer2:int = maskParams.outerRadius*maskParams.outerRadius;
			
			for (var x:int = left; x<right; x++) {
				x2 = x*x;
				for (var y:int = top; y<bottom; y++) {
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
		
		public function setNoiseParameters(mean:Number, sigma:Number, seed:* = undefined):void {
			_noiseMean = mean;
			_noiseSigma = sigma;
			if (seed is uint) _noiseSeed = seed;
			generateNoiseData();
			update();		
		}
		
		private function generateNoiseData():void {
			// - this function generates an array of noise values following a gaussian distribution
			//   according to the current noise parameters; the random numbers are generated using
			//   an adaptation of an algorithm found at
			//     http://lab.polygonal.de/2007/04/21/a-good-pseudo-random-number-generator-prng/
			//   which allows seeding the algorithm, unlike Math.random()
			// - note that the noise values can be negative in this arrangement 
			// - another thing to note is that the noise data array always contains an even number of values
			//   per column -- if the height is odd there is an extra value that will then be ignored
			var startTimer:Number = getTimer();
			_noiseData = [];
			var f:Number;
			var x1:Number;
			var x2:Number;
			var column:Array;
			var h:int = _height;
			var seed:uint = _noiseSeed;
			if ((h%2)==1) h += 1;
			for (var i:int = 0; i<_width; i++) {
				column = [];
				for (var j:int = 0; j<h; j+=2) {
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
			trace("generateNoiseData: "+(getTimer()-startTimer));
		}
		
		private function shuffleNoiseData():void {
			// - this function shuffles the columns in the noise data array; the reason for this
			//   is that it is too CPU intensive to recalculate the noise from scratch for every frame
			var startTimer:Number = getTimer();
			var newNoiseData:Array = [];
			for (var i:int = _noiseData.length; i>0; i--) {
				newNoiseData.push(_noiseData.splice(Math.floor(i*Math.random()), 1)[0]);
			}
			_noiseData = newNoiseData;
			trace("shuffleNoiseData: "+(getTimer()-startTimer));
		}
		
		private function generateFieldData():void {
			var startTimer = getTimer();
			
			var x:int;
			var y:int;
			var i:int;
			var j:int;
			var k:int;
			var left:int;
			var top:int;
			var m:Number;
			var f:Number;
			var v:Number;
			var column:Array;
			var n:int = 2*_psfRadius;
			
			_fieldData = [];
			
			startTimer = getTimer();
			
			// initialize and zero the data array
			for (x=0; x<_width; x++) {
				column = [];
				for (y=0; y<_height; y++) column[y] = 0;
				_fieldData.push(column);
			}
			
			trace("section 1: "+(getTimer()-startTimer));
			startTimer = getTimer();
			
			// add the stars to the data array
			for (i=0; i<_starsList.length; i++) {
				// f is the psf scaling factor for a star, left and top denote the position
				// of the upper left corner of the psf template for that star
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
			
			trace("section 2: "+(getTimer()-startTimer));
			startTimer = getTimer();
		
			// now add the noise and quantize the result
			for (x=0; x<_width; x++) {
				for (y=0; y<_height; y++) {
					_fieldData[x][y] += _noiseData[x][y];/*
					v = _noiseData[x][y] + _fieldData[x][y];
					if (v>_peakValue) v = _peakValue;
					else if (v<0) v = 0;
					_fieldData[x][y] = uint(v);*/
				}
			}
			
				trace("section 3: "+(getTimer()-startTimer));
		//trace("generateFieldData: "+(getTimer()-startTimer));
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
		
		//
	}
}
