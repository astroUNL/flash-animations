
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	
	
	public class SpectrumGraph extends Spectrum {
		
		
		protected var _filterSet:Array;
		
		
		protected var _filters:Shape;
		protected var _curve:Shape;
		protected var _tickmarks:Sprite;
		
		// the point of the observedFluxes array (and the other 'observed' variables) is to provide an
		// efficient way to look up the redshifted fluxes for the filters code
		protected var _observedMinWavelength:int;
		protected var _numObservedWavelengths:int;
		protected var _observedWavelengthResolution:Number = 1;
		protected var _observedFluxes:Vector.<Number>;
		
		public function SpectrumGraph(w:Number, h:Number, data:Array, minW:Number, maxW:Number, maxF:Number, filterSet:Array) {
			super(w, h, data, minW, maxW, maxF);
			_filterSet = filterSet;
			
			_filters = new Shape();
			_content.addChild(_filters);
			
			_curve = new Shape();
			_content.addChild(_curve);
			
			
			var iMin:int = Math.floor(minW/_observedWavelengthResolution);
			var iMax:int = Math.ceil(maxW/_observedWavelengthResolution);
			
			_observedMinWavelength = iMin*_observedWavelengthResolution;
			_numObservedWavelengths = iMax - iMin + 1;
			
			_observedFluxes = new Vector.<Number>(_numObservedWavelengths);
			
			redraw();
		}
		
		protected var _lineThickness:Number = 0;
		protected var _lineColor:uint = 0x000000;
		protected var _lineAlpha:Number = 1;
		
		override public function redraw():void {
			
			super.redraw();
			
			for (i=0; i<_numObservedWavelengths; i++) _observedFluxes[i] = Number.NaN;				
			
			var xScale:Number = _width/(_maxW-_minW);
			var yScale:Number = -_height/(_maxF-_minF);
			var k:Number = _redshift + 1;
			
			var index:int;
			var wShifted:Number;
			var i:int;
			
			wShifted = k*_data[0].w;
			
			index = Math.round((wShifted-_observedMinWavelength)/_observedWavelengthResolution);
			if (index>=0 && index<_numObservedWavelengths) _observedFluxes[index] = _data[0].f;
			
			_curve.graphics.clear();
			_curve.graphics.lineStyle(_lineThickness, _lineColor, _lineAlpha);
			_curve.graphics.moveTo(xScale*(wShifted-_minW), yScale*(_data[0].f-_minF));
			
			var nx:Number, ny:Number;	
			
			for (i=1; i<_data.length; i++) {
				wShifted = k*_data[i].w;
				
				index = Math.round((wShifted-_observedMinWavelength)/_observedWavelengthResolution);
				if (index>=0 && index<_numObservedWavelengths) _observedFluxes[index] = _data[i].f;
				
				_data[i].wShifted = wShifted;
				nx = xScale*(wShifted-_minW);
				ny = yScale*(_data[i].f-_minF);
				if (nx<0) _curve.graphics.moveTo(nx, ny);
				else if (nx<_width) _curve.graphics.lineTo(nx, ny);
				else {
					_curve.graphics.lineTo(nx, ny);
					break;
				}
			}
			
			
			// the observedFluxes array was initialized with NaN values, so these values can be
			// used to find gaps in the observed data (NaN values should not appear in the spectrum)
			// find the first and last non-NaN entries in observedFluxes
			var firstNNIndex:int = 0;
			var lastNNIndex:int = 0;
			for (i=_numObservedWavelengths-1; i>=0; i--) {
				if (!isNaN(_observedFluxes[i])) {
					lastNNIndex = i;
					break;
				}
				else _observedFluxes[i] = 0;
			}
			for (i=0; i<lastNNIndex; i++) {
				if (!isNaN(_observedFluxes[i])) {
					firstNNIndex = i;
					break;
				}
				else _observedFluxes[i] = 0;
			}
			var numGaps:int = 0;
			for (i=firstNNIndex; i<=lastNNIndex; i++) {
				if (isNaN(_observedFluxes[i])) {
					_observedFluxes[i] = 0;
					numGaps++;
					// should interpolate here
					// skipping for now since the present combination of spectrum data, filters,
					// observedWavelengthResolution, and redshifts does not seem to require it
				}
			}
			if (numGaps>0) trace("WARNING, NEED TO IMPLEMENT INTERPOLATION, gaps: "+numGaps);
			
			redrawFilters();			
		}
		
		public function get showFilters():Boolean {
			return _filters.visible;
		}
		
		public function set showFilters(arg:Boolean):void {
			_filters.visible = arg;
			if (_filters.visible) redraw();
		}
			
		public function setFiltersAlpha(arg:Number):void {
			_filters.alpha = arg;			
		}		
			
		protected var _mags:Object = {};
		
		public function getMagnitudes():Object {
			return _mags;			
		}
		
		public function addTickmarks(tickmarksList:Array):void {
			if (_tickmarks!=null) removeChild(_tickmarks);
			_tickmarks = new Sprite();
			addChild(_tickmarks);
			
			var xScale:Number = _width/(_maxW-_minW);
			
			var tickmarkWithLabel:TickmarkWithLabel;
			var tickmarkWithoutLabel:TickmarkWithoutLabel;
			
			for each (var tickmarkDef:Object in tickmarksList) {
				if (tickmarkDef.label!=undefined) {
					tickmarkWithLabel = new TickmarkWithLabel();
					tickmarkWithLabel.label.text = tickmarkDef.label;
					tickmarkWithLabel.x = xScale*(tickmarkDef.w - _minW);
					_tickmarks.addChild(tickmarkWithLabel);				
				}
				else {
					tickmarkWithoutLabel = new TickmarkWithoutLabel();
					tickmarkWithoutLabel.x = xScale*(tickmarkDef.w - _minW);
					_tickmarks.addChild(tickmarkWithoutLabel);				
				}
			}
			
		}
		
		protected function valueAt(w:Number):Number {
			var index:int = Math.round((w-_observedMinWavelength)/_observedWavelengthResolution);
			if (index<0 || index>=_observedFluxes.length) return 0;
			else return _observedFluxes[index];
		}
		
		protected function redrawFilters():void {
			
			var g:Graphics = _filters.graphics;
			g.clear();
			
			if (!_filters.visible) return;
			
			var i:int, j:int;
			
			var xScale:Number = _width/(_maxW-_minW);
			var yScale:Number = -_height/(_maxF-_minF);
			var k:Number = _redshift + 1;
			
			var filter:Object;
			var data:Array;
			
			var x0:Number, y0:Number;
			var xj:Number;
			
			var sum:Number;
			
			var w:Number, f:Number;
			var lw:Number, lf:Number;
						
			for (i=0; i<_filterSet.length; i++) {
				filter = _filterSet[i];
				data = filter.data;
				
				w = data[0].w;
				x0 = xScale*(w - _minW);
				
				g.moveTo(x0, 0);
				g.beginFill(filter.color, 0.3);
				
				f = data[0].t*valueAt(w);
				g.lineTo(x0, yScale*(f-_minF));
				
				sum = 0;
				
				lw = w;
				lf = f;
								
				for (j=1; j<data.length; j++) {
					w = data[j].w;
					xj = xScale*(w - _minW);
					f = data[j].t*valueAt(w);
					g.lineTo(xj, yScale*(f-_minF));					
					
					sum += (w-lw)*(lf+f)/2;
					
					lw = w;
					lf = f;
				}
				
				g.lineTo(xj, 0);
				g.lineTo(x0, 0);
				g.endFill();
				
				_mags[filter.name] = -Math.log(sum);// + filter.fudge;
			}
				
		}		
		
		
		
	}
}
