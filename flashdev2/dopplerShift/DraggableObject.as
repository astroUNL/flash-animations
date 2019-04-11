
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.display.Graphics;
	import flash.events.Event;
	
	public class DraggableObject extends Sprite {
		
		public static const MaxVelocity:Number = 20/1000;
		
		public var _positionLog:PositionLog;
		
		protected var _mouseIsDown:Boolean = false;		
		protected var _xOffset:Number;
		protected var _yOffset:Number;
		protected var _timeLast:Number;
		protected var _range:Rectangle;
		
		protected var _controlKeyDown:Boolean = false;
		protected var _shiftKeyDown:Boolean = false;
		
		protected var _showPath:Boolean = false;
		protected var _pathGraphics:Graphics = null;
		protected var _pathDuration:Number = 5000;
		
		protected var _updateTime:Number = 0;
		
		protected var _pathStyle:Object = {thickness: 1, maxDarkness: 190, satFrac: 0.5};
		
		protected var _mouseMode:int = 0;
		
		
		public function DraggableObject() {			
			_positionLog = new PositionLog();
			setPosition(new Position(0, 0, 0));		
			addEventListener("addedToStage", onAddedToStage);
		}
		
		protected function onAddedToStage(...ignored):void {
			addEventListener("mouseDown", onMouseDownFunc);
			stage.addEventListener("mouseUp", onMouseUpFunc);
			stage.addEventListener("keyDown", onKeyDownFunc);
			stage.addEventListener("keyUp", onKeyUpFunc);
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			_controlKeyDown = evt.ctrlKey;
			_shiftKeyDown = evt.shiftKey;			
		}
		
		protected function onKeyUpFunc(evt:KeyboardEvent):void {
			_controlKeyDown = evt.ctrlKey;
			_shiftKeyDown = evt.shiftKey;			
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
		
		public function setRange(rect:Rectangle=null):void {
			_range = rect;			
		}
		
		public function setPosition(pos:Position):void {
			_positionLog.clear();
			_positionLog.addEntry(pos);
			update(pos.time);
			
			dispatchEvent(new Event("positionReset"));
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
			
			// bring object to front
			parent.setChildIndex(this, parent.numChildren-1);
			
			// stop any previous motion
			var timeNow:Number = TimeKeeper.getTime();
			stopMotionAt(timeNow);
			
			if (_shiftKeyDown) {
				// shift mode - delayed mouse following (object will follow linear path after mouse button is released)
				_mouseMode = 1;
				_xOffset = 0;
				_yOffset = 0;
			}
			else if (_controlKeyDown) {
				// control mode - the object follows the mouse immediately; this mode clears the history
				_mouseMode = 2;
				_xOffset = super.x - parent.mouseX;
				_yOffset = super.y - parent.mouseY;
			}
			else {
				// default (unmodulated) mode - the object chases the mouse as long as the mouse button is down
				_mouseMode = 0;
				_xOffset = super.x - parent.mouseX;
				_yOffset = super.y - parent.mouseY;
			}
			
			_mouseIsDown = true;			
						
			_timeLast = timeNow;
			stage.addEventListener("mouseMove", onMouseMoveFunc);
		}
		
		protected function onMouseUpFunc(...ignored):void {
			graphics.clear();
			
			if (_mouseIsDown) {
				var timeNow:Number = TimeKeeper.getTime();
					
				if (_mouseMode==0) {
					// live mouse following
					stopMotionAt(timeNow);
				}
				else if (_mouseMode==1) {
					// delayed mouse following					
					chaseMouse(timeNow);
				}
								
				stage.removeEventListener("mouseMove", onMouseMoveFunc);
			}
			
			_mouseIsDown = false;
		}
		
		protected function chaseMouse(timeNow:Number):void {
			
			// stop the object's previous motion
			var posNow:Position = stopMotionAt(timeNow);
			
			// add a future entry at the target position
			_positionLog.addEntry(getMouseTarget(posNow));
		}
		
		protected function getMouseTarget(startPos:Position):Position {
			var targetX:Number = parent.mouseX + _xOffset;
			var targetY:Number = parent.mouseY + _yOffset;
			
			if (_range!=null) {
				
				var u:Number = 1;
				
				if (targetX<_range.left) {
					var uLeft:Number = (_range.left - startPos.x)/(targetX - startPos.x);
					if (uLeft>=0 && uLeft<=1) u = Math.min(u, uLeft);
				}
				
				if (targetX>_range.right) {					
					var uRight:Number = (_range.right - startPos.x)/(targetX - startPos.x);
					if (uRight>=0 && uRight<=1) u = Math.min(u, uRight);
				}
				
				if (targetY<_range.top) {
					var uTop:Number = (_range.top - startPos.y)/(targetY - startPos.y);
					if (uTop>=0 && uTop<=1) u = Math.min(u, uTop);
				}
				
				if (targetY>_range.bottom) {
					var uBottom:Number = (_range.bottom - startPos.y)/(targetY - startPos.y);
					if (uBottom>=0 && uBottom<=1) u = Math.min(u, uBottom);
				}
				
				if (u<1) {
					targetX = startPos.x + u*(targetX - startPos.x);
					targetY = startPos.y + u*(targetY - startPos.y);					
				}
			}
			
			var dx:Number = targetX - startPos.x;
			var dy:Number = targetY - startPos.y;
			var targetTime:Number = startPos.time + Math.sqrt(dx*dx + dy*dy)/MaxVelocity;
			
			return new Position(targetTime, targetX, targetY);			
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {
			var timeNow:Number = TimeKeeper.getTime();
								
			if (_mouseMode==0) {
				// live mouse following
				chaseMouse(timeNow);
				update(timeNow);
			}
			else if (_mouseMode==1) {
				// delayed mouse following
				
				// draw a line
				var posNow:Position = _positionLog.getPosition(timeNow);
				var targetPos:Position = getMouseTarget(posNow);
				graphics.clear();
				graphics.moveTo(0, 0);
				graphics.lineStyle(2, 0xffc080);
				graphics.lineTo(targetPos.x-posNow.x, targetPos.y-posNow.y);
			}
			else if (_mouseMode==2) {
					
				var nx:Number = parent.mouseX + _xOffset;
				var ny:Number = parent.mouseY + _yOffset;
				if (nx<_range.left) nx = _range.left;
				else if (nx>_range.right) nx = _range.right;
				if (ny<_range.top) ny = _range.top;
				else if (ny>_range.bottom) ny = _range.bottom;
				
				setPosition(new Position(timeNow, nx, ny));
			}
				
			evt.updateAfterEvent();
		}
		
		public function update(timeNow:Number):void {
			_updateTime = timeNow;
			var posNow:Position = _positionLog.getPosition(timeNow);
			super.x = posNow.x;
			super.y = posNow.y;
			updatePath();
		}
		
		protected function updatePath():void {
			if (_pathGraphics==null) return;			
			_pathGraphics.clear();
			if (!_showPath) return;
						
			var timeLast:Number = _updateTime - _pathDuration;
			
			var i:int;
			var g:int;
			
			var th:Number = _pathStyle.thickness;
			var m:uint = _pathStyle.maxDarkness;
			var r:Number = (255-m)*(1/(1-_pathStyle.satFrac));
			
			// taking a stepSize of about 1/MaxVelocity means that each step will be 1 pixel or less
			var stepSize:Number = 1/MaxVelocity;
			var numSteps:int = Math.ceil(_pathDuration/stepSize);
			stepSize = _pathDuration/numSteps;
			
			// generate the positions list for the given spacing
			var posList:Array = [];
			for (i=0; i<=numSteps; i++) posList[i] = new Position(timeLast+stepSize*i);			
			_positionLog.getPositions(posList);
			
			// draw the path
			_pathGraphics.moveTo(posList[0].x, posList[0].y);
			for (i=1; i<posList.length; i++) {
				g = 255 - r*(posList[i].time-timeLast)/_pathDuration;
				if (g<m) g = m;
				_pathGraphics.lineStyle(th, (g<<16) | (g<<8) | g);
				_pathGraphics.lineTo(posList[i].x, posList[i].y);
			}
		}
		
		protected function stopMotionAt(time:Number):Position {
			// stops any motion the object was undergoing at the given time
			var pos:Position = _positionLog.getPosition(time);
			_positionLog.expireForward(time);
			_positionLog.addEntry(pos);			
			return pos;
		}
		
		public function stopMotion():void {
			stopMotionAt(TimeKeeper.getTime());
			if (_mouseIsDown) {
				stage.removeEventListener("mouseMove", onMouseMoveFunc);
				_mouseIsDown = false;
			}
		}
				
		public function getPathStyle():Object {
			return _pathStyle;
		}
		
		public function setPathStyle(arg:Object):void {
			_pathStyle = arg;
			updatePath();
		}
		
		public function getPathDuration():Number {
			return _pathDuration;		
		}
		
		public function setPathDuration(arg:Number):void {
			_pathDuration = arg;
			updatePath();
		}
		
		public function getShowPath():Boolean {
			return _showPath;			
		}
		
		public function setShowPath(arg:Boolean):void {
			_showPath = arg;
			updatePath();
		}
		
		public function getPathGraphicsObject():Graphics {
			return _pathGraphics;
		}
		
		public function setPathGraphicsObject(arg:Graphics):void {
			_pathGraphics = arg;			
			updatePath();
		}
		
		
		public function expireHistory(expTime:Number):void {
			_positionLog.expire(expTime);			
		}
		
	}
}

