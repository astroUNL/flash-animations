
package {
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import flash.text.TextFormat;
	import fl.managers.StyleManager;

	
	public class dopplerShiftDemo2 extends Sprite {
		
		public static const WaveVelocity:Number = 30/1000;
		
		//protected var _controlPanel:ControlPanel;
		
		protected var _observer:Observer;
		protected var _source:ISource;
		protected var _timeLast:Number;
		
		protected var _observerPlot:HistoryPlot;
		protected var _sourcePlot:HistoryPlot;
		
		protected var _timeStep:Number = 25;
		
		protected var _observerData:Array = [];
		protected var _sourceData:Array = [];
		
		protected var _circlesSP:Sprite;
		protected var _circles:CircleCropper;
		
		
		protected var _observerPathSP:Sprite;
		protected var _sourcePathSP:Sprite;
		
		
		protected var _timeLastSecond:int = 0;
		
		protected var _maskSP:Sprite;
		protected var _maskedAreaSP:Sprite;
		protected var _backgroundSP:Sprite;
		
		protected var _expirationAge:Number;
		
		
		
		
		public function dopplerShiftDemo2() {
			
			StyleManager.setStyle("disabledTextFormat", new TextFormat("Verdana", 11, 0x999999));
			StyleManager.setStyle("textFormat", new TextFormat("Verdana", 11, 0x000000));
			StyleManager.setStyle("embedFonts", true);
			StyleManager.setStyle("focusRectSkin", NAAP_focusRectSkin);
			
			titleBar.addEventListener("reset", onReset);
			
			titleBar.title = "Doppler Shift Demonstrator";
			
			animationStateButton.addEventListener("change", onAnimationStateButtonChanged);
			emissionStateButton.addEventListener("change", onEmissionStateButtonChanged);
			showPathsCheckBox.addEventListener("change", onShowPathsChanged);
			
			var timeNow:Number = TimeKeeper.getTime();
			
			
			_observer = new Observer();
			_observer.setPosition(new Position(timeNow, 500, 300));			
			
			var range:Rectangle = new Rectangle(7, 209, 686, 354);
			var dragMargin:Number = 5;
			var dragRange:Rectangle = new Rectangle(range.x+dragMargin, range.y+dragMargin, range.width-2*dragMargin, range.height-2*dragMargin);
			
			_backgroundSP = new Sprite();
			_backgroundSP.graphics.clear();
			_backgroundSP.graphics.lineStyle(1, 0x606060);
			_backgroundSP.graphics.beginFill(0xfafafa);
			_backgroundSP.graphics.drawRect(range.x, range.y, range.width, range.height);
			_backgroundSP.graphics.endFill();
			addChild(_backgroundSP);
			
			_maskSP = new Sprite();
			_maskSP.graphics.clear();
			_maskSP.graphics.lineStyle(1, 0xc0c0ff);
			_maskSP.graphics.beginFill(0xff0000, 0.1);
			_maskSP.graphics.drawRect(range.x, range.y, range.width, range.height);
			_maskSP.graphics.endFill();
			
			_maskedAreaSP = new Sprite();
			_maskedAreaSP.mask = _maskSP;
			addChild(_maskedAreaSP);
			
			
			_source = new Source();
			_source.setPosition(new Position(timeNow, 300, 250));
			
			
			_observer.setRange(dragRange);
			(_source as DraggableObject).setRange(dragRange);
			
			_circlesSP = new Sprite();
			_maskedAreaSP.addChild(_circlesSP);
			
			_observerPathSP = new Sprite();
			_maskedAreaSP.addChild(_observerPathSP);
			_observer.setPathGraphicsObject(_observerPathSP.graphics);
			
			_sourcePathSP = new Sprite();
			_maskedAreaSP.addChild(_sourcePathSP);
			(_source as DraggableObject).setPathGraphicsObject(_sourcePathSP.graphics);
			
			_maskedAreaSP.addChild(_observer);
			_maskedAreaSP.addChild(_source as Sprite);
			
			_observerPlot = new HistoryPlot();
			_observerPlot.x = 22;
			_observerPlot.y = 153;
			addChild(_observerPlot);
			
			_sourcePlot = new HistoryPlot();
			_sourcePlot.x = 22;
			_sourcePlot.y = 83;
			addChild(_sourcePlot);
						
			//_source.setEmissionState(true);
			
			_circles = new CircleCropper();
			_circles.graphics = _circlesSP.graphics;
			_circles.range = range;
			
			
			var cornerToCornerTime:Number = Math.sqrt(range.width*range.width + range.height*range.height)/WaveVelocity;
			
			
			_expirationAge = 1.25*Math.max(cornerToCornerTime, _sourcePlot.historyDuration, _observerPlot.historyDuration);
			

			_backgroundSP.addEventListener("mouseDown", onBackgroundPressed);
			
			_timeLast = TimeKeeper.getTime();
			_timeLastSecond = Math.floor(_timeLast/1000);
			
			//addEventListener("enterFrame", onEnterFrameFunc);
			
			_updateTimer = new Timer(10);
			_updateTimer.addEventListener("timer", onUpdateTimer);
			_updateTimer.start();
			
			
			_source.addEventListener("onTransition", onEmissionTransition);
			
			_source.addEventListener("positionReset", onSourcePositionReset);
			_observer.addEventListener("positionReset", onObserverPositionReset);
			
			rateSlider.addEventListener("change", onRateChanged);
			
			
			
			setChildIndex(titleBar, numChildren-1);
		}
		
		protected var _updateTimer:Timer;

		protected function onReset(...ignored):void {
			
			// run the simulator
			TimeKeeper.running = true;
			animationStateButton.selected = true;
			animationStateButton.label = "pause simulation";
			
			// reset the rate
			TimeKeeper.rate = rateSlider.value = 1;
			
			// hide paths
			showPathsCheckBox.selected = false;
			onShowPathsChanged();
			
			// reset the source and observer
			// these calls will cause the onSourcePositionReset, onSourcePositionReset,
			// and onEmissionTransition functions to be called, clearing the historical data, turn off
			// emission, and make sure the emission button is in the correct state
			var timeNow:Number = TimeKeeper.getTime();
			_source.setPosition(new Position(timeNow, 300, 250));
			_observer.setPosition(new Position(timeNow, 500, 300));			
		}		
			
		protected function onRateChanged(...ignored):void {
			TimeKeeper.rate = rateSlider.value;			
		}
		
		protected function onSourcePositionReset(...ignored):void {
			_sourceData = [];
			_observerData = [];
			emissionStateButton.selected = false;
			emissionStateButton.label = "start emission";
		}
		
		protected function onObserverPositionReset(...ignored):void {
			_observerData = [];
		}

		protected function onBackgroundPressed(...ignored):void {
			_observer.stopMotion();
			(_source as DraggableObject).stopMotion();
		}
		
		protected function onShowPathsChanged(...ignored):void {
			_observer.setShowPath(showPathsCheckBox.selected);
			(_source as DraggableObject).setShowPath(showPathsCheckBox.selected);
		}
		
		public function onEmissionStateButtonChanged(...ignored):void {
			_source.setEmissionState(emissionStateButton.selected);
			emissionStateButton.label = (emissionStateButton.selected) ? "stop emission" : "start emission";
		}
		
		public function onEmissionTransition(...ignored):void {
			if (_source.inTransition) {
				emissionStateButton.enabled = false;
			}
			else {
				emissionStateButton.enabled = true;
			}
		}
		
		public function onAnimationStateButtonChanged(...ignored):void {
			TimeKeeper.running = !TimeKeeper.running;
			animationStateButton.label = (TimeKeeper.running) ? "pause simulation" : "resume simulation";			
		}
		
		
		public function onUpdateTimer(evt:TimerEvent):void {
			onEnterFrameFunc();
			evt.updateAfterEvent();			
		}
		
		public var _timerLast:Number = 0;
		
		public function onEnterFrameFunc(...ignored):void {
			var startTimer:Number = getTimer();
			
			var timeNow:Number = TimeKeeper.getTime();
			
			//trace("timeNow: " +timeNow+", dt: "+(timeNow-_timeLast));
			
			if (timeNow==_timeLast) return;
			
			var timeNowSecond:int = Math.floor(timeNow/1000);
			var nNow:int = Math.floor(timeNow/_timeStep);
			var nLast:int = Math.floor(_timeLast/_timeStep);
			var n:int = nNow - nLast;			
			
			var i:int;
			
			_source.update(timeNow);
			_observer.update(timeNow);
			
			var timeStep:Number = 10;
			var numSteps:Number = 1000;
			
			var posList:Array = [];
			for (i=0; i<numSteps; i++) {
				posList[i] = new Position(timeNow-i*timeStep);
			}
			_observer.getPositions(posList);
			
			
			// update the source plot
			var newSourceData:Array = [];
			for (i=0; i<n; i++) {
				newSourceData[i] = {time: (nLast+1+i)*_timeStep};
			}
			_source.getValues(newSourceData);
			_sourceData = _sourceData.concat(newSourceData);
			_sourcePlot.plotData(_sourceData, timeNow);
			
			
			// update the observer plot
			var newObserverData:Array = [];
			for (i=0; i<n; i++) {
				newObserverData[i] = new Position((nLast+1+i)*_timeStep);
			}
			_observer.getPositions(newObserverData);
			_source.getObservedValues(newObserverData, WaveVelocity);
			_observerData = _observerData.concat(newObserverData);
			_observerPlot.plotData(_observerData, timeNow);
			
			
			var expirationTime:Number = timeNow - _expirationAge;
			
			
			// draw the circles representing the wave crests
			var peaksList:Array = _source.getPeaks(expirationTime, timeNow);
			_circles.graphics.clear();
			_circles.graphics.lineStyle(1, 0xa0a0a0);
			for (i=0; i<peaksList.length; i++) {
				_circles.drawCircle(peaksList[i].x, peaksList[i].y, WaveVelocity*(timeNow-peaksList[i].time));
			}
			
			
			
			if (_timeLastSecond!=timeNowSecond && timeNowSecond%1==0 && true) {
//				trace("update:");
//				//trace(" _timeLastSecond: "+_timeLastSecond);
//				trace(" timeNowSecond: "+timeNowSecond);
//				trace(" sourceData.length: "+_sourceData.length);
//				trace(" observerData.length: "+_observerData.length);
//				
//				trace(" source log length: "+(_source as DraggableObject)._positionLog.getRawLog().length);
//				trace(" observer log length: "+_observer._positionLog.getRawLog().length);
//				
//				trace(timeNowSecond+", "+(_source as DraggableObject)._positionLog.getRawLog().length+", "+_observer._positionLog.getRawLog().length+", "+(_source as Source)._phiIntervalsList.length+", "+_sourceData.length+", "+_observerData.length+", "+System.totalMemory+", "+(TimeKeeper.getTime()-timeNow));
				/*
				trace(" last 100 observer and source data points:");
				for (i=0; i<100; i++) {
					trace("  obs "+i+": "+_observerData[_observerData.length-i-1].time+", "+_observerData[_observerData.length-i-1].value);
					trace("  src "+i+": "+_sourceData[_sourceData.length-i-1].time+", "+_sourceData[_sourceData.length-i-1].value);
				}
				*/
				
				/*
				trace(" last 100 observer positions:");
				for (i=0; i<Math.min(100, obsLog.length); i++) {
					trace("  "+i+", "+obsLog[obsLog.length-1-i].time+", "+obsLog[obsLo
				}g.length-1-i].x+", "+obsLog[obsLog.length-1-i].y);
				
				*/
				
				if (timeNowSecond%5==0) {
					//trace("purging old data, timeNow: "+timeNow);
					expire(_sourceData, timeNow-_sourcePlot.historyDuration);
					expire(_observerData, timeNow-_observerPlot.historyDuration);
					_source.expireHistory(expirationTime);
					_observer.expireHistory(expirationTime);
					//trace("memory usage: "+System.totalMemory);
					
				}
			}
			
			
			trace("update: "+(getTimer()-startTimer)+", wait: "+(startTimer-_timerLast));
			_timerLast = startTimer;
			
			//trace(timeNow+", "+System.totalMemory+", "+(TimeKeeper.getTime()-timeNow));
			_timeLast = timeNow;
			_timeLastSecond = timeNowSecond;
		}
		
		public function expire(data:Array, expTime:Number):void {
			for (var delCount:uint = 0; delCount<data.length; delCount++) {
				if (data[delCount].time>=expTime) break;				
			}
			data.splice(0, delCount);
		}
	}	
	
}
