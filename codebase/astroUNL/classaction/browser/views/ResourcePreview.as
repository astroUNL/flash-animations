
package astroUNL.classaction.browser.views {

	import astroUNL.classaction.browser.resources.ResourceItem;
	import astroUNL.classaction.browser.download.Downloader;
	import astroUNL.classaction.browser.resources.BinaryFile;
	
	import astroUNL.utils.easing.CubicEaser;
	
	import astroUNL.utils.logger.Logger;
	
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	
	public class ResourcePreview extends Sprite {
		
		protected var _alphaTimer:Timer;
		protected var _thumbTimer:Timer;
		
		protected var _alphaEaser:CubicEaser;
		
		protected var _downloadPriority:int = 500000;
		
		protected var _thumbLoader:Loader;
		
		protected var _bubble:Sprite;
		protected var _background:ResourcePreviewBackground;
		protected var _stem:ResourcePreviewBubbleStem;
		protected var _thumb:Bitmap;
		
		// the states:
		// -1 - alpha is held at zero
		//  0 - alpha is held at zero while waiting for the thumbnail to load
		//  1 - alpha is increasing
		//  2 - alpha is held at 1
		//  3 - alpha is at 1 for a brief time before falling
		//  4 - alpha is decreasing
		protected var _state:int = 0;
		protected var _thumbIsLoaded:Boolean;
		protected var _position:Point;
		protected var _item:ResourceItem;
		
		public function ResourcePreview() {
			
			_bubble = new Sprite();
			_bubble.alpha = 0;
			addChild(_bubble);
			
			_background = new ResourcePreviewBackground();
			_bubble.addChild(_background);
			
			_stem = new ResourcePreviewBubbleStem();
			_bubble.addChild(_stem);
			
			_thumb = new Bitmap();
			_bubble.addChild(_thumb);
			
			
			mouseEnabled = false;
			mouseChildren = false;
			
			_alphaEaser = new CubicEaser(0);
			
			_thumbTimer = new Timer(20);
			_thumbTimer.addEventListener(TimerEvent.TIMER, onThumbTimer);
			
			_alphaTimer = new Timer(20);
			_alphaTimer.addEventListener(TimerEvent.TIMER, onAlphaTimer);
		}
		
		protected function updateAlpha():void {
			
			var timeNow:Number = getTimer();
			
			// first, check to see if we need to transition between states
			if (_state==0 && _thumbIsLoaded) {
				_state = 1;
				_alphaEaser.setTarget(timeNow, 0, timeNow+_state1Duration, 1);
			}
			else if (_state==1 && timeNow>_alphaEaser.targetTime) {
				_state = 2;
				_alphaEaser.init(1);
			}
			else if (_state==3 && timeNow>_alphaEaser.targetTime) {
				_state = 4;
				_alphaEaser.setTarget(timeNow, 1, timeNow+_state4Duration, 0);
			}
			else if (_state==4 && timeNow>_alphaEaser.targetTime) {
				_state = 0;
				_alphaEaser.init(0);
			}
			
			// set the alpha
			if (_state==-1 || _state==0) _bubble.alpha = 0;
			else if (_state==2 || _state==3) _bubble.alpha = 1;
			else _bubble.alpha = _alphaEaser.getValue(timeNow);
			
			// lastly, check that the alpha timer is running when it should be
			if (_state==-1 || _state==0 || _state==2) {
				if (_alphaTimer.running) _alphaTimer.stop();
			}
			else if (!_alphaTimer.running) _alphaTimer.start();
			
//			trace("updateAlpha, state: "+_state+", alpha: "+_bubble.alpha+", running: "+_alphaTimer.running);
		}
		
		protected const _maxWidth:Number = 180;
		protected const _maxHeight:Number = 140;
		protected const _state1Duration:Number = 400;
		protected const _state3Duration:Number = 300;
		protected const _state4Duration:Number = 200;
		protected const _backgroundMargin:Number = 14;
		protected const _stemOverlap:Number = 2;
		protected const _stemPosition:Number = 0.2;
		protected const _offsetX:Number = 40;
		protected const _offsetY:Number = 4;
		
		protected function onThumbLoaded(evt:Event):void {
			
			var scale:Number = Math.min(_maxWidth/_thumbLoader.width, _maxHeight/_thumbLoader.height);
			if (scale>1) scale = 1;
			
			var w:int = scale*_thumbLoader.width;
			var h:int = scale*_thumbLoader.height;
			
			var src:BitmapData = new BitmapData(_thumbLoader.width, _thumbLoader.height, true, 0x0);
			src.draw(_thumbLoader);
			
			var bmd:BitmapData = new BitmapData(w, h);
			bmd.draw(src, new Matrix(scale, 0, 0, scale, 0, 0), null, null, null, true);
			
			_background.width = w + _backgroundMargin;
			_background.height = h + _backgroundMargin;
			
			_stem.x = -(_background.width/2) + _stemPosition*_background.width;
			_stem.y = (_background.height/2) - _stemOverlap;
			
			_thumb.bitmapData = bmd;
			_thumb.x = -(w/2);
			_thumb.y = -(h/2);
			
			var pos:Point = globalToLocal(_position);			
			_bubble.x = pos.x - _stem.x + _offsetX;
			_bubble.y = pos.y - (_stem.y+_stem.height) + _offsetY;
			
			_thumbIsLoaded = true;
			updateAlpha();
			
			destroyThumbLoader();
		}		
		
		public function show(item:ResourceItem, pos:Point):void {
						
			if (item==null || pos==null) {
				hide();
				return;
			}
			
			_item = item;
			_position = pos;
			
			if (item.thumb!=null) {
				if (item.thumb.downloadState==Downloader.NOT_QUEUED) {
					item.thumb.downloadPriority = _downloadPriority++;
					Downloader.get(item.thumb);
				}
			}
			else {
				Logger.report("missing thumb in ResourcePreview, item: "+item);
				hide();
				return;
				
			}
			
			_thumbIsLoaded = false;
			if (_state==-1) _state = 0;
			else if (_state==3) _state = 2;
			else if (_state==4) {
				_state = 1;
				var timeNow:Number = getTimer();
				_alphaEaser.setTarget(timeNow, null, timeNow+_state4Duration, 1);
			}
			
			// decided to create a new thumbLoader with every request in an attempt to fix a rare
			// but persistent bug where the loader would display the previously loaded thumb
			// (making it more confusing, in the onThumbLoaded method the number of reported bytes loaded
			// would match the new thumb, but the dimensions (and what was shown) would match the old thumb)
			destroyThumbLoader();
			_thumbLoader = new Loader();
			
			if (!_thumbTimer.running) _thumbTimer.start();
			onThumbTimer();			
		}
		
		protected function destroyThumbLoader():void {
			if (_thumbLoader!=null) {
				_thumbLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onThumbLoaded, false);
				_thumbLoader = null;
			}
		}		
		
		public function hide(noWait:Boolean=false):void {
			
			_item = null;
			
			destroyThumbLoader();
			if (_thumbTimer.running) _thumbTimer.stop();
			
			var timeNow:Number = getTimer();
			
			if (noWait) _state = -1;
			else if (_state==0) _state = -1;
			else if (_state==1) {
				_state = 4;
				_alphaEaser.setTarget(timeNow, null, timeNow+_state4Duration, 0);
			}
			else if (_state==2) {
				_state = 3;
				_alphaEaser.setTarget(timeNow, 1, timeNow+_state3Duration, 1);
			}
			else _state = -1; // multiple calls to hide() without an intervening call to show() makes the hiding immediate
			
			updateAlpha();
		}
		
		protected function onAlphaTimer(evt:TimerEvent=null):void {
			updateAlpha();
		}
		
		protected function onThumbTimer(evt:TimerEvent=null):void {
			if (_item.thumb.downloadState==Downloader.DONE_FAILURE) {
				Logger.report("failed to get thumb for "+_item.name);
				_thumbTimer.stop();
				hide();
			}
			else if (_item.thumb.downloadState==Downloader.DONE_SUCCESS) {
				_thumbLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onThumbLoaded, false, 0, true);
				_thumbLoader.loadBytes(_item.thumb.byteArray);
				_thumbTimer.stop();
				updateAlpha();
			}
			// else keep waiting for the thumb to load
		}
		
	}
}

