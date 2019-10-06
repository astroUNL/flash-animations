package {
	
	public class StarField {
		
		private var _width:Number;
		private var _height:Number;
		
		// pointSpread and fieldData are used for arrays, not as bitmaps to be displayed
		private var _psfBMD:BitmapData;
		
		private var _psfData:Array;
		private var _noiseData:Array; 
		private var _fieldData:Array; // noise plus stars
		
	//	private var _fieldBMD:BitmapData;
	//	private var _fieldBM:Bitmap;
		
		public function StarField(initObj:* = undefined):void {
			if (initObj is Object) {
				if ((initObj.width is Number) && (initObj.height is Number)) setDimensions(initObj.width, initObj.height);
				else setDimensions(300, 300);				
			}
			
		}
		
		
		private function clearField():void {
			var startTimer:Number = getTimer();
			var i:Number, j:Number;
			var w:Number = _width;
			var h:Number = _height;
			for (i=0; i<w; i++) {
				column = _fieldData[i];
				for (j=0; j<h; j++) column[j] = 0;				
			}			
			trace("clearFieldData: "+(getTimer()-startTimer));
		}
		
		private function calculateNoise(mean:Number, sigma:Number, seed:uint):void {
			var startTimer:Number = getTimer();
			var i:Number, j:Number;
			var f:Number, x1:Number, x2:Number;
			var w:Number = _width;
			var h:Number = _height;
			if ((h%2)==1) h += 1;
			for (i=0; i<w; i++) {
				column = _noiseData[i];
				for (j=0; j<h; j+=2) {
					do {
						x1 = 2*(seed/2147483647) - 1;
						seed = (seed*16807)%2147483647;
						x2 = 2*(seed/2147483647) - 1;
						seed = (seed*16807)%2147483647;
						f = x1*x1 + x2*x2;
					} while (f>=1);
					f = Math.sqrt((-2*Math.log(f))/f);
					column[j] = mean + sigma*x1*f;
					column[j+1] = mean + sigma*x2*f;
				}
			}
			trace("calculateNoise: "+(getTimer()-startTimer));
		}
		
		private function calculateFieldData():void {
			
			// steps:
			//  1 - clear the data array
			//  2 - 
			
			
			
		}
		
		public function setDimensions(width:Number, height:Number):void {
			_width = width;
			_height = height;
			_fieldBMD = new BitmapData(_width, _height, false, 0xffffff);
			_fieldDataBMD = new BitmapData(_width, _height, true, 0xffffffff);
		}
	}	
}