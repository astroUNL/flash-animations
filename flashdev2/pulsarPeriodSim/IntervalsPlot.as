
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
		
	
	public class IntervalsPlot extends Sprite {
		
		// update must be called after changing these properties
		public var useColor:Boolean = true;
		public var minDelta:Number = 1;
		public var maxDelta:Number = 500;
		
		
		protected var _plotWidth:Number;
		protected var _plotHeight:Number;
		protected var _plotTimespan:Number;
		
		protected var _borderThickness:Number = 1;
		protected var _borderColor:uint = 0xd0d0d0;
		protected var _backgroundColor:uint = 0xffffff;
		protected var _backgroundAlpha:Number = 1;
		protected var _dataColor:uint = 0x808080;
		
		protected var _background:Shape;
		protected var _data:Shape;
		protected var _dataMask:Shape;
		protected var _border:Shape;
		
		protected var _dataList:Array = [];
		protected var _tmpList:Array = [];
				
		protected var _time:Number = 0;
				
		
		public function IntervalsPlot(w:Number=300, h:Number=170, t:Number=60000) {
			
			_plotWidth = w;
			_plotHeight = h;
			_plotTimespan = t;
			
			_background = new Shape();
			addChild(_background);
			
			_data = new Shape();
			addChild(_data);
			
			_dataMask = new Shape();
			addChild(_dataMask);
			
			_border = new Shape();
			addChild(_border);
			
			_data.mask = _dataMask;
			
			_background.graphics.clear();
			_background.graphics.beginFill(_backgroundColor, _backgroundAlpha);
			_background.graphics.drawRect(0, -_plotHeight, _plotWidth, _plotHeight);
			_background.graphics.endFill();
			
			_dataMask.graphics.clear();
			_dataMask.graphics.beginFill(0xff0000);
			_dataMask.graphics.drawRect(0, -_plotHeight, _plotWidth, _plotHeight);
			_dataMask.graphics.endFill();
			
			_border.graphics.clear();
			_border.graphics.lineStyle(_borderThickness, _borderColor);
			_border.graphics.drawRect(0, -_plotHeight, _plotWidth, _plotHeight);
		}
		
		override public function get width():Number {
			return _plotWidth;
		}
		
		override public function set width(arg:Number):void {
			trace("fail - set plot width with constructor");
		}
		
		override public function get height():Number {
			return _plotHeight;
		}
		
		override public function set height(arg:Number):void {
			trace("fail - set plot width with constructor");
		}
		
		public function addData(data:Array):void {
			// the points passed here should have time, delta, and color properties
			for (var i:int = 0; i<data.length; i++) _dataList[_dataList.length] = data[i];			
		}
		
		public function clearData():void {
			_dataList = [];			
		}
		
		public function update(time:Number=-1):void {
			
			if (time<0) time = _time;
			else _time = time;
			
			var cutoffTime:Number = _time - _plotTimespan;
									
			var xScale:Number = _plotWidth/_plotTimespan;
			var yScale:Number = -_plotHeight/(maxDelta - minDelta);
			
			var g:Graphics = _data.graphics;
			
			g.clear();
			
			var pt:Object;
			
			_tmpList = [];
			
			var x:Number, y:Number;
			
			var i:int;
			var n:int = _dataList.length;
			
			for (i=0; i<n; i++) {
				pt = _dataList[i];
				
				if (pt.time>=cutoffTime) {
					_tmpList[_tmpList.length] = pt;
					
					if (pt.time<_time) {
						
						if (useColor) g.beginFill(pt.color);
						else g.beginFill(_dataColor);
						
						g.drawCircle(xScale*(pt.time-cutoffTime), yScale*(pt.delta-minDelta), 2);
						g.endFill();
					}
				}
			}
			
			_dataList = _tmpList;
		}	
				
	}	
}

