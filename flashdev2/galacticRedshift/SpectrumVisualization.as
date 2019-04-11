
package {
	
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	
	public class SpectrumVisualization extends Spectrum {
		
		protected var _bmd:BitmapData;
		protected var _bm:Bitmap;
		protected var _intensities:Vector.<Number>;
		protected var _contentRect:Rectangle;
		
		
		public function SpectrumVisualization(w:Number, h:Number, data:Array, minW:Number, maxW:Number, maxF:Number) {
			super(w, h, data, minW, maxW, maxF);
			
			_bmd = new BitmapData(_width, _height, false, 0x0);
			_bm = new Bitmap(_bmd);
			_bm.y = -_height;
			_content.addChild(_bm);
			
			_intensities = new Vector.<Number>(_bmd.width);
			
			_contentRect = new Rectangle(0, -_height, _width, _height);
			
			redraw();
		}
		
		protected function colorFromWavelengthAndIntensity(wavelength:Number, intensity:Number):uint {
			
			var f:Number = (wavelength - 400)/300;
			if (f<0 || f>1) return 0x000000;
			
			f *= 256;
			
			var colors:Array = [0x000000, 0x0000FF, 0x00FFFF, 0x00FF00, 0xFFFF00, 0xFF0000, 0x000000];
			var ratios:Array = [0, 48, 96, 128, 160, 207, 256];
			
			var color:uint = 0x000000;
			
			var u:Number;
			var r:int, g:int, b:int;
			
			var i:int;
			for (i=1; i<ratios.length; i++) {
				if (f<=ratios[i]) {
					
					u = (f - ratios[i-1])/(ratios[i] - ratios[i-1]);
					
					r = int(intensity*(((colors[i-1]>>16)&0xff) + u*(((colors[i]>>16)&0xff) - ((colors[i-1]>>16)&0xff))));
					if (r<0) r = 0;
					else if (r>0xff) r = 0xff;
					
					g = int(intensity*(((colors[i-1]>>8)&0xff) + u*(((colors[i]>>8)&0xff) - ((colors[i-1]>>8)&0xff))));
					if (g<0) g = 0;
					else if (g>0xff) g = 0xff;
					
					b = int(intensity*((colors[i-1]&0xff) + u*((colors[i]&0xff) - (colors[i-1]&0xff))));
					if (b<0) b = 0;
					else if (b>0xff) b = 0xff;
					
					color = (r<<16) | (g<<8) | b;
					
					break;
				}
			}
			
			return color;
		}
		
		public static const visualMin:Number = 400;
		public static const visualMax:Number = 700;
		
		override public function redraw():void {			
			super.redraw();
			
			var i:int, j:int;
			
			_bmd.fillRect(_contentRect, 0x0);
			
			for (i=0; i<_intensities.length; i++) _intensities[i] = 0;
			
			var nmPerPx:Number = (_maxW-_minW)/_bmd.width;
			
			var xScale:Number = _width/(_maxW-_minW);
			var k:Number = _redshift + 1;
						
			var xCurr:Number, xNext:Number;
			var xLeft:Number, xRight:Number;
			
			var f:Number;
			var fScale:Number = (_maxF - _minF);
						
			var range:Number;
			var pxLeft:Number, pxRight:Number;
			var pxLeftF:Number, pxRightF:Number;
			var px:Number;
			var fPerPx:Number;
			
			var case1:int = 0;
			var case2:int = 0;
			
			for (i=0; i<_data.length; i++) {
				if (i==0) {
					xCurr = xScale*(k*_data[i].w - _minW);
					xNext = xScale*(k*_data[i+1].w - _minW);
					xRight = (xCurr + xNext)/2;
					xLeft = xCurr - (xRight - xCurr)/2;
				}
				else if (i==_data.length-1) {
					xCurr = xNext;
					xLeft = xRight;
					xRight = xCurr + (xCurr - xLeft)/2;
				}
				else {
					xCurr = xNext;
					xLeft = xRight;					
					xNext = xScale*(k*_data[i+1].w - _minW);
					xRight = (xCurr + xNext)/2;
				}
				
				f = fScale*(_data[i].f-_minF);
				if (f>1) f = 1;
				else if (f<0) f = 0;
				
				range = xRight - xLeft;
				pxLeft = Math.floor(xLeft);
				pxRight = Math.floor(xRight);
				
				fPerPx = f/range;
				
				if (pxRight<0 || pxLeft>=_intensities.length) continue;
				
				if (pxLeft==pxRight) {
					case1++;
					if (pxLeft>=0 && pxLeft<_intensities.length) _intensities[pxLeft] += f;
				}
				else {
					case2++;
					if (pxLeft>=0 && pxLeft<_intensities.length) _intensities[pxLeft] += (1-(xLeft-pxLeft))*fPerPx;
					if (pxRight>=0 && pxRight<_intensities.length) _intensities[pxRight] += (xRight-pxRight)*fPerPx;
					for (px=pxLeft+1; px<pxRight; px++) {
						if (px>=0 && px<_intensities.length) _intensities[px] += fPerPx;
					}
				}
			}
			
			var column:Rectangle = new Rectangle(0, 0, 1, _bmd.height);
			
			var maxIntensity:Number = Number.NEGATIVE_INFINITY;
			for (i=0; i<_intensities.length; i++) if (_intensities[i]>maxIntensity) maxIntensity = _intensities[i];
						
			var wavelengthStep:Number = (_maxW - _minW)/_bmd.width;
			
			var wavelength:Number = _minW + wavelengthStep/2;
			for (i=0; i<_intensities.length; i++) {
				column.x = i;
				_bmd.fillRect(column, colorFromWavelengthAndIntensity(wavelength, _intensities[i]/maxIntensity));
				wavelength += wavelengthStep;
			}
			
		}
				
	}
}
