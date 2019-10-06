
package edu.unl.astro.starField {
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.ByteArray;
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
		
		
			
		
		private var _mappingMode:String = "linear";
		private var _invertMapping:Boolean = false;
		private var _gamma:Number = 1.8;		
		private var _lookupTable:Array;

		private var _starsList:Array;
		
		
		// - _noiseData is an array of the noise values that were calculated when
		//   the noise profile was specified; it can be divided into _numChunks segments
		//   each of which has _chunkSize values
		// - noisePixels is a byte array consisting of 0xAARRGGBB (uint) pixel values
		//   corresponding to the values in noiseSource mapped according to the current settings
		private var _noiseData:Array;
		private var _noisePixels:ByteArray;
		
		// - fieldData is a byte array consisting of the field data (ie. the counts) 
		//   in *floating point* format
		// - fieldPixels is a byte array consisting of the values
		private var _fieldDataS:Array;
		private var _fieldPixels:ByteArray;
		
		private var _fieldBMD:BitmapData;
		private var _fieldBM:Bitmap;
		
		private var _fieldRect:Rectangle;
		
		private var _locked:Boolean = false;
		
		private var _numChunks:int;
		private var _chunkSize:int;
		
		private var _chunkTable:Array;
		
		//public static const STAR_CHANGED:String = "starChanged";
		
		public function StarField():void {
			
			_starsList = new Array();
			_customMappingKeysList = new Array();
			_fieldDataS = new Array();
			_noiseData = new Array();
			_noisePixels = new ByteArray();
			_fieldPixels = new ByteArray();
			_lookupTable = new Array();
			_psfData = new Array();
			
			var startTimer:Number = getTimer();
			
			
			var w:int = 450;
			var h:int = 350;
			
			_width = w;
			_height = h;
			
			_fieldBMD = new BitmapData(w, h, false, 0xff0000);
			_fieldBM = new Bitmap(_fieldBMD);
			addChild(_fieldBM);
			
			_fieldRect = new Rectangle(0, 0, w, h);
			
			_numChunks = 0.7*w;
			_chunkSize = Math.ceil((w*h)/_numChunks);
			if ((_chunkSize%2)==1) _chunkSize += 1;
			
			_chunkTable = new Array(_numChunks);
			
			
			
			
			
			
			
			
			lock();
			
			bitDepth = 16;
			saturationMagnitude = 3;
			
			noiseMean = 0;
			noiseSigma = 5000;
			
			psfRadius = 15;
			
			generateNoise();
			generateLookupTable();
			generateNoisePixels();
			
			unlock();
			trace("constructor: "+(getTimer()-startTimer));
		}
		
		private var _record:Object = {totalTime2: 0, totalTime: 0, totalUpdates: 0};

		
		public function doUpdate():void {
			update();
		}
		
		private function update(...argsIgnored):void {
			if (_locked) {
				trace("let me in!");
				return;
			}
			
			var startTimer2:Number = getTimer();
			
			doTrace("");
			
			shuffleChunkTable();
			copyNoisePixels();
			
			var startTimer:Number;
			
			startTimer = getTimer();
			_fieldDataS = _noiseData.concat();
			doTrace("array copy time: "+(getTimer()-startTimer));
			
			
			startTimer = getTimer();
			// add the stars to the data array
			// f is the psf scaling factor for a star, left and top denote the position
			// of the upper left corner of the psf template for that star
			var i:int;
			var f:Number;
			var left:int;
			var top:int;
			var j:int;
			var k:int;
			var m:int;
			var p:int;
			var q:int;
			var x:int;
			var y:int;
			var v:Number;
			
			//var n:int = (_psfToUse=="new") ? (2*_psfRadius+1) : 2*_psfRadius;
			
			//var n:int = 2*_psfRadius;
			
			
			
			var u:Number;
			var psfCol:Array;
			
			var star:IStar;
			
			var sine:Number;
			var mag:Number;
			
			//var params:StarParamsObject;
			
			for (i=0; i<_starsList.length; i++) {
				star = _starsList[i];
				
				star.epoch = _epoch;
				
				
				//params = _starsList[i].getParamsObject(_epoch);
				
				//f = _peakValue*Math.pow(10, (_saturationMagnitude-params.magnitude)/2.5);
				//left = params.x - _psfX;
				//top = params.y - _psfY;
				
				
				f = _peakValue*Math.pow(10, (_saturationMagnitude - star.magnitude)/2.5);
				///left = star.x - _psfX;
				///top = star.y - _psfY;
				left = star.x - _psf.x;
				top = star.y - _psf.y;
				
				
				///for (j=0; j<_psfWidth; j++) {
				for (j=0; j<_psf.width; j++) {
					x = left + j;
					if (x<0) continue;
					else if (x>=_width) break;
					///psfCol = _psfData[j];
					psfCol = _psf.data[j];
					///for (k=0; k<_psfHeight; k++) {
					for (k=0; k<_psf.height; k++) {
						y = top + k;
						u = psfCol[k];
						if (u<=0 || y<0) continue;
						else if (y>=_height) break;
						m = x + y*_width;
						p = m/_chunkSize;
						q = m - p*_chunkSize;
						v = (_fieldDataS[int(q+_chunkSize*_chunkTable[p])] += f*u);
						if (v<0) v = 0;
						else if (v>_peakValue) v = _peakValue;
						_fieldPixels.position = 4*m;
						_fieldPixels.writeUnsignedInt(_lookupTable[int(v)]);
					}
				}
			}
			var bob:int = (getTimer()-startTimer);
			doTrace("section 2: "+bob);
			_record.totalTime2 += bob;
			
			_fieldPixels.position = 0;
			_fieldBMD.setPixels(_fieldRect, _fieldPixels);
			
			var t:Number = getTimer() - startTimer2;
			_record.totalUpdates += 1;
			_record.totalTime += t;
			trace("update: "+t);
			doTrace("average2: "+(_record.totalTime2/_record.totalUpdates));
			trace("average: "+(_record.totalTime/_record.totalUpdates));
						
			dispatchEvent(new Event("fieldUpdated"));
		}
		
		public function getColorFromValue(v:uint):uint {
			if (v<0) v = 0;
			else if (v>_peakValue) v = _peakValue;
			return _lookupTable[v];			
		}
		
		public function getInfoTest(xCenter:int, yCenter:int, r:uint):Object {
			
			var n:int = 2*r;
			
			var left:int = xCenter - r;
			var top:int = yCenter - r;
			
			
			var i:int;
			var j:int;
			var k:int;
			var m:int;
			var p:int;
			var q:int;
			var x:int;
			var y:int;
			var v:Number;
	
			
			var clipped:Boolean = false;
			var totalCounts:uint = 0;
			var totalPixels:uint = 0;
			
			var dx:int;
			var dy:int;
			var d2:int;
						
			var r2:Number = r*r;
				
			for (j=0; j<n; j++) {
				x = left + j;
				
				if (x<0) {
					clipped = true;
					continue;
				}
				else if (x>=_width) {
					clipped = true;
					break;
				}
				
				for (k=0; k<n; k++) {
					y = top + k;

					if (y<0) {
						clipped = true;
						continue;
					}
					else if (y>=_height) {
						clipped = true;
						break;
					}
					
					dx = x - xCenter;
					dy = y - yCenter;
					d2 = dx*dx + dy*dy;
					if (d2>r2) continue;
					
					m = x + y*_width;
					p = m/_chunkSize;
					q = m - p*_chunkSize;
					v = _fieldDataS[int(q+_chunkSize*_chunkTable[p])];
					if (v<0) v = 0;
					else if (v>_peakValue) v = _peakValue;
					
					totalCounts += v;
					totalPixels++;
				}
			}
			
			var obj:Object = {};
			
			obj.totalCounts = totalCounts;
			obj.totalPixels = totalPixels;
			obj.clipped = clipped;
			obj.average = obj.totalCounts/obj.totalPixels;
			
			return obj;			
		}
		
		public function getPixels(rect:Rectangle):Array {
			var startTimer:Number = getTimer();
			// - this function returns a two dimensional array of uint pixel values 
			//   for the specified region; parts of the region outside the field
			//   will have value 0x00000000 (note the alpha channel is zero, where
			//   it would normally be 0xff, unless a custom mapping key specifies otherwise)
			// - the region includes the top and left boundaries of the pixel, but not the 
			// right and bottom boundaries
			var pixels:Array = [];
			var i:int;
			var x:int;
			var y:int;
			var m:int;
			var p:int;
			var q:int;
			var v:Number;
			var col:Array;
			for (x=rect.left; x<rect.right; x++) {
				col = [];
				if (x<0 || x>=_width) {
					// the column is out of bounds
					for (i=0; i<rect.height; i++) col.push(uint(0x00000000));
				}
				else {
					for (y=rect.top; y<rect.bottom; y++) {
						if (y<0 || y>=_height) {
							// the pixel is out of bounds
							col.push(uint(0x00000000));
						}
						else {
							m = x + y*_width;
							p = m/_chunkSize;
							q = m - p*_chunkSize;
							v = _fieldDataS[int(q+_chunkSize*_chunkTable[p])];
							if (v<0) v = 0;
							else if (v>_peakValue) v = _peakValue;
							col.push(_lookupTable[int(v)]);
						}					
					}
				}
				pixels.push(col);				
			}
			doTrace("getPixels: "+(getTimer()-startTimer));
			return pixels;
		}
		
			
		public function getValue(x:int, y:int):uint {
			if (x<0 || x>=_width || y<0 || y>=_height) return 0; 
			var m:int = x + y*_width;
			var p:int = m/_chunkSize;
			var q:int = m - p*_chunkSize;
			var v:Number = _fieldDataS[int(q+_chunkSize*_chunkTable[p])];
			if (v<0) v = 0;
			else if (v>_peakValue) v = _peakValue;
			return uint(v);			
		}
		
		
		public function get noiseMean():Number {
			return _noiseMean;			
		}
		
		public function set noiseMean(arg:Number):void {
			_noiseMean = arg;
			
			generateNoise();
			generateNoisePixels();
			update();		
		}
		
		public function get noiseSigma():Number { 
			return _noiseSigma;		
		}
		
		public function set noiseSigma(arg:Number):void {
			_noiseSigma = arg;
			
			generateNoise();
			generateNoisePixels();
			update();
		}
		
		private var _epoch:Number = 0;
		private var _shuffleSeed:uint;
		
		
		
		
		
		
		
		
		
		
		
		public function get locked():Boolean {
			return _locked;
		}
		
		public function set locked(arg:Boolean):void {
			arg ? lock() : unlock();
		}
		
		public function lock():void {
			_fieldBM.visible = false;
			_locked = true;
		}
		
		public function unlock():void {
			_fieldBM.visible = true;
			_locked = false;
			update();		
		}
		
		
		public function addStar(star:IStar):void {
			star.addEventListener(Star.STAR_CHANGED, update);
			_starsList.push(star);
			update();
		}
		
		public function removeStar(star:IStar):Boolean {
			for (var i:int = 0; i<_starsList.length; i++) {
				if (star==_starsList[i]) {
					star.removeEventListener(Star.STAR_CHANGED, update);
					_starsList.splice(i, 1);
					update();
					return true;
				}
			}
			return false;
		}
		
		public function removeAllStars():void {
			for (var i:int = 0; i<_starsList.length; i++) {
				_starsList[i].removeEventListener(Star.STAR_CHANGED, update);
			}
			_starsList = [];
			update();
		}
		
		public function get saturationMagnitude():Number {
			return _saturationMagnitude;			
		}
		
		public function set saturationMagnitude(mag:Number):void {
			if (!isFinite(mag) || isNaN(mag)) throw new Error(StarField.SATURATION_MAGNITUDE_ERROR);
			_saturationMagnitude = mag;
			update();
		}
		
		public function get bitDepth():uint {
			return _bitDepth;			
		}
		
		public function set bitDepth(depth:uint):void {
			if (depth>16 || depth<2) throw new Error(StarField.BIT_DEPTH_ERROR);
			_bitDepth = depth;
			_peakValue = Math.pow(2, _bitDepth) - 1;
			
			generateLookupTable();
			generateNoisePixels();
			
			update();
		}
		
		public function get peakValue():uint {
			return _peakValue;			
		}
		
		public function set peakValue(arg:uint):void {
			throw new Error(StarField.PEAK_VALUE_ERROR);
		}
		
		public function get mappingMode():String {
			return _mappingMode;			
		}
		
		public function set mappingMode(arg:String):void {
			if (arg!=StarField.LINEAR && arg!=StarField.GAMMA) throw new Error(StarField.MAPPING_MODE_ERROR);
			_mappingMode = arg;
			generateLookupTable();
			generateNoisePixels();
			update();
		}
		
		public function get invertMapping():Boolean {
			return _invertMapping;			
		}
		
		public function set invertMapping(arg:Boolean):void {
			_invertMapping = arg;
			generateLookupTable();
			generateNoisePixels();
			update();		
		}
		
		public function get gamma():Number {
			return _gamma;
		}
		
		public function set gamma(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0) throw new Error(StarField.GAMMA_ERROR);
			_gamma = arg;
			if (_mappingMode==StarField.GAMMA) {
				generateLookupTable();
				generateNoisePixels();
				update();
			}
		}
		
		public function get epoch():Number {
			return _epoch;			
		}
		
		public function set epoch(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) throw new Error(StarField.EPOCH_ERROR);
			_epoch = arg;
			_shuffleSeed = 1 + 0x7ffffffe*Math.random();
			update();
		}
		
		public function get noiseSeed():uint {
			return _shuffleSeed;
		}
		
		public function set noiseSeed(seed:uint):void {
			if (!isFinite(seed) || isNaN(seed) || seed<1 || seed>0x7ffffffe) throw new Error(StarField.NOISE_SEED_ERROR);
			_shuffleSeed = seed;
			update();
		}
		
		public function setEpochAndNoiseSeed(e:Number, seed:uint):void {
			if (!isFinite(e) || isNaN(e)) throw new Error(StarField.EPOCH_ERROR);
			if (!isFinite(seed) || isNaN(seed) || seed<1 || seed>0x7ffffffe) throw new Error(StarField.NOISE_SEED_ERROR);
			_epoch = e;
			_shuffleSeed = seed;
			update();
		}
		
		
		
		
		
		
		
		public static const LINEAR:String = "linear";
		public static const GAMMA:String = "gamma";
		
		public static const NOISE_SEED_ERROR:String = "noiseSeed must be an integer between 1 and 0x7ffffffe (inclusive)";
		
		public static const EPOCH_ERROR:String = "epoch must be a finite number";
		
		public static const MAPPING_MODE_ERROR:String = "invalid mappingMode specified";
		
		public static const GAMMA_ERROR:String = "gamma must be a finite number greater than zero";
		public static const SATURATION_MAGNITUDE_ERROR:String = "saturationMagnitude must be a finite number";
		public static const BIT_DEPTH_ERROR:String = "bitDepth must be an integer between 2 and 16 (inclusive)";
		public static const PEAK_VALUE_ERROR:String = "peakValue is a read-only property, use bitDepth instead";
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		private function doTrace(...restParam) {
			return;
			trace(restParam);			
		}
		
		

		
		
		
		
		
		
		
		
		private var _customMappingKeysList:Array;
		
		public function addCustomMappingKey(value:int, color:uint):void {
			_customMappingKeysList.push({value: value, color: color});
			generateLookupTable();
			generateNoisePixels();
			update();		
		}
		
		public function removeCustomMappingKeys():void {
			_customMappingKeysList = [];			
			generateLookupTable();
			generateNoisePixels();
			update();		
		}
		
		
		
		
		
		
		
		
		
		
		
		
		private function generateLookupTable():void {
			// - this function generates a lookup table which takes a value (the index) and
			//   returns the corresponding uint (0xaarrggbb) pixel value
			var startTimer:Number = getTimer();
			
			var i:int;
			var g:int;
			var n:int = _peakValue + 1;
			var k:Number = 0xff/_peakValue;
			
			if (_invertMapping) {
				if (_mappingMode=="linear") {
					for (i=0; i<n; i++) {
						g = 0xff - int(k*i);
						_lookupTable[i] = uint(0xff000000 | (g << 16) | (g << 8) | g);						
					}
				}
				else if (_mappingMode=="gamma") {
					for (i=0; i<n; i++) {
						g = 0xff - 0xff*Math.pow(i/_peakValue, 1/_gamma);
						_lookupTable[i] = uint(0xff000000 | (g << 16) | (g << 8) | g);	
					}
				}
			}
			else {
				if (_mappingMode=="linear") {
					for (i=0; i<n; i++) {
						g = k*i;
						_lookupTable[i] = uint(0xff000000 | (g << 16) | (g << 8) | g);					
					}
				}
				else if (_mappingMode=="gamma") {
					for (i=0; i<n; i++) {
						g = 0xff*Math.pow(i/_peakValue, 1/_gamma);
						_lookupTable[i] = uint(0xff000000 | (g << 16) | (g << 8) | g);	
					}
				}
			}
			
			var key:Object;
			for (i=0; i<_customMappingKeysList.length; i++) {
				key = _customMappingKeysList[i];
				if (key.value>=0 && key.value<=_peakValue) {
					_lookupTable[key.value] = key.color;					
				}			
			}
			
			trace("generateLookupTable: "+(getTimer()-startTimer)+" ("+_mappingMode+")");
		}
		
		private function generateNoise():void {
			var startTimer:Number = getTimer();
			var f:Number;
			var x1:Number;
			var x2:Number;
			var i:int;
			var n:int = _numChunks*_chunkSize;
			var seed:uint = _noiseSeed;
			for (i=0; i<n; i++) {
				do {
					x1 = 2*(seed/2147483647) - 1;
					seed = (seed*16807)%2147483647;
					x2 = 2*(seed/2147483647) - 1;
					seed = (seed*16807)%2147483647;
					f = x1*x1 + x2*x2;
				} while (f>=1);
				f = Math.sqrt((-2*Math.log(f))/f);
				_noiseData[i] = _noiseMean + _noiseSigma*x1*f;
				_noiseData[++i] = _noiseMean + _noiseSigma*x2*f;
			}	
			doTrace("generateNoise: "+(getTimer()-startTimer));
		}
		
		private function generateNoisePixels():void {
			// - this function maps the values in the noise source array to an array of uint (0xaarrggbb)
			//   pixel values according to the current lookup table; the point of this is to save some
			//   time looking up pixel values since most of the field is unmodified noise
			var startTimer:Number = getTimer();
			var i:int;
			var v:int;
			var n:int = _numChunks*_chunkSize;
			_noisePixels.position = 0;
			for (i=0; i<n; i++) {
				v = _noiseData[i];
				if (v<0) v = 0;
				else if (v>_peakValue) v = _peakValue;
				_noisePixels.writeUnsignedInt(_lookupTable[int(v)]);
			}
			doTrace("generateNoisePixels: "+(getTimer()-startTimer));
		}
		
		private function shuffleChunkTable():void {
			// - this function shuffles the _chunkTable array, which specifies
			//   the order in which the noise chunks are assembled to create the
			//   noise background for a particular frame
			var startTimer:Number = getTimer();
			var i:int;
			var j:int;
			var tmp:int;
			var seed:uint = _shuffleSeed;//1 + 0x7ffffffe*Math.random();
			for (i=0; i<_numChunks; i++) _chunkTable[i] = i;
			for (i=0; i<_numChunks-1; i++) {
				j = i + int((_numChunks-i)*(seed/2147483647));
				seed = (seed*16807)%2147483647;
				tmp = _chunkTable[j];
				_chunkTable[j] = _chunkTable[i];
				_chunkTable[i] = tmp;
			}
			doTrace("generateChunkTable: "+(getTimer()-startTimer));
		}

		private function copyNoisePixels():void {
			var startTimer:Number = getTimer();
			var i:int;
			_fieldPixels.position = 0;
			var k:int = 4*_chunkSize;
			for (i=0; i<_numChunks; i++) {
				_noisePixels.position = k*_chunkTable[i];
				_noisePixels.readBytes(_fieldPixels, i*k, k);
			}
			doTrace("copyNoisePixels: "+(getTimer()-startTimer));
		}
		
		
		
		private var _psf:IPointSpreadFunction;
		
		public function get psf():IPointSpreadFunction {
			return _psf;
		}	
		
		public function set psf(arg:IPointSpreadFunction):void {
			_psf = arg;
			update();			
		}
		
		
		
		
		
		
		
		
		/*
		** psf code
		*/
		
		// - _psfData is a two-dimensional array of template values for the psf (values are between 0 and 1)
		// - _psfWidth and _psfHeight specify the dimensions of that array
		// - _psfX and _psfY specify the center of the psf with respect to the template's upper left pixel
		// - _usingCustomPSF declares whether the psf is a user provided custom psf or the default airy disc
		private var _psfData:Array;
		private var _psfWidth:int;
		private var _psfHeight:int;
		private var _psfX:int;
		private var _psfY:int;
		private var _usingCustomPSF:Boolean = false;
						
		
		public function get usingCustomPSF():Boolean {
			return _usingCustomPSF;			
		}
		
		public function set usingCustomPSF(arg:Boolean):void {
			// do nothing			
		}
		
		public function clearCustomPSF():void {
			// - this function gets rid of any custom psf that was specified and returns to the default psf
			_usingCustomPSF = false;
			generatePSFData();
			update();
		}
		
		public function setCustomPSF(psfArray:Array, xCenter:* = null, yCenter:* = null):void {
			// - this function lets the user define a custom psf by providing a two-dimensional
			//   array of values; these values should be Numbers between zero and one
			// - the optional xCenter and yCenter properties (which should be integers) can be used
			//   to specify where the center of the custom psf should be relative to the upper left
			//   corner of the psf template; if these values are not provided the center of the psf is used
			// - this function throws errors if it finds something wrong with the psfArray parameter
			var w:Number = psfArray.length;
			
			if (!(psfArray[0] is Array)) {
				throw new Error("the psfArray argument in setCustomPSF is not a valid two-dimensional array (psfArray[0] should be an array)");
			}
			
			var h:Number = psfArray[0].length;		
			
			var x:int;
			var y:int;
			
			// we make a copy of the array, checking the values as we go
			var copyArray:Array = [];
			var copyColumn:Array;
			
			var psfColumn:*;
			var v:*;

			for (x=0; x<w; x++) {
				psfColumn = psfArray[x];
				
				if (!(psfColumn is Array)) {
					throw new Error("the psfArray argument in setCustomPSF is not a valid two-dimensional array (psfArray["+x+"] should be an array)");
				}
				else if (psfColumn.length!=h) {
					throw new Error("the psfArray argument in setCustomPSF is not a valid two-dimensional array (all columns should have the same length, psfArray["+x+"] does not have the same length as the first column)");
				}
				
				copyColumn = [];
				
				for (y=0; y<h; y++) {
					v = psfColumn[y];
					
					// allow a bit of margin for round-off error
					if (v>1 && v<(1+1e-12)) v = 1;
					
					if (!(v is Number)) {
						throw new Error("the psfArray argument in setCustomPSF has an invalid value (all values should be of type Number, psfArray["+x+"]["+y+"] is not)"); 
					}					
					else if (v>1) {
						throw new Error("the psfArray argument in setCustomPSF has an invalid value (all values should be less than or equal to 1, psfArray["+x+"]["+y+"] is not)"); 
					}
					
					copyColumn[y] = v;					
				}
				
				copyArray[x] = copyColumn;
			}
			
			_psfData = copyArray;
			
			if (xCenter is Number) _psfX = int(xCenter);
			else _psfX = int(w/2);
			
			if (yCenter is Number) _psfY = int(yCenter);
			else _psfY = int(h/2);
			
			_psfWidth = w;
			_psfHeight = h;
			
			_usingCustomPSF = true;
		}
		
		public function get psfRadius():uint {
			return _psfRadius;
		}
		
		public function set psfRadius(radius:uint):void {
			// - the psfRadius property sets the radius of the default psf (the airy disc) in 
			//   pixels; it has no effect if a custom psf is being used
			_psfRadius = radius;
			if (!_usingCustomPSF) {
				generatePSFData();
				update();
			}
		}
		
		private function generatePSFData():void {
			// - this function generates the default PSF, which is an airy disc out to the first trough;
			//   the formula used is 4*(J1(r)/r)^2 out to r = 3.831705970256774
			var i:int;
			var j:int;
			var k:int = _psfRadius - 1;
			var r2:Number;
			var J1_r:Number;
			var x:Number;
			var y:Number;
			var a:Number;
			var n:int = 2*_psfRadius - 1;
			var scale:Number = 3.831705970256774/_psfRadius;
			_psfData = [];
			for (i=0; i<n; i++) _psfData[i] = [];
			// the way this works is to determine the values in a 45° slice and then mirror them into the array
			for (i=0; i<_psfRadius; i++) {
				x = scale*i;
				for (j=0; j<=i; j++) {
					y = scale*j;
					r2 = x*x + y*y;
					if (r2>=14.681970642501405) a = 0;
					else {
						J1_r = getJ1(Math.sqrt(r2));
						a = 4*J1_r*J1_r/r2;
					}
					_psfData[k+i][k-j] = a;
					_psfData[k+j][k-i] = a;
					_psfData[k-j][k-i] = a;
					_psfData[k-i][k-j] = a;
					_psfData[k-i][k+j] = a;
					_psfData[k-j][k+i] = a;
					_psfData[k+j][k+i] = a;
					_psfData[k+i][k+j] = a;
				}
			}
			_psfData[k][k] = 1;
			_psfX = k;
			_psfY = k;
			_psfWidth = n;
			_psfHeight = n;
		}
		
				
		
		private function getJ1(x:Number):Number {
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
