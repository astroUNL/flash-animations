
package edu.unl.astro.starField {
	
	public class AbstractTransferFunction extends EventDispatcher implements ITransferFunction {
		
		private var _lookupTable:Array;
		
		public function AbstractTransferFunction() {
			// 
		}
		
		public function getColor(counts:uint):uint {
			return _lookupTable[counts];
		}
		
		
		private var _linkedStarField:StarField;
		
		
		public function set linkedStarField(sf:StarField):void {
			if (sf==_linkedStarField) return;
			if (_linkedStarField!=null) {
				_linkedStarField.removeEventListener(StarField.BIT_DEPTH_CHANGED, recalculate);
			}
			_linkedStarField = sf;
			_linkedStarField.addEventListener(StarField.BIT_DEPTH_CHANGED, recalculate);
		}
		public function get linkedStarField():StarField {
			return _linkedStarField;
			
		}
		
		
		
		private var _customMappingKeysList:Array = [];
		
		public function addCustomMappingKey(counts:int, color:uint):void {
			_customMappingKeysList.push({counts: counts, color: color});
			doDispatch();
		}
		
		public function removeCustomMappingKeys():void {
			_customMappingKeysList = [];			
			doDispatch();
			if (
		}
		
		public function doDispatch():void {
			dispatchEvent(new Event(StarField.TRANSFER_FUNCTION_CHANGED));
		}
		
		
		
		
		
		
	
			private var _starField:StarField;
		
		function linkToStarField(sf:StarField):void {
			_starField = sf;
		}
		
		function unlinkFromStarField(sf:StarField):void {
			
			
		}
		
		
	}
	

	
	
}
