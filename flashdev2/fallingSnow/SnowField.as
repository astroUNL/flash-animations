
package {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class SnowField extends Sprite {
		
		private var _fieldBMD:BitmapData;
		private var _fieldBM:Bitmap;
		
		private var _locked:Boolean = false;
		private var _updateQueue:Object = {callInitializeBitmap: false,
										   callInitializeFlakeField: false,
										   callUpdateBitmap: false};
		
		private var _screenHeight:uint;
		private var _screenWidth:uint;
		private var _screenRadius:uint;
		
		private var _numberOfFlakes:uint;
		private var _halfFieldOfView:Number;
		private var _visibility:Number;
		
		private var _flakesList:Array = [];
		
		private var _snowSpeed:Number;
		private var _carSpeed:Number;
		
		private var _animationState:Boolean = false;
		private var _timeLast:Number;
		
		public function SnowField():void {
			lock();
			
			screenWidth = 500;
			screenHeight = 400;
			
			numberOfFlakes = 10000;
			
			fieldOfView = 110;
			visibility = 100;
			carSpeed = 20;
			snowSpeed = 1;
			
			unlock();		
		}
		
		public function refresh():void {
			initializeFlakeField()
			updateBitmap();
		}
		
		public function lock():void {
			_locked = true;
		}
		
		public function unlock():void {
			_locked = false;
			
			if (_updateQueue.callInitializeBitmap) initializeBitmap();
			if (_updateQueue.callInitializeFlakeField) initializeFlakeField();
			if (_updateQueue.callUpdateBitmap) updateBitmap();
			
			_updateQueue.callInitializeBitmap = false;
			_updateQueue.callInitializeFlakeField = false;
			_updateQueue.callUpdateBitmap = false;
		}
		
		public function get locked():Boolean {
			return _locked;
		}
		
		public function set locked(arg:Boolean):void {
			arg ? lock() : unlock();
		}		
		
		public function get screenHeight():uint {
			return _screenHeight;
		}
		
		public function set screenHeight(arg:uint):void {
			_screenHeight = arg;
			initializeBitmap();
			updateBitmap();
		}
		
		public function get screenWidth():uint {
			return _screenWidth;
		}
		
		public function set screenWidth(arg:uint):void {
			_screenWidth = arg;
			initializeBitmap();
			updateBitmap();
		}
		
		public function get numberOfFlakes():uint {
			return _numberOfFlakes;
		}
		
		public function set numberOfFlakes(arg:uint):void {
			_numberOfFlakes = arg;
		}
		
		public function get fieldOfView():Number {
			return 2*_halfFieldOfView*(180/Math.PI);			
		}
		
		public function set fieldOfView(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0 || arg>=140) return;
			_halfFieldOfView = arg*(Math.PI/180)/2;		
			initializeFlakeField();
			updateBitmap();
		}
		
		public function get visibility():Number {
			return _visibility;
		}
		
		public function set visibility(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0) return;
			_visibility = arg;
			initializeFlakeField();
			updateBitmap();
		}		
		
		public function get snowSpeed():Number {
			return _snowSpeed*1000;			
		}
		
		public function set snowSpeed(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<0) return;
			_snowSpeed = arg/1000;
		}
		
		public function get carSpeed():Number {
			return _carSpeed*1000;
		}
		
		public function set carSpeed(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<0) return;
			_carSpeed = arg/1000;
		}
		
		public function get animationState():Boolean {
			return _animationState;			
		}
		
		public function set animationState(arg:Boolean):void {
			if (arg && !_animationState) {
				// start animating
				_timeLast = getTimer();
				addEventListener(Event.ENTER_FRAME, animationEnterFrameFunc);
			}
			else if (!arg && _animationState) {
				// stop animating
				removeEventListener(Event.ENTER_FRAME, animationEnterFrameFunc);
			}
			_animationState = arg;
		}
				
		private function animationEnterFrameFunc(...ignored):void {
			var timeNow:Number = getTimer();
			advanceFlakes(timeNow-_timeLast);
			updateBitmap();
			_timeLast = timeNow;
		}
		
		private function advanceFlakes(deltaT:Number):void {			
			var a:Number = _visibility*Math.sin(_halfFieldOfView);
			var b:Number = 2*a;
			var c:Number = deltaT*_carSpeed;
			var d:Number = deltaT*_snowSpeed;
			var e:Number = _visibility + c;
			
			var boxVolume:Number = b*b*_visibility;
			
			var targetDensity:Number = _numberOfFlakes/boxVolume;
			
			var topMarginVolume:Number = e*d*b;
			var frontMarginVolume:Number = b*b*c;
			var totalMarginVolume:Number = topMarginVolume + frontMarginVolume;
			
			var topMarginFraction:Number = topMarginVolume/totalMarginVolume;
			
			var numberOfNewFlakes:Number = targetDensity*totalMarginVolume;
			
			var flakesList_NEW:Array = [];
			var recycleList:Array = [];
			
			var dy:Number = -c;
			var dz:Number = -d;
			
			var i:int;
			var j:int = 0;
			var f:Flake;
			
			var len:int = _flakesList.length;
			for (i=0; i<len; i++) {
				f = _flakesList[i];
				f.y += dy;
				f.z += dz;
				if (f.y>0 && f.z>-a) flakesList_NEW[j++] = f;
			}
			
			// now inject new particles			
			for (i=0; i<numberOfNewFlakes; i++) {
				
				f = new Flake();
				
				if (Math.random()<topMarginFraction) { 
					// add the new flake to the top margin
					f.x = a*(2*Math.random()-1);
					f.y = e*Math.random();
					f.z = a + d*Math.random();
				}
				else {
					// add the new flake to the front margin
					f.x = a*(2*Math.random()-1);
					f.y = _visibility + c*Math.random();
					f.z = a*(2*Math.random()-1);
				}
				
				f.y += dy;
				f.z += dz;
				
				flakesList_NEW[j++] = f;
			}
			
			_flakesList = flakesList_NEW;			
		}
		
		private function updateBitmap():void {
			if (_locked) {
				_updateQueue.callUpdateBitmap = true;
				return;
			}
			
			_fieldBMD.fillRect(new Rectangle(0, 0, _screenWidth, _screenHeight), 0x000000);
			
			var f:Flake;
			var s:Number;
			var g:int;
			var tanHFOV:Number = Math.tan(_halfFieldOfView);
			var sx:int;
			var sy:int;
			
			var k:Number = _screenRadius/tanHFOV;
			
			_fieldBMD.lock();
			
			var len:int = _flakesList.length;
			for (var i:int = 0; i<len; i++) {
				f = _flakesList[i];
				s = k/f.y;
				sx = ((_screenWidth/2) + s*f.x);
				sy = ((_screenHeight/2) - s*f.z);
				
				if (sx>=0 && sx<_screenWidth && sy>=0 && sy<_screenHeight) {
					g = (0xf0 - (0xf0*Math.sqrt(f.x*f.x + f.y*f.y + f.z*f.z)/_visibility));
					if (g<0) continue;
					g += (0xff & _fieldBMD.getPixel(sx, sy));
					if (g>0xff) g = 0xff;
					_fieldBMD.setPixel(sx, sy, uint((g<<16) | (g<<8) | g));
				}
			}
			_fieldBMD.unlock();
		}
		
		private function initializeFlakeField():void {
			if (_locked) {
				_updateQueue.callInitializeFlakeField = true;
				return;
			}
			
			// make _flakesList the same length as _numberOfFlakes
			var delta:int = _numberOfFlakes - _flakesList.length;
			if (delta<0) {
				// remove flakes
				_flakesList.splice(_flakesList.length + delta);
			}
			else if (delta>0) {
				// add flakes
				for (var i:int = 0; i<delta; i++) _flakesList.push(new Flake());			
			}			
			
			// the flakes are placed in a box shaped volume of space that encloses the viewing
			// cone; this box has a long side of length _visibility (aligned with the +y axis)
			// and a square face with sides of 2*_visibility*sin(_halfFieldOfView)
			var m:Number = _visibility*Math.sin(_halfFieldOfView);
			var f:Flake;
			for (i=0; i<_numberOfFlakes; i++) {
				f = _flakesList[i];
				f.x = m*(2*Math.random()-1);
				f.z = m*(2*Math.random()-1);
				f.y = _visibility*Math.random();
			}
		}
		
		private function initializeBitmap():void {
			if (_locked) {
				_updateQueue.callInitializeBitmap = true;
				return;
			}
			_screenRadius = Math.sqrt(_screenWidth*_screenWidth + _screenHeight*_screenHeight);
			if (_fieldBM!=null) removeChild(_fieldBM);
			_fieldBMD = new BitmapData(_screenWidth, _screenHeight, false, 0x000000);
			_fieldBM = new Bitmap(_fieldBMD);
			addChild(_fieldBM);
		}
		
	}
	
}

internal class Flake {
	public var x:Number = 0;
	public var y:Number = 0;
	public var z:Number = 0;
}
