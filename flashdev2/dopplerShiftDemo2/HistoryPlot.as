
package {

	import flash.display.Sprite;

	public class HistoryPlot extends Sprite {

		public var historyDuration:Number = 15000;
		public var historyWidth:Number = 400;
		public var historyHeight:Number = 20;

		public var borderColor:uint = 0xe0e0e0;
		public var borderThickness:Number = 1;

		public var backgroundColor:uint = 0xffffff;
		public var backgroundAlpha:Number = 0.8;

		public var curveColor:uint = 0xa0a0a0;
		public var curveThickness:Number = 0;

		public var curveFractionalHeight:Number = 0.82;

		protected var _plotSP:Sprite;
		protected var _backgroundSP:Sprite;
		protected var _borderSP:Sprite;

		public function HistoryPlot() {
			_backgroundSP = new Sprite();
			addChild(_backgroundSP);

			_plotSP = new Sprite();
			addChild(_plotSP);

			_borderSP = new Sprite();
			addChild(_borderSP);

			drawPlotWindow();
		}
		
		public function drawPlotWindow():void {

			_backgroundSP.graphics.clear();
			_backgroundSP.graphics.moveTo(0, historyHeight);
			_backgroundSP.graphics.beginFill(backgroundColor, backgroundAlpha);
			_backgroundSP.graphics.lineTo(historyWidth, historyHeight);
			_backgroundSP.graphics.lineTo(historyWidth, -historyHeight);
			_backgroundSP.graphics.lineTo(0, -historyHeight);
			_backgroundSP.graphics.lineTo(0, historyHeight);
			_backgroundSP.graphics.endFill();

			_borderSP.graphics.clear();
			_borderSP.graphics.moveTo(0, historyHeight);
			_borderSP.graphics.lineStyle(borderThickness, borderColor);
			_borderSP.graphics.lineTo(historyWidth, historyHeight);
			_borderSP.graphics.lineTo(historyWidth, -historyHeight);
			_borderSP.graphics.lineTo(0, -historyHeight);
			_borderSP.graphics.lineTo(0, historyHeight);
		}
		
		public function plotData(data:Array, timeNow:Number):void {
			
			_plotSP.graphics.clear();
			
			if (data==null || data.length==0) return;
			
			_plotSP.graphics.lineStyle(curveThickness, curveColor);

			var hx:Number;
			var hy:Number;

			var i:int = 0;

			var historyStart:Number = timeNow - historyDuration;

			var xScale:Number = historyWidth/historyDuration;
			var yScale:Number = -curveFractionalHeight*historyHeight;

			for (i=0; i<data.length; i++) {
				if (data[i].time>=historyStart) {
					break;
				}
			}
			//trace("skipped to i = "+i);

			_plotSP.graphics.moveTo(xScale*(data[i].time-historyStart), yScale*data[i].value);

			for (i; i<data.length; i++) {
				_plotSP.graphics.lineTo(xScale*(data[i].time-historyStart), yScale*data[i].value);
			}
		}
	}
}