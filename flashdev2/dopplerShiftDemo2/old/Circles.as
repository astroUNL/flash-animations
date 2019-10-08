
package {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	import flash.events.TimerEvent;
	
	public class Circles extends Sprite {
		
		protected var _bmd:BitmapData;
		protected var _bm:Bitmap;
		protected var _timerLast:Number;
		protected var _updateTimer:Timer;
		
		protected var _time:Number = 0;
		protected var _timeLast:Number = 0;
		
		protected var _sp:Sprite;
		
		protected var _circlesList:Array = [];
		
		public function Circles() {
			
			
			
			_bmd = new BitmapData(600, 400);
			_bm = new Bitmap(_bmd);
			
			//addChild(_bm);
			
			_sp = new Sprite();
			
			addChild(_sp);
			
			_timerLast = getTimer();
			_updateTimer = new Timer(30);
			_updateTimer.addEventListener("timer", onUpdateTimer);
			_updateTimer.start();
			
		}
		
		protected var _sourceX:Number = 0;
		protected var _sourceY:Number = 0;
		
		protected var _sourceVX:Number = 0;
		protected var _sourceVY:Number = 0;
		
		
		
		public function get sourceX():Number {
			return _sourceX;
		}
		
		public function get sourceY():Number {
			return _sourceY;
		}
		
		
		public function setSourcePosition(sx:Number, sy:Number):void {
			_sourceX = sx;
			_sourceY = sy;			
		}
		
		public function setSourceVelocity(vx:Number, vy:Number):void {
			_sourceVX = vx;
			_sourceVY = vy;			
		}
		
		public function setSourcePositionAndVelocity(sx:Number, sy:Number, vx:Number, vy:Number):void {
			_sourceX = sx;
			_sourceY = sy;			
			_sourceVX = vx;
			_sourceVY = vy;			
		}

		
		protected var _animationState:Boolean = false;
		
		public function setAnimationState(arg:Boolean):void {
			if (arg) _timerLast = getTimer();
			_animationState = arg;
		}
		
		
		
		protected function onUpdateTimer(evt:TimerEvent):void {
			
			if (_animationState) { 
				var timerNow:Number = getTimer();
			
				//trace(timerNow-_timerLast);
				//_time += (timerNow - _timerLast);
				
				_time = getTimer();
				
				update();
				
				_timerLast = timerNow;
				
				evt.updateAfterEvent();
			}
		}
		
		public var _speed:Number = 30/1000;
		protected var _frequency:Number = 1200;
		protected var _maxNumCircles:int = 80;
		protected var _circlesIndex:int = 0;
		
		protected function update():void {
			//trace("");
			
			var dt:Number = _time - _timeLast;
						
			
			var n:int = Math.floor(_timeLast/_frequency) + 1;
			var nLimit:int = Math.floor(_time/_frequency);
			
			var c:Circle;
			var color:uint;
			
			
			
			var x0:Number = _sourceX;
			var y0:Number = _sourceY;
			
			var t:Number = _timeLast;
			
			
				
			var cx:Number;
			var cy:Number;
			
			//trace("n: "+n);
			//trace("nLimit: "+nLimit);
			
			var nx:Number = _sourceX + dt*_sourceVX;
			var ny:Number = _sourceY + dt*_sourceVY;
			
			
			
			
			
			//trace("_time: "+_time);
			
			for (i=n; i<=nLimit; i++) {
				
				t = i*_frequency;
				
				cx = nx - (_time-t)*_sourceVX;
				cy = ny - (_time-t)*_sourceVY;
				
				//trace("t: "+t);
				
				
				
				if (_circlesIndex%4==0) color = 0xffa0a0;
				else color = 0xd0d0d0;
				
				c = new Circle(cx, cy, t, color);
				
				_circlesList[_circlesIndex] = c;
				_circlesIndex = (_circlesIndex + 1)%_maxNumCircles;
			}
			
			
			_sourceX += dt*_sourceVX;
			_sourceY += dt*_sourceVY;
						
			
			
			_timeLast = _time;
			
			var i:int;
			var r:Number;
			
			_sp.graphics.clear();
			
			for (i=0; i<_circlesList.length; i++) {
				c = _circlesList[i];
				
				_sp.graphics.lineStyle(1, c.color);
				
				r = _speed*(_time - c.startTime);
				
				
				_sp.graphics.drawCircle(c.x, c.y, r);
				//trace(c.startTime);
			}
			
			
		}
		
		
		
	}
	
}

internal class Circle {
	public var x:Number;
	public var y:Number;
	public var startTime:Number;
	public var color:uint;
	public function Circle(initX:Number, initY:Number, initStartTime:Number, initColor:Number) {
		x = initX;
		y = initY;
		startTime = initStartTime;
		color = initColor;		
	}
}

