
package edu.unl.astro.starField {
	
	import flash.events.IEventDispatcher;

	public interface ITransferFunction extends IEventDispatcher {
		// - in addition to these functions every instance of an ITransferFunction is expected to dispatch an
		//   event with type StarField.TRANSFER_FUNCTION_CHANGED after changes are made
		function getColor(counts:uint):uint;
		function get peakValue():uint;
		function set peakValue(value:uint):void;
	}	
	
}
