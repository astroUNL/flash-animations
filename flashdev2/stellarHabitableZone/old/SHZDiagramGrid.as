
package {
	
	import flash.display.Shape;
	
	public class SHZDiagramGrid extends Shape {
		
		public var minSpacing:Number = 15;
		public var lineThickness:Number = 1;
		public var lineColor:uint = 0xe0e0e0;
		public var minLineAlpha:Number = 0.05;
		public var maxLineAlpha:Number = 0.20;
		
		protected var _diagram:SHZDiagram;
		
		public function SHZDiagramGrid(diagram:SHZDiagram) {
			_diagram = diagram;
		}		
		
		public function update():void {	
			var minX:Number = -_diagram.starX;
			var maxX:Number = _diagram.width - _diagram.starX;
			var minY:Number = -_diagram.height/2;
			var maxY:Number = _diagram.height/2;
			
			var s:Number = _diagram.scale;
			
			var m:Number = minSpacing/s;
			var lg:Number = Math.log(m)/Math.LN10;
			var k:int = Math.ceil(lg);
			
			var spacing:Number, belowSpacing:Number;
			var majorMultiple:uint;
			
			if ((k-lg)>(Math.log(2)/Math.LN10)) {
				// use 5*10^(k-1) as the spacing
				belowSpacing = Math.pow(10, k-1);
				spacing = 5*belowSpacing;
				majorMultiple = 2;
			}
			else {
				// use 10^k as the spacing
				spacing = Math.pow(10, k);
				belowSpacing = 0.5*spacing;
				majorMultiple = 5;
			}
			
			var minorAlpha:Number = minLineAlpha + (maxLineAlpha - minLineAlpha)*(spacing - m)/(spacing - belowSpacing);
			var majorAlpha:Number = maxLineAlpha;
			
			var i:int;
			var x:Number, y:Number;
			
			graphics.clear();
			
			var xGridLimit:int = Math.ceil((maxX/s)/spacing);
			for (i=Math.ceil((minX/s)/spacing); i<xGridLimit; i++) {
				x = i*spacing*s;
				if (i%majorMultiple==0) graphics.lineStyle(lineThickness, lineColor, majorAlpha);
				else graphics.lineStyle(lineThickness, lineColor, minorAlpha);
				graphics.moveTo(x, minY);
				graphics.lineTo(x, maxY);
			}
			
			var yGridLimit:int = Math.ceil((maxY/s)/spacing);
			for (i=Math.ceil((minY/s)/spacing); i<yGridLimit; i++) {
				y = i*spacing*s;
				if (i%majorMultiple==0) graphics.lineStyle(lineThickness, lineColor, majorAlpha);
				else graphics.lineStyle(lineThickness, lineColor, minorAlpha);
				graphics.moveTo(minX, y);
				graphics.lineTo(maxX, y);
			}
		}		
	}	
}
