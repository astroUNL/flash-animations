
package edu.unl.astro.starField {
	
	import flash.display.Sprite;
	
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import flash.utils.ByteArray;
	import flash.events.Event;
	
	public class ObservationsPlot extends Sprite {
		
		private var _width:Number = 10;
		private var _height:Number = 10;
		private var _plotType:String = ObservationsPlot.SCROLLING;
		private var _epoch:Number = 0;
		private var _autoExpand:Boolean = true;
		private var _maxValue:Number = 0;
		private var _minValue:Number = 0;
		private var _period:Number = 1;
		
		private var _measurementsList:Array = [];
		
		private var _measurementsBMD:BitmapData;
		private var _measurementsBM:Bitmap;
		private var _borderSP:Sprite;
		
		public static const SCROLLING:String = "scrolling";
		public static const CYCLIC:String = "cyclic";
		
		public function ObservationsPlot():void {
			
			_measurementsBM = new Bitmap();
			_borderSP = new Sprite();
			
			addChild(_measurementsBM);
			addChild(_borderSP);
			
		}
		
		private var _cursorLast:Number = 0;
		private var _epochLast:Number = 0;
		
		private function update(...ignored):void {
			
			if (_measurementsList.length==0) return;
			
			var startTimer:Number = getTimer();
			
			var i:int;
			var x:Number;
			var y:Number;
			
			var fromScratch:Boolean = true;
			
			var xScale:Number;
			var yScale:Number;
			var max:Number;
			var min:Number;
			var m:Number;
			
			var margin:Number = 0;
			

			
			
			if (_plotType==ObservationsPlot.CYCLIC) {
				
				if (fromScratch) {
					
					if (_autoExpand) {
						
						max = _measurementsList[0].value;
						min = _measurementsList[0].value;
						
						for (i=1; i<_measurementsList.length; i++) {
							m = _measurementsList[i].value;
							if (m>max) max = m;
							else if (m<min) min = m;							
						}
						
						yScale = (_height - 2*margin)/(max - min);
						
						_minValue = min - (margin/yScale);
						_maxValue = max + (margin/yScale);
					}
					
					xScale = _width/_period;
					
					_measurementsBMD.fillRect(new Rectangle(0, 0, _width, _height), 0x00ffffff);
					
					for (i=0; i<_measurementsList.length; i++) {
						
						x = xScale*((_measurementsList[i].epoch%_period + _period)%_period);
						y = yScale*(_measurementsList[i].value-_minValue);
						
						if (y>0 && y<_height) {
							_measurementsBMD.setPixel32(int(x), int(y), 0xffff0000);
							_measurementsBMD.setPixel32(int(x)-1, int(y), 0xffff0000);
							_measurementsBMD.setPixel32(int(x), int(y)-1, 0xffff0000);
							_measurementsBMD.setPixel32(int(x), int(y)+1, 0xffff0000);
							_measurementsBMD.setPixel32(int(x)+1, int(y), 0xffff0000);
						}
					}					
				}
				else {
					
					
					
					
				}
				
			}
			else {
				
				
				if (_autoExpand) {
						
					max = _measurementsList[0].value;
					min = _measurementsList[0].value;
					
					for (i=1; i<_measurementsList.length; i++) {
						m = _measurementsList[i].value;
						if (m>max) max = m;
						else if (m<min) min = m;							
					}
					
					yScale = (_height - 2*margin)/(max - min);
					
					
					_minValue = min - (margin/yScale);
					_maxValue = max + (margin/yScale);
					
					//_minValue = min - (20/yScale);
					//_maxValue = max + (20/xScale);
				}
					

				
				xScale = _width/_period;
				//yScale = _height/(_maxValue-_minValue);
					
				var cursorNow:Number = (_epoch%_period + _period)%_period;
				
				//var mObj:Object = _measurementsList[_measurementsList.length-1];
				
				if (_cursorLast>cursorNow) {
					// clear and star over
					_measurementsList = [];
					_measurementsBMD.fillRect(new Rectangle(0, 0, _width, _height), 0x00ffffff);
				}
				
				
				
					_measurementsBMD.fillRect(new Rectangle(0, 0, _width, _height), 0x00ffffff);
					
					for (i=0; i<_measurementsList.length; i++) {
						
						x = xScale*((_measurementsList[i].epoch%_period + _period)%_period);
						y = yScale*(_measurementsList[i].value-_minValue);
						
						if (y>0 && y<_height) {
							_measurementsBMD.setPixel32(int(x), int(y), 0xffff0000);
							_measurementsBMD.setPixel32(int(x)-1, int(y), 0xffff0000);
							_measurementsBMD.setPixel32(int(x), int(y)-1, 0xffff0000);
							_measurementsBMD.setPixel32(int(x), int(y)+1, 0xffff0000);
							_measurementsBMD.setPixel32(int(x)+1, int(y), 0xffff0000);
						}
					}					
				
				
				
				/*
				
				
				
				x = xScale*((mObj.epoch%_period + _period)%_period);
				y = yScale*(mObj.value-_minValue);
				
				if (y>0 && y<_height) {
					_measurementsBMD.setPixel32(int(x), int(y), 0xffff0000);
					_measurementsBMD.setPixel32(int(x)-1, int(y), 0xffff0000);
					_measurementsBMD.setPixel32(int(x), int(y)-1, 0xffff0000);
					_measurementsBMD.setPixel32(int(x), int(y)+1, 0xffff0000);
					_measurementsBMD.setPixel32(int(x)+1, int(y), 0xffff0000);
				}
				*/
				
				_cursorLast = cursorNow;				
				_epochLast = _epoch;
			}
			
			trace("min: "+_minValue);
			trace("max: "+_maxValue);
			
//			trace("update plot: "+(getTimer()-startTimer));
		}
		
		public function setDimensions($width:Number, $height:Number):void {
			if (!isFinite($width) || isNaN($width) || $width<=0 || !isFinite($height) || isNaN($height) || $height<=0) return;
			
			_width = $width;
			_height = $height;
			
			_measurementsBMD = new BitmapData(_width, _height, true, 0x00ffffff);
			_measurementsBM.bitmapData = _measurementsBMD;
			_measurementsBM.x = 0;
			_measurementsBM.y = -height;
			
			_borderSP.graphics.clear();
			_borderSP.graphics.moveTo(0, 0);
			_borderSP.graphics.lineStyle(1, 0x000000);
			_borderSP.graphics.lineTo(_width, 0);
			_borderSP.graphics.lineTo(_width, -_height);
			_borderSP.graphics.lineTo(0, -_height);
			_borderSP.graphics.lineTo(0, 0);
		}
		
		public function addMeasurement($measurement:Number, $epoch:* = null):void {
			if (!isFinite($measurement) || isNaN($measurement)) return;
			if (($epoch is Number) && (!isFinite($epoch) || isNaN($epoch))) return;
			else _epoch = $epoch;
			_measurementsList.push({epoch: _epoch, value: $measurement});
			update();
		}
		
		public function clear():void {
			_measurementsList = [];
			update();
		}
		
		public function get plotType():String {
			return _plotType;
		}
		
		public function set plotType(arg:String):void {
			if (arg!=ObservationsPlot.SCROLLING || arg!=ObservationsPlot.CYCLIC) return;
			_plotType = arg;
			update(true);
		}
		
		public function get epoch():Number {
			return _epoch;			
		}
		
		public function set epoch(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			_epoch = arg;
			update();
		}
		
		public function get autoExpand():Boolean {
			return _autoExpand;
		}
		
		public function set autoExpand(arg:Boolean):void {
			_autoExpand = arg;
			if (_autoExpand) update();
		}
		
		public function get maxValue():Number {
			return _maxValue;
		}
		
		public function set maxValue(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			if (!_autoExpand) {
				_maxValue = arg;
				update();
			}
		}
									   
		public function get minValue():Number {
			return _minValue;
		}
		
		public function set minValue(arg:Number):void {
			if (!isFinite(arg) || isNaN(arg)) return;
			if (!_autoExpand) {
				_minValue = arg;
				update();
			}
		}
		
		public function get period():Number{
			return _period;
		}
		
		public function set period($period:Number):void {
			if (!isFinite($period) || isNaN($period)) return;
			_period = $period;
			if (_plotType==ObservationsPlot.CYCLIC) update(true);
		}
			
		
		
	}
	
	
	
	
	
}
