/**
* ...
* @author Default
* @version 0.1
*/

package br.hellokeita.display {
	import br.hellokeita.geom.PointColor;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;

	public class GradientBitmapData extends BitmapData{
		
		private var $fillColor:uint;
		private var spotArray:Array = new Array();
		private var pArray:Array;
		private var xArray:Array;
		private var yArray:Array;
		
		public function GradientBitmapData(width:int, height: int,transparent:Boolean = true, fillColor:uint = 0xffffffff):void {
			
			$fillColor = fillColor;
			super(width, height, transparent, fillColor);
			
		}
		
		public function addSpot(pointColor:PointColor):void {
			pointColor.addEventListener(Event.CHANGE, spotChange);
			spotArray.push(pointColor);
			redraw();
		}
		
		private function spotChange(ev:Event):void {
			redraw();
		}
		
		private function redraw():void {
			var i:int, j:int;
			
			this.lock();
			
			this.floodFill(0, 0, $fillColor);
			
			pArray = new Array();
			xArray = new Array();
			yArray = new Array();
			
			var l1:int, l2:int;
			l1 = spotArray.length;
			
			var px:int, py:int;
			
			for (i = 0; i < l1; i++) {
				
				px = round(spotArray[i].x);
				py = round(spotArray[i].y);
				
				if (xArray.indexOf(px) == -1) xArray.push(px);
				if (yArray.indexOf(py) == -1) yArray.push(py);
				
				if (!pArray[px]) pArray[px] = new Array();
				pArray[px][py] = spotArray[i].color;
				
			}
			
			xArray.sort(Array.NUMERIC);
			yArray.sort(Array.NUMERIC);
			
			l1 = xArray.length - 1;
			l2 = yArray.length - 1;
			
			for (i = 0; i < l1; i++) {
				for (j = 0; j < l2; j++) {
					drawRect(xArray[i], yArray[j], xArray[i + 1], yArray[j + 1]);
				}
			}

			this.unlock();
			
		}
		private function drawRect(x1:Number, y1:Number, x2:Number, y2:Number):void {
			var c1:Number, c2:Number, c3:Number, c4:Number;
			c1 = (isNaN(pArray[x1][y1]))?setColorAt(x1, y1):pArray[x1][y1];
			c2 = (isNaN(pArray[x2][y1]))?setColorAt(x2, y1):pArray[x2][y1];
			c3 = (isNaN(pArray[x2][y2]))?setColorAt(x2, y2):pArray[x2][y2];
			c4 = (isNaN(pArray[x1][y2]))?setColorAt(x1, y2):pArray[x1][y2];
			
			setPixel32(x1, y1, c1);
			setPixel32(x2, y1, c2);
			setPixel32(x2, y2, c3);
			setPixel32(x1, y2, c4);
			
			drawHalfs(x1, y1, x1, y2);
			drawHalfs(x2, y1, x2, y2);
			
			for (var i:int = y1; i <= y2; i++) {
				drawHalfs(x1, i, x2, i);
			}
			
		}
		private function setColorAt(x:Number, y:Number):Number {
			
			var lx:int = xArray.length - 1;
			var ly:int = yArray.length - 1;
			
			var px:int = xArray.indexOf(x);
			var py:int = yArray.indexOf(y);
			if (px == -1) return Number.NaN;
			if (py == -1) return Number.NaN;
			
			var c:Number, c1:Number, c2:Number, c3:Number, c4:Number;
			var px1:int, px2:int, py1:int, py2:int;
			var d:Number;
			
			
			if ((px == 0 || px == lx) && (py == 0 || py == ly)) {
				c = 0x00000000;
			}else if (px == 0 || px == lx) {
				
				py1 = yArray[py - 1];
				py2 = yArray[py + 1];
				
				c1 = (pArray[px][py1] !== null)?pArray[px][py1]:setColorAt(px, py1);
				c2 = (pArray[px][py2] !== null)?pArray[px][py2]:setColorAt(px, py2);
				
				d = (py2 - py) / (py2 - py1);
				c = c1 + (c2 - c1) * d;
				
			}else if (py == 0 || py == ly) {
				px1 = xArray[px - 1];
				px2 = xArray[px + 1];
				
				c1 = (pArray[px1][py] !== null)?pArray[px1][py]:setColorAt(px1, py);
				c2 = (pArray[px2][py] !== null)?pArray[px2][py]:setColorAt(px2, py);
				
				d = (px2 - px) / (px2 - px1);
				c = c1 + (c2 - c1) * d;
			}else {
				px1 = xArray[px - 1];
				px2 = xArray[px + 1];
				py1 = yArray[py - 1];
				py2 = yArray[py + 1];
				
				c1 = (pArray[px][py1] !== null)?pArray[px][py1]:setColorAt(px, py1);
				c2 = (pArray[px2][py] !== null)?pArray[px2][py]:setColorAt(px2, py);
				c3 = (pArray[px][py2] !== null)?pArray[px][py2]:setColorAt(px, py2);
				c4 = (pArray[px1][py] !== null)?pArray[px1][py]:setColorAt(px1, py);
				
				c = (c1 + c2 + c3 + c4) * .25;
			}
			
			if (!pArray[px]) pArray[px] = new Array();
			pArray[px][py] = c;
			
			return c;
		}
		private function drawHalfs(x1:Number, y1:Number, x2:Number, y2:Number):void {
			
			var px:int = round((x1 + x2) * .5);
			var py:int = round((y1 + y2) * .5);
			
			var s1:Array = splitColor(pArray[x1][y1]);
			var s2:Array = splitColor(pArray[x2][y1]);
			var s3:Array = splitColor(pArray[x2][y2]);
			var s4:Array = splitColor(pArray[x1][y2]);
			var c:uint = joinColor(round((s1[0] + s2[0] + s3[0] + s4[0]) * .25), round((s1[1] + s2[1] + s3[1] + s4[1]) * .25), round((s1[2] + s2[2] + s3[2] + s4[2]) * .25), round((s1[3] + s2[3] + s3[3] + s4[3]) * .25));
			
			this.setPixel32(px, py, c);
			
			if (!pArray[px]) pArray[px] = new Array();
			pArray[px][py] = c;
			if ((px - x1) > 1) {
				drawHalfs(x1, y1, px, y2);
				drawHalfs(px, y1, x2, y2);
			}
			if ((py - y1) > 1) {
				drawHalfs(x1, y1, x2, py);
				drawHalfs(x1, py, x2, y2);
			}
		}
		private static function round(n:Number):int {
			return int(n + .5);
		}
		private static function splitColor(c:uint):Array {
			return [(c >> 24) & 0xff, (c >> 16) & 0xff, (c >> 8) & 0xff, c & 0xff];
		}
		private static function joinColor(a:int, r:int, g:int, b:int):uint {
			return (a << 24) + (r << 16) + (g << 8) + b;
		}
	}
}