
package {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	
	public class SHZTimeline extends Sprite {
		
		public var timelineWidth:Number = 750;
		public var timelineHeight:Number = 5;
		
		public const backgroundMarginY:Number = 2;
		public const backgroundMarginX:Number = 0;
		
		protected var _minorMargin:Number = 1.5;
		
		protected var _timespan:Number = 0;
		protected var _time:Number = 0;
		
		protected var _labelFormat:TextFormat;
		
		protected var _cursor:SHZTimelineCursor;
		protected var _backgroundSP:Sprite;
		protected var _marksSP:Sprite;
		protected var _labelsSP:Sprite;
				
		protected var _marksColor:uint = 0x505050;
		
		protected var _range:Number;
		
		protected var _incrementTimer:Timer;
		
		protected var _dataTable:Array;
		
		protected var _incrementRate:Number = 2.5/40; // ticks per ms
		protected var _incrementTimerStart:Number;
		protected var _incrementTimerWait:Number = 500;
		protected var _lastIncrementTime:Number;
		
		public function SHZTimeline(width:Number=750, height:Number=6) {
			
			timelineWidth = width;
			timelineHeight = height;
			
			// this class dispatches a "timeChanged" event whenever the time changes as a result of mouse interaction
			
			_labelFormat = new TextFormat("Verdana", 12, _marksColor, false);
			
			_backgroundSP = new Sprite();
			addChild(_backgroundSP);
			
			_backgroundSP.addEventListener("mouseDown", onBackgroundMouseDown);
			
			_marksSP = new Sprite();
			addChild(_marksSP);
			
			_labelsSP = new Sprite();
			addChild(_labelsSP);
			
			_cursor = new SHZTimelineCursor(0, timelineWidth, this);
			_cursor.y = timelineHeight/2;
			addChild(_cursor);
			
			_cursor.addEventListener("cursorDragged", onCursorDragged);
			
			_incrementTimer = new Timer(40);
			_incrementTimer.stop();
			_incrementTimer.addEventListener("timer", onIncrementTimer);
		}
		
		public function reset(star:Object):void {
			// resets the timeline for the given star object, also sets the time cursor position to zero
			// does not dispatch a timeChanged event
			_timespan = star.timespan;
			_dataTable = star.dataTable;
			_time = 0;
			updateCursor();
			updateTickmarks();
		}
		
		public function get time():Number {
			return _time;
		}
		
		public function set time(arg:Number):void {
			_time = arg;
			updateCursor();
		}		
		
		public function setTime(arg:Number, doDispatch:Boolean=false):void {
			_time = arg;
			updateCursor();
			dispatchEvent(new Event("timeChanged"));
		}
				
		public function onCursorDragged(...ignored):void {
			_time = _cursor.x*_timespan/timelineWidth;			
			dispatchEvent(new Event("timeChanged"));
		}		
		
		public function increment(ticks:int, dejitter:Boolean=false, dejitterTime:Number=0):void {
			// should increment by the dataTable spacing, or by the equivalent of 1 pixel, whichever is smaller
									
			if (ticks==0) return;
			
			var minIncrement:Number = _timespan/timelineWidth;
			
			// figure out what the time would be if we increment by 1px per tick
			var pxTime:Number = _time + ticks*minIncrement;
			if (pxTime<0) pxTime = 0;
			else if (pxTime>_timespan) pxTime = _timespan;
			var pxDelta:Number = pxTime - _time;
			
			
			// figure out what the time would be if each tick corresponds to a step in the data table
			var i:int;
			for (i=1; i<_dataTable.length; i++) {
				if (_time<_dataTable[i].time) break;
			}
			i--;
			if (i==(_dataTable.length-1)) {
				// the current time is at the upper limit
				if (ticks<0) i += ticks;			
			}
			else {
				var margin:Number = 0.1*(_dataTable[i+1].time - _dataTable[i].time);
				if (_time<(_dataTable[i].time+margin)) {
					// the time is in the left margin of the interval
					i += ticks;
				}
				else if (i<(_dataTable.length-1) && _time>(_dataTable[i+1].time-margin)) {
					// the time is in the right margin of the interval
					i += ticks + 1;
				}
				else if (i<(_dataTable.length-1)) {
					i += ticks;
					if (ticks<0) i++;
				}
			}
			
			if (i<0) i = 0;
			else if (i>=_dataTable.length) i = _dataTable.length - 1;
			var stepTime:Number = _dataTable[i].time;
			var stepDelta:Number = stepTime - _time;					
			
			// use the whichever of the two times results in the smallest change
			var newTime:Number = (Math.abs(pxDelta)<Math.abs(stepDelta)) ? pxTime : stepTime;
			
			// do dejitter test
			if (dejitter) {
				// when dejitter is true we look to see if newTime is on the opposite of dejitterTime from _time, and if it
				// is we use dejitterTime as the new time; what this does is prevent the timeline cursor from bouncing around
				// the mouse position when doing click and hold incrementing; the small margin (1e-12) is needed due to finite precision
				if (((newTime-1e-12)<dejitterTime && (_time+1e-12)>dejitterTime) || ((newTime+1e-12)>dejitterTime && (_time-1e-12)<dejitterTime)) newTime = dejitterTime;	
			}
			
			_time = newTime;
			
			updateCursor();
			dispatchEvent(new Event("timeChanged"));			
		}
		
		public function onIncrementTimer(evt:TimerEvent):void {
			
			var timeNow:Number = getTimer();
			var ticks:Number = _incrementRate*(timeNow - _lastIncrementTime);
			if (mouseX<_cursor.x) ticks *= -1;
			_lastIncrementTime = timeNow;
			
			if (getTimer()<_incrementTimerStart) return;
			
			var dejitterTime:Number = mouseX*_timespan/timelineWidth;
			if (dejitterTime<0) dejitterTime = 0;
			else if (dejitterTime>_timespan) dejitterTime = _timespan;
			increment(ticks, true, dejitterTime);
			
			evt.updateAfterEvent();
		}
		
		public function onBackgroundMouseDown(...ignored):void {
			// clicking on the timeline background causes the time to increment by one step towards the mouse position (a step
			// is either 1px or the next index in the data table array, whichever is smaller); holding the mouse down for more
			// than incrementTimerWait causes the time to increment towards the mouse position coninuously by incrementRate
			
			stage.addEventListener("mouseUp", onBackgroundMouseUp);
			
			_incrementTimerStart = getTimer() + _incrementTimerWait;
			_incrementTimer.start();
			
			if (mouseX>_cursor.x) {
				increment(1);
			}
			else if (mouseX<_cursor.x) {
				increment(-1);
			}
		}
		
		public function onBackgroundMouseUp(...ignored):void {
			stage.removeEventListener("mouseUp", onBackgroundMouseUp);
			_incrementTimer.stop();
		}
		
		public function updateCursor():void {
			_cursor.x = _time*timelineWidth/_timespan;
		}
		
		public function updateTickmarks():void {
			
			var g:Graphics;
			var label:TextField;
			
			g = _backgroundSP.graphics;
			g.clear();
			g.lineStyle(1, 0xeaeaea);
			g.beginFill(0xffffff);
			g.drawRect(-backgroundMarginX, -backgroundMarginY, timelineWidth+2*backgroundMarginX, timelineHeight+2*backgroundMarginY);
			g.endFill();
			
			
			g = _marksSP.graphics;
			g.clear();
			var scale:Number = timelineWidth/_timespan;
			
			
			var ticksMinSpacing:Number = 15;
			var labelsMinSpacing:Number = 80;
			
			
			// determine the spacing to use for the tickmarks
			var ticksSpacing:Number = Math.pow(10, Math.ceil(Math.log(ticksMinSpacing/scale)/Math.LN10));
			if ((ticksSpacing/2)*scale>ticksMinSpacing) {
				ticksSpacing = ticksSpacing/2;
			}
			
			// determine the spacing and precision to use for the labels
			var labelsPrecision:int = Math.ceil(Math.log(labelsMinSpacing/scale)/Math.LN10);
			var labelsSpacing:Number = Math.pow(10, labelsPrecision);
			if ((labelsSpacing/2)*scale>labelsMinSpacing) {
				labelsSpacing = labelsSpacing/2;
				labelsPrecision--;
			}
			
			var labelsMultiple:int = labelsSpacing/ticksSpacing;
			
			
			var i:int;
			var x:Number;
			var t:Number = 0;
			
			g.lineStyle(1, _marksColor);
			
			// draw the tickmarks
			var labelsList:Array = [{x: 0, label: "0"}];
			while (t<_timespan) {
				x = scale*t;
				if (t%labelsSpacing==0) {
					if (t!=0) {
						if (t>=1e3) labelsList.push({x: x, label: getFormattedNumber(t/1e3, labelsPrecision-3)+" Gy"});
						else if (t>=1e6) labelsList.push({x: x, label: getFormattedNumber(t/1e6, labelsPrecision-6)+" Ty"});
						else labelsList.push({x: x, label: getFormattedNumber(t, labelsPrecision)+" My"});
					}
					g.moveTo(x, 0);
					g.lineTo(x, timelineHeight);
				}
				else {
					g.moveTo(x, _minorMargin);
					g.lineTo(x, timelineHeight-_minorMargin);
				}
				t += ticksSpacing;
			}
						
			// add more labels if needed
			while (_labelsSP.numChildren<labelsList.length) {
				label = new TextField();
				label.defaultTextFormat = _labelFormat;
				label.selectable = false;
				label.embedFonts = false;
				label.autoSize = "left";
				label.y = timelineHeight + 3;
				_labelsSP.addChild(label);
			}
			
			// render the labels
			for (i=0; i<labelsList.length; i++) {
				label = _labelsSP.getChildAt(i) as TextField;
				label.width = 0;
				label.height = 0;
				label.text = labelsList[i].label;
				label.x = labelsList[i].x - label.width/2;
				label.visible = true;
			}
			for (i; i<_labelsSP.numChildren; i++) {
				_labelsSP.getChildAt(i).visible = false;
			}
		}		
		
		public function getTimeString():String {
			var t:Number = _time;
			var b:Number = Math.floor(Math.log(t)/Math.LN10);
			
			if (b>=3) return getFormattedNumber(t/1e3, b-3-2)+" Gy";
			else if (b>=6) return getFormattedNumber(t/1e6, b-6-2)+" Ty";
			else return getFormattedNumber(t, b-2)+" My";
		}
		
		protected function getFormattedNumber(num:Number, place:int):String {
			// this function takes a number and returns a string representation rounded
			// to the indicated digit (indicated by the power of ten of that place, e.g.
			// place = -1 causes the number to be rounded to the nearest tenth)
			if (place>=0) {
				var p:Number = Math.pow(10, place);
				return String(p*Math.round(num/p));
			}
			else return num.toFixed(-place);
		}			
				
	}
}
