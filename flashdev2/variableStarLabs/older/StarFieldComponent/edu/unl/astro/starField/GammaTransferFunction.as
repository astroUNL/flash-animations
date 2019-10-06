
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class GammaTransferFunction extends EventDispatcher implements ITransferFunction {
		
		private var _lookupTable:Array;
		private var _normalTable:Array;
		private var _invertedTable:Array;
		private var _peakValue:uint;
		private var _inverted:Boolean = false;
		private var _gamma:Number = 1.8;
		
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
			
			dispatchEvent(new Event(StarField.TRANSFER_FUNCTION_CHANGED));
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
