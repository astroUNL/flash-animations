
package {
	
	import flash.events.IEventDispatcher;
	
	public interface ISource extends IEventDispatcher {
		
		// public static const ON_TRANSITION:String = "onTransition";
		// a source must dispatch an "onTransition" event when a transition starts and when it ends;
		// or, if the transition is immediate (after calls to setPosition and clearHistory) a single
		// "onTransition" event must be dispatched
		
		function setPosition(pos:Position):void;
		// sets the position of the source, clears the history, and sets the emission state to false
		// without transition (but still dispatches a single "onTransition" event)
		
		function getPosition(time:Number=Number.NaN):Position;
		// returns the position at the given time; if the time is not specified the current time is used
		
		function getPositions(timesList:Array):void;
		// reads the time property for each object in the timesList array and sets the x and y properties
		// to the position of the source at that time; timesList is assumed to be ordered
		
		function update(time:Number):void;
		// instructs the source to position itself for the given time (this is how the source moves)
		
		function clearHistory():void;
		// clears the history and starts over with the current position, and sets the emission state to
		// false without transition (but still dispatches a single "onTransition" event)
		
		function expireHistory(expTime:Number):void;
		// removes all position and emission history earlier than the given time; one should call this
		// function periodically to keep the history arrays from growing unnessarily large
		
		function getValue(time:Number):Number;
		// returns the value of the source emission at the given time
		
		function getValues(timesList:Array):void;
		// for each object in the times list the time property is read and the value property is set to
		// the value of the source emission at that time; timesList is assumed to be ordered
		
		function getObservedValue(obsPos:Position, waveSpeed:Number):Number;
		// returns the value that an observer at the given position (time and location) would observe if
		// waves travelled at the given speed; this function takes into account the source's position history
		
		function getObservedValues(obsPosList:Array, waveSpeed:Number):void;
		// assigns the value property for each object in the observer positions list with the value that
		// would be observed at the given location and time if waves travelled at the given speed
		
		function getPeaks(start:Number, end:Number):Array;
		// returns an array of positions (Position objects) of the source when it was emitting a crest,
		// between the time interval bracketed by the given times

		function getEmissionState():Boolean;
		// returns the emission state; note that the emission state may still be true for a short period
		// after setting it to false while the source transitions between states (cf. inTransition)
		
		function setEmissionState(state:Boolean):void;
		// sets the emission state, that is, whether the source is currently emitting waves or not; note
		// that a source may continue to emit waves for a brief period of time after setting the state
		// to false (cf. inTransition); also note that you may not be able to set the state during
		// transitions between states
		
		function toggleEmissionState():Boolean;
		// toggles the emission state and returns the value of the emission state; note that the state
		// may not change if currently in transition
		
		function get inTransition():Boolean;
		// a read-only property that indicates whether the source is transitioning from emission to
		// non-emission or vice-versa; during a transition you may not be able to set that emission state
	}	
	
}
