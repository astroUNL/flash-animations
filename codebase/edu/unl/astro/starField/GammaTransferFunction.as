
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class GammaTransferFunction extends EventDispatcher implements ITransferFunction {
		
		protected var _lookupTable:Array;
		protected var _normalTable:Array;
		protected var _invertedTable:Array;
		protected var _peakValue:uint;
		protected var _inverted:Boolean = false;
		protected var _gamma:Number = 1.8;
		
		public function GammaTransferFunction():void {
			//
		}
		
		public function getColor(counts:uint):uint {
			return _lookupTable[counts];
		}
		
		public function get peakValue():uint {
			return _peakValue;
		}
		
		public function set peakValue(arg:uint):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0 || _peakValue==arg) return;
			_peakValue = arg;
			refresh();			
		}
		
		public function refresh():void {
			var g:int;
			var n:int = _peakValue + 1;
			var k:Number = 0xff/_peakValue;
			
			_normalTable = [];
			_invertedTable = [];
			
			for (var i:int = 0; i<n; i++) {
				g = 0xff*Math.pow(i/_peakValue, 1/_gamma);
				_normalTable[i] = uint((g << 16) | (g << 8) | g);
				
				g = 0xff - g;
				_invertedTable[i] = uint((g << 16) | (g << 8) | g);
				
			}
			
			
			_lookupTable = _inverted ? _invertedTable : _normalTable;
			
			// calling this function takes care of dispatching the transfer function changed event
			updateHighlightingOfSaturatedPixels();
		}
		
		public function get highlightSaturatedPixels():Boolean {
			return _highlightSaturatedPixels;			
		}
		
		public function set highlightSaturatedPixels(arg:Boolean):void {
			_highlightSaturatedPixels = arg;
			updateHighlightingOfSaturatedPixels();
		}
		
		protected var _highlightSaturatedPixels:Boolean = false;
		
		protected function updateHighlightingOfSaturatedPixels():void {
			if (_highlightSaturatedPixels) {
				_invertedTable[_peakValue] = _highlightColor;
				_normalTable[_peakValue] = _highlightColor;
			}
			else {
				_invertedTable[_peakValue] = 0x000000;
				_normalTable[_peakValue] = 0xffffff;
			}
			
			dispatchEvent(new Event(StarField.TRANSFER_FUNCTION_CHANGED));
		}
		
		protected var _highlightColor:uint = 0xff0000;
		
		public function get highlightColor():uint {
			return _highlightColor;		
		}
		
		public function set highlightColor(arg:uint):void {
			_highlightColor = arg;
			updateHighlightingOfSaturatedPixels();			
		}
		
		public function get gamma():Number {
			return _gamma;
		}
		
		public function set gamma(arg:Number) {
			if (isNaN(arg) || !isFinite(arg) || arg<=0) return;
			_gamma = arg;
			refresh();
		}

		public function get inverted():Boolean {
			return _inverted;			
		}
		
		public function set inverted(arg:Boolean):void {
			_inverted = arg;
			_lookupTable = _inverted ? _invertedTable : _normalTable;
			dispatchEvent(new Event(StarField.TRANSFER_FUNCTION_CHANGED));
		}
				
	}
	
}		
