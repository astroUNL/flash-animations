
package edu.unl.astro.starField {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class LinearTransferFunction extends EventDispatcher implements ITransferFunction {
		
		private var _lookupTable:Array;
		private var _normalTable:Array;
		private var _invertedTable:Array;
		private var _peakValue:uint;
		private var _inverted:Boolean = false;
		
		public function LinearTransferFunction():void {
			//
		}
		
		public function refresh():void {
			var g:int;
			var n:int = _peakValue + 1;
			var k:Number = 0xff/_peakValue;
			
			_normalTable = [];
			_invertedTable = [];
			
			for (var i:int = 0; i<n; i++) {
				g = k*i;
				_normalTable[i] = uint((g << 16) | (g << 8) | g);
				g = 0xff - g;
				_invertedTable[i] = uint((g << 16) | (g << 8) | g);
			}
			
			_lookupTable = _inverted ? _invertedTable : _normalTable;
			
			dispatchEvent(new Event(StarField.TRANSFER_FUNCTION_CHANGED));
		}
		
		public function get peakValue():uint {
			return _peakValue;
		}
		
		public function set peakValue(arg:uint):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0) return;
			_peakValue = arg;
			refresh();			
		}

		public function getColor(counts:uint):uint {
			return _lookupTable[counts];
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
