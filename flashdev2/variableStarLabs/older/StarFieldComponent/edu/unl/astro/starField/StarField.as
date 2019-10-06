
package edu.unl.astro.starField {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.ByteArray;
	import flash.events.Event;

	public class StarField extends Sprite {
		
		// Comment: probably the most confusing part of this component is the way the data structures are
		// handled, particularly in how some of the arrays are shuffled. The reason for all this confusion
		// is speed. 
		
		// First we start with the noise. Since it is costly to generate noise we create it just once (after
		// the mean and sigma are chosen), in the generateNoise function, and store it as numbers in the
		// noiseData array. The length of this array is at least as great as the number of pixels. To
		// simulate new noise we reshuffle this array like a pack of cards. In this case the 'cards' are
		// called 'chunks', the number of chunks being chosen so that there are enough pixels per chunk to
		// gain efficiency but not so much that one can notice patterns repeating in the noise. A chunk size
		// that is 0.7 times the width seems to work well. Once the chunk size is determined the number of
		// chunks is chosen so that the chunk size times the number of chunks is greater than or equal to
		// the number of pixels. (One caveat: since the noise generation algorithm produces values in pairs
		// we make sure the chunk size is even.)
		
		// The order of the chunks is determined in the shuffleChunkTable function and stored in the
		// chunkTable array. The shuffling is random but is seeded so that it can be reproduced exactly.
		// The seed is called 'shuffleSeed' internally but 'noiseSeed' to the outside world.
		
		
		
		
		
		private var _width:Number;
		private var _height:Number;
		private var _fieldBMD:BitmapData;
		private var _fieldBM:Bitmap;
		private var _fieldRect:Rectangle;
		
		private var _epoch:Number = 0;
		private var _shuffleSeed:uint = 1;
		private var _noiseMean:Number;
		private var _noiseSigma:Number;
		private var _saturationMagnitude:Number;
		private var _bitDepth:uint;
		private var _peakValue:Number;
		private var _locked:Boolean = false;
		
		private var _starsList:Array;
		private var _transferFunction:ITransferFunction;
		private var _psf:IPSF;
		
		// noiseData is an array of the noise values that were calculated when
		// the noise parameters were specified; it can be divided into numChunks segments
		// each of which has chunkSize values
		private var _noiseData:Array;
		
		// noisePixels is a byte array consisting of 0xAARRGGBB (uint) pixel values
		// corresponding to the values in noiseSource mapped according to the current transfer function
		private var _noisePixels:ByteArray;
		
		// fieldData is a byte array consisting of the field data (ie. the counts) 
		// in *floating point* format
		private var _fieldData:Array;
		
		// fieldPixels is a byte array consisting of the values in noisePixels after being shuffled
		// according to the chunkTable array
		private var _fieldPixels:ByteArray;		
		
		// 'chunks' are the blocks of random noise are that are reshuffled to simulate fresh noise;
		// see the extended comment at the top for more information
		private var _numChunks:int;
		private var _chunkSize:int;
		private var _chunkTable:Array;		
		
		// these are the names of events that star field component listens for, or broadcasts in the
		// case of "fieldChanged"
		public static const TRANSFER_FUNCTION_CHANGED:String = "transferFunctionChanged";
		public static const STAR_CHANGED:String = "starChanged";
		public static const PSF_CHANGED:String = "psfChanged";
		public static const FIELD_CHANGED:String = "fieldChanged";
		
		// the outOfBoundsColor is the color that is reported by the getPixelInfo and getPixelColors
		// functions for pixels that are out of the bounds of the field
		public var outOfBoundsColor:uint = 0x00ffcc00;
		
		
		public function StarField():void {
			
			_starsList = new Array();
			_fieldData = new Array();
			_noiseData = new Array();
			_noisePixels = new ByteArray();
			_fieldPixels = new ByteArray();
			
			trace("\n");
			
			var startTimer:Number = getTimer();
			
			
			lock();
			
			dimensions = {width: 450, height: 350};
			
			bitDepth = 16;
			saturationMagnitude = 3;
			
			noiseMean = 0;
			noiseSigma = 1000;
			
			unlock();
			
			trace("constructor: "+(getTimer()-startTimer)+"\n");
		}
		
		
		
		
		
		
	
		
		
		
		
		
		
		
		
				
		
		
		
		
		
		
		private var totalUpdates:int = 0;
		private var totalUpdateTime:int = 0;
		
		
		
		
		/*
		** Private Utility Functions
		*/
		
		
		private var _callGenerateNoise:Boolean = false;
		private var _callGenerateNoisePixels:Boolean = false;
		private var _callShuffleNoise:Boolean = false;
											
		private function update(...argsIgnored):void {
			if (_locked || _transferFunction==null || _psf==null) return;
			
			
			if (_callGenerateNoise) generateNoise();
			if (_callGenerateNoisePixels) generateNoisePixels();
			/*if (_callShuffleNoise) shuffleNoise();
			*/
			
			var startTimer:Number = getTimer();
			//generateNoisePixels();
			shuffleNoise();			
			trace("preliminaries: "+(getTimer()-startTimer));
			
			startTimer = getTimer();
			
			// make a fresh copy of the noise data array
			_fieldData = _noiseData.concat();
			
			var star:IStar;
			var psfCol:Array;
			
			// left an top denote the position of the upper left corner of the psf template for a star
			var left:int;
			var top:int;
			
			// f is the psf scaling factor for a given star
			var f:Number;
			
			// x and y are the field coordinates for a given point corresponding to template coordinates j and k
			var x:int;
			var y:int;
			
			// m, p, and q are used to get the corresponding point in the scrambled field data array
			var m:int;
			var p:int;
			var q:int;
			
			// u is the value of the psf template at a given point and v is the value of the 
			// star field at that given point (after adding the psf contribution for the star)
			var u:Number;
			var v:Number;
			
			// now we are ready to go through the stars list and add each to the star field
			for (var i:int = 0; i<_starsList.length; i++) {
				star = _starsList[i];
				star.epoch = _epoch;
				f = _peakValue*Math.pow(10, (_saturationMagnitude - star.magnitude)/2.5);
				left = star.x - _psf.x;
				top = star.y - _psf.y;
				
				// now go through the pixels of the psf template and scale and place the values for the given star
				for (var j:int = 0; j<_psf.width; j++) {
					x = left + j;
					if (x<0) continue;
					else if (x>=_width) break;
					psfCol = _psf.data[j];
					for (var k:int = 0; k<_psf.height; k++) {
						y = top + k;
						u = psfCol[k];
						if (u<=0 || y<0) continue;
						else if (y>=_height) break;
						m = x + y*_width;
						p = m/_chunkSize;
						q = m - p*_chunkSize;
						v = (_fieldData[int(q+_chunkSize*_chunkTable[p])] += f*u);
						if (v<0) v = 0;
						else if (v>_peakValue) v = _peakValue;
						_fieldPixels.position = 4*m;
						_fieldPixels.writeUnsignedInt(_transferFunction.getColor(uint(v)));
					}
				}
			}
			
			// now update the bitmap with the new field pixel values
			_fieldPixels.position = 0;
			_fieldBMD.setPixels(_fieldRect, _fieldPixels);
			
			
			
			
			
			var t:Number = getTimer() - startTimer;
			totalUpdateTime += t;
			totalUpdates++;
			
			trace("update: "+t);
			trace("average: "+(totalUpdateTime/totalUpdates));
			
			
			dispatchEvent(new Event(StarField.FIELD_CHANGED));

		}
		
		private function update2(...ignored):void {
			// - this function is called when the transfer function changes
			
			_callGenerateNoisePixels = true;
			_callShuffleNoise = true;
			
			update();
		}
				
		private function generateNoise():void {
			// - this function generates a source array of noise; this same noise source will be
			//   reused continuously by scrambling it for each new field			
			var startTimer:Number = getTimer();
			var f:Number;
			var x1:Number;
			var x2:Number;
			var i:int;
			var n:int = _numChunks*_chunkSize;
			var seed:uint = 1;
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

			_callGenerateNoise = false;
			
			trace("generateNoise: "+(getTimer()-startTimer));
		}
		
		private function generateNoisePixels():void {
			
			if (_transferFunction==null) return;
			
			// - this function maps the values in the noise source array to an array of uint (0xaarrggbb)
			//   pixel values according to the current transfer function; the point of this is to save some
			//   time looking up pixel values since most of any field is unmodified noise
			var startTimer:Number = getTimer();
			var i:int;
			var v:int;
			var n:int = _numChunks*_chunkSize;
			_noisePixels.position = 0;
			for (i=0; i<n; i++) {
				v = _noiseData[i];
				if (v<0) v = 0;
				else if (v>_peakValue) v = _peakValue;
				_noisePixels.writeUnsignedInt(_transferFunction.getColor(uint(v)));
			}
			
			_callGenerateNoisePixels = false;

			trace("generateNoisePixels: "+(getTimer()-startTimer));
		}
		
		private function shuffleNoise():void {
			// - this function shuffles the _chunkTable array, which specifies
			//   the order in which the noise chunks are assembled to create the
			//   noise background for a particular frame; then it copies the noise
			//   pixel values (in the array _noisePixels) into the _fieldPixels
			//   array according to the order specified by _chunkTable
			var startTimer:Number = getTimer();
			var i:int;
			var j:int;
			var tmp:int;
			var seed:uint = _shuffleSeed;
			for (i=0; i<_numChunks; i++) _chunkTable[i] = i;
			for (i=0; i<_numChunks-1; i++) {
				j = i + int((_numChunks-i)*(seed/2147483647));
				seed = (seed*16807)%2147483647;
				tmp = _chunkTable[j];
				_chunkTable[j] = _chunkTable[i];
				_chunkTable[i] = tmp;
			}
			
			// now copy the source noise pixel values 
			_fieldPixels.position = 0;
			var k:int = 4*_chunkSize;
			for (i=0; i<_numChunks; i++) {
				_noisePixels.position = k*_chunkTable[i];
				_noisePixels.readBytes(_fieldPixels, i*k, k);
			}
			
			_callShuffleNoise = false;
	
			trace("shuffleNoise: "+(getTimer()-startTimer));
		}
		
		/*
		** Public Utility Functions
		*/
				
		public function getStatistics(pMask:IPixelMask):Object {
			// given a pixel mask object, this function returns an object with the following properties:
			//   totalCounts - the number of counts for every pixel covered by the mask
			//   totalPixels - the number of pixels covered by the mask that are in the field
			//   clipped - a Boolean indicating whether there are pixels that are part of the mask
			//             but not part of the field (ie. the mask is over the edge of the image)
			//   average - the average counts per pixel covered by the mask: totalCounts/totalPixels 
			var j:int;
			var k:int;
			var x:int;
			var y:int;
			var m:int;
			var p:int;
			var q:int;
			var v:Number;
			var clipped:Boolean = false;
			var totalCounts:uint = 0;
			var totalPixels:uint = 0;
			for (j=0; j<pMask.width; j++) {
				x = pMask.left + j;
				if (x<0) {
					clipped = true;
					continue;
				}
				else if (x>=_width) {
					clipped = true;
					break;
				}
				for (k=0; k<pMask.height; k++) {
					y = pMask.top + k;
					if (y<0) {
						clipped = true;
						continue;
					}
					else if (y>=_height) {
						clipped = true;
						break;
					}
					if (pMask.data[j][k]) {
						m = x + y*_width;
						p = m/_chunkSize;
						q = m - p*_chunkSize;
						v = _fieldData[int(q+_chunkSize*_chunkTable[p])];
						if (v<0) v = 0;
						else if (v>_peakValue) v = _peakValue;
						totalCounts += uint(v);
						totalPixels++;
					}
				}
			}
			var obj:Object = {};
			obj.totalCounts = totalCounts;
			obj.totalPixels = totalPixels;
			obj.clipped = clipped;
			obj.average = obj.totalCounts/obj.totalPixels;
			return obj;			
		}
		
		public function getPixelColors(rect:Rectangle):Array {
			// - this function returns a two dimensional array of uint pixel values 
			//   for the specified region; parts of the region outside the field
			//   will have value outOfBoundsColor
			// - the region includes the top and left pixels of the rectangle, but not the 
			//   right and bottom limits
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
					for (i=0; i<rect.height; i++) col[i] = outOfBoundsColor;
				}
				else {
					for (y=rect.top; y<rect.bottom; y++) {
						if (y<0 || y>=_height) {
							// the pixel is out of bounds
							col.push(outOfBoundsColor);
						}
						else {
							m = x + y*_width;
							p = m/_chunkSize;
							q = m - p*_chunkSize;
							v = _fieldData[int(q+_chunkSize*_chunkTable[p])];
							if (v<0) v = 0;
							else if (v>_peakValue) v = _peakValue;
							col.push(_transferFunction.getColor(int(v)));
						}					
					}
				}
				pixels.push(col);				
			}
			return pixels;
		}
		
		public function getPixelInfo(pt:Point):Object {
			// - this function can be used to get the counts and color for a given pixel; the function
			//   returns an object with the following properties:
			//      counts:int - the number of counts for the pixel; it will be -1 if the given
			//                   pixel is outside the bounds of the field
			//      color:uint - the color the pixel according to the lookup table
			if (pt.x<0 || pt.x>=_width || pt.y<0 || pt.y>=_height) {
				return {counts: int(-1), color: outOfBoundsColor};
			}
			var m:int = pt.x + pt.y*_width;
			var p:int = m/_chunkSize;
			var q:int = m - p*_chunkSize;
			var v:Number = _fieldData[int(q+_chunkSize*_chunkTable[p])];
			if (v<0) v = 0;
			else if (v>_peakValue) v = _peakValue;
			return {counts: int(v), color: _transferFunction.getColor(int(v))};
		}
		
		
		/*
		** Transfer Function Functions
		*/
		
		public function get transferFunction():ITransferFunction {
			return _transferFunction;
		}
		
		public function set transferFunction(arg:ITransferFunction):void {
			if (_transferFunction!=null) _transferFunction.removeEventListener(StarField.TRANSFER_FUNCTION_CHANGED, update2);
			_transferFunction = arg;
			// (let the transfer function know what the current peak value is)
			_transferFunction.peakValue = _peakValue;			
			_transferFunction.addEventListener(StarField.TRANSFER_FUNCTION_CHANGED, update2);
			update2();
		}
		
		
		/*
		** PSF Functions
		*/
		
		public function get psf():IPSF {
			return _psf;
		}	
		
		public function set psf(arg:IPSF):void {			
			if (_psf!=null) _psf.removeEventListener(StarField.PSF_CHANGED, update);
			_psf = arg;
			_psf.addEventListener(StarField.PSF_CHANGED, update);
			update();			
		}
		
		
		/*
		** Public Star Management Functions
		*/
		
		public function addStar(star:IStar):void {
			// - this function adds a star to the field
			star.addEventListener(StarField.STAR_CHANGED, update);
			_starsList.push(star);
			update();
		}
		
		public function removeStar(star:IStar):Boolean {
			// - this function removes a particular star from the field
			// - if the star was found and removed it returns true, otherwise false
			for (var i:int = 0; i<_starsList.length; i++) {
				if (star==_starsList[i]) {
					star.removeEventListener(StarField.STAR_CHANGED, update);
					_starsList.splice(i, 1);
					update();
					return true;
				}
			}
			return false;
		}
		
		public function removeAllStars():void {
			// - this function removes all stars from the field
			for (var i:int = 0; i<_starsList.length; i++) {
				_starsList[i].removeEventListener(StarField.STAR_CHANGED, update);
			}
			_starsList = [];
			update();
		}
		
		
		/*
		** Public Properties (getter/setters) and Associated Functions
		*/
		
		public function set dimensions(arg:Object):void {
			if (!(arg.width is Number) || !(arg.height is Number) || !isFinite(arg.width) || isNaN(arg.width) ||
				!isFinite(arg.height) || isNaN(arg.height) || arg.width==0 || arg.width>2000 || arg.height==0 || arg.height>2000) return;
		
			_width = uint(arg.width);
			_height = uint(arg.height);
			
			if (_fieldBM!=null) removeChild(_fieldBM);
			
			_fieldBMD = new BitmapData(_width, _height, false, 0xff0000);
			_fieldBM = new Bitmap(_fieldBMD);
			addChild(_fieldBM);
			
			_fieldRect = new Rectangle(0, 0, _width, _height);
			
			_numChunks = 0.7*_width;
			_chunkSize = Math.ceil((_width*_height)/_numChunks);
			if ((_chunkSize%2)==1) _chunkSize += 1;
			
			_chunkTable = new Array(_numChunks);
			
			_callGenerateNoise = true;
			_callGenerateNoisePixels = true;
			_callShuffleNoise = true;
						
			update();		
		}

		public function get dimensions():Object {
			// this function returns an object with width and height properties
			return {width: _width, height: _height};
		}
		
		// the epoch is the time associated with the field, expressed in days; every time the epoch
		// property is set the background noise is randomly reshuffled, that is, the property
		// noiseSeed takes a new value; use the setEpochAndNoiseSeed function to set both properties
		// at the same time (e.g. you want to recreate a field to be exactly the same);
		// note that noiseSeed must be in the range [1, 0x7ffffffe] inclusive
		
		public function get epoch():Number {
			return _epoch;			
		}
		
		public function set epoch(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_epoch = arg;
			_shuffleSeed = 1 + 0x7ffffffe*Math.random();
			
			_callShuffleNoise = true;
			
			update();
		}
		
		public function get noiseSeed():uint {
			return _shuffleSeed;
		}
		
		public function set noiseSeed(seed:uint):void {
			if (!isFinite(seed) || isNaN(seed) || seed<1 || seed>0x7ffffffe) return;
			_shuffleSeed = seed;
			
			_callShuffleNoise = true;
			
			update();
		}
		
		public function setEpochAndNoiseSeed(e:Number, seed:uint):void {
			if (!isFinite(e) || isNaN(e)) return;
			if (!isFinite(seed) || isNaN(seed) || seed<1 || seed>0x7ffffffe) return;
			_epoch = e;
			_shuffleSeed = seed;
			
			_callShuffleNoise = true;
			
			update();
		}
		
		// the noise mean is the value, in counts, around which the noise values are centered
		// (the noise follows a gaussian distribution)
		
		public function get noiseMean():Number {
			return _noiseMean;			
		}
		
		public function set noiseMean(arg:Number):void {
			_noiseMean = arg;
			
			_callGenerateNoise = true;
			_callGenerateNoisePixels = true;
			_callShuffleNoise = true;
						
			update();		
		}
		
		// the noise sigma controls the spread of the noise values around the noise mean
		// (the noise follows a gaussian distribution)
		
		public function get noiseSigma():Number { 
			return _noiseSigma;		
		}
		
		public function set noiseSigma(arg:Number):void {
			_noiseSigma = arg;
			
			_callGenerateNoise = true;
			_callGenerateNoisePixels = true;
			_callShuffleNoise = true;
			
			update();
		}
		
		// the saturation magnitude is the magnitude at which values of 1 in the
		// psf template will be mapped to the peak value	
		
		public function get saturationMagnitude():Number {
			return _saturationMagnitude;
		}
		
		public function set saturationMagnitude(mag:Number):void {
			if (!isFinite(mag) || isNaN(mag)) return;
			_saturationMagnitude = mag;
			update();
		}
		
		// the bit depth is the number of bits of resolution for each pixel in the field;
		// it relates to the peak value (a read only property) by the formula peakValue = 2^bitDepth - 1
		
		public function get bitDepth():uint {
			return _bitDepth;
		}
		
		public function set bitDepth(depth:uint):void {
			if (depth>16 || depth<2) return;
			_bitDepth = depth;
			_peakValue = Math.pow(2, _bitDepth) - 1;
			if (_transferFunction!=null) _transferFunction.peakValue = _peakValue;
			// note that no update functions need to be called here since changing the
			// peak value of the transfer function causes it to dispatch an event
			// that will in turn cause the update2() function to be called
		}
		
		public function get peakValue():uint {
			return _peakValue;
		}
		
		// when locked the field is not updated after changes; it's a way of making bulk changes efficiently;
		// the updates take place at unlocking
		
		public function get locked():Boolean {
			return _locked;
		}
		
		public function set locked(arg:Boolean):void {
			arg ? lock() : unlock();
		}
		
		public function lock():void {
			if (_fieldBM!=null) _fieldBM.visible = false;
			_locked = true;
		}
		
		public function unlock():void {
			if (_fieldBM!=null) _fieldBM.visible = true;
			_locked = false;
			update();
		}
		
	}
}
