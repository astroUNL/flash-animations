
package {
	
	import flash.display.Sprite;
	
	public class HistoryPlot extends Sprite {
		
		public static const HistoryDuration:Number = 15000;
		public static const HistoryWidth:Number = 700;
		public static const HistoryHeight:Number = 100;
		
		protected var _plotSP:Sprite;
		
		public function HistoryPlot() {
			_plotSP = new Sprite();
			addChild(_plotSP);
			
			graphics.clear();
			graphics.moveTo(0, HistoryHeight);
			graphics.lineStyle(1, 0xa0a0a0);
			graphics.lineTo(HistoryWidth, HistoryHeight);
			graphics.lineTo(HistoryWidth, -HistoryHeight);
			graphics.lineTo(0, -HistoryHeight);
			graphics.lineTo(0, HistoryHeight);
		}
		
		public function plotData(data:Array, timeNow:Number):void {
			_plotSP.graphics.clear();
			_plotSP.graphics.lineStyle(2, 0xff0000);
			
			var hx:Number;
			var hy:Number;
			
			var i:int = 0;
			
			var historyStart:Number = timeNow - HistoryDuration;
			
			var xScale:Number = HistoryWidth/HistoryDuration;
			var yScale:Number = -90;
			
			_plotSP.graphics.moveTo(xScale*(data[0].time-historyStart), yScale*data[0].value);
			
			for (i=1; i<data.length; i++) {
				_plotSP.graphics.lineTo(xScale*(data[i].time-historyStart), yScale*data[i].value);
			}			
		}		
		
	}
	
}

