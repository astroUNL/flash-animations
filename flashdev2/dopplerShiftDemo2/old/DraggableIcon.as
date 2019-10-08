
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	//import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class DraggableIcon extends Sprite {
		
		public static const MaxVelocity:Number = 20/1000;
		
		protected var _positionLog:PositionLog;
		
		protected var _mouseIsDown:Boolean = false;		
		protected var _xOffset:Number;
		protected var _yOffset:Number;
		protected var _timeLast:Number;
		
		public function DraggableIcon() {			
			_positionLog = new PositionLog();
			setPosition(new Position(0, 0, 0));		
			addEventListener("addedToStage", onAddedToStage);
		}
		
		protected function onAddedToStage(...ignored):void {
			addEventListener("mouseDown", onMouseDownFunc);
			stage.addEventListener("mouseUp", onMouseUpFunc);
		}
		
		override public function get x():Number {
			trace("get x called, maybe you shouldn't do that, this: "+this);
			return super.x;			
		}
		
		override public function set x(arg:Number):void {
			trace("plz set x using setPosition, this: "+this);
			return;
		}
		
		override public function get y():Number {
			trace("get y called, maybe you shouldn't do that, this: "+this);
			return super.y;			
		}
		
		override public function set y(arg:Number):void {
			trace("plz set y using setPosition, this: "+this);
			return;
		}
		
		public function setPosition(pos:Position):void {
			_positionLog.clear();
			_positionLog.addEntry(pos);
			update(pos.time);
		}
		
		public function getPosition(time:Number=Number.NaN):Position {
			// returns the position at the given time; if the time is not specified the current time is used
			if (isNaN(time)) time = TimeKeeper.getTime();
			return _positionLog.getPosition(time);
		}
			
		public function getPositions(timesList:Array):void {
			// reads the time property for each object in the timesList array and sets the x and y properties
			// to the position of the source at that time; timesList is assumed to be ordered
			_positionLog.getPositions(timesList);
		}		
		
		protected function onMouseDownFunc(...ignored):void {
			_mouseIsDown = true;			
			_xOffset = super.x - parent.mouseX;
			_yOffset = super.y - parent.mouseY;
			_timeLast = TimeKeeper.getTime();
			stage.addEventListener("mouseMove", onMouseMoveFunc);
		}
		
		protected function onMouseUpFunc(...ignored):void {
			if (_mouseIsDown) {
				var timeNow:Number = TimeKeeper.getTime();
					
				// stop the icon's motion (assuming it was moving)
				var posNow:Position = _positionLog.getPosition(timeNow);
				if (_positionLog.expireForward(timeNow)>0) _positionLog.addEntry(posNow);
				
				stage.removeEventListener("mouseMove", onMouseMoveFunc);
			}
			_mouseIsDown = false;
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {			
			var timeNow:Number = TimeKeeper.getTime();
			
			// stop the icon's previous motion
			var posNow:Position = _positionLog.getPosition(timeNow);
			if (_positionLog.expireForward(timeNow)>0) _positionLog.addEntry(posNow);
			
			//var targetX:Number = parent.mouseX + _xOffset;
			//var targetY:Number = parent.mouseY + _yOffset;
			
			//var dx:Number = targetX - posNow.x;
			//var dy:Number = targetY - posNow.y;			
/*			var dt:Number = Math.sqrt(dx*dx + dy*dy)/MaxVelocity;
			
			var targetPos:Position = new Position(timeNow+dt, targetX, targetY);

			
			var targetX:Number = parent.mouseX + _xOffset;
			var targetY:Number = parent.mouseY + _yOffset;
			
			var dx:Number = targetX - posNow.x;
			var dy:Number = targetY - posNow.y;			
			var dt:Number = Math.sqrt(dx*dx + dy*dy)/MaxVelocity;
*/			
			
			
			var targetPos:Position = new Position(Number.NaN, parent.mouseX+_xOffset, parent.mouseY+_yOffset);
			var dx:Number = targetPos.x - posNow.x;
			var dy:Number = targetPos.y - posNow.y;
			targetPos.time = timeNow + Math.sqrt(dx*dx + dy*dy)/MaxVelocity;
			
			_positionLog.addEntry(targetPos);	
			
			update(timeNow);			
			evt.updateAfterEvent();
		}
		
		public function update(time:Number):void {
			var posNow:Position = _positionLog.getPosition(time);
			super.x = posNow.x;
			super.y = posNow.y;
		}		
		
	}
}

