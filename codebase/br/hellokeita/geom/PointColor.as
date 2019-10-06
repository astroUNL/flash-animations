/**
* ...
* @author Default
* @version 0.1
*/

package br.hellokeita.geom {
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class PointColor extends EventDispatcher{
		
		private static const CHANGE_EVENT:Event = new Event(Event.CHANGE);
		
		private var $x:Number;
		private var $y:Number;
		private var $color:uint;
		
		public function PointColor(x:Number = 0, y:Number = 0, color:uint = 0xffffffff) {
			
			$x = x;
			$y = y;
			$color = color;
			
		}
		public function set x(v:Number):void {
			$x = v;
			dispatchEvent(CHANGE_EVENT);
		}
		public function get x():Number {
			return $x;
		}
		public function set y(v:Number):void {
			$y = v;
			dispatchEvent(CHANGE_EVENT);
		}
		public function get y():Number {
			return $y;
		}
		public function set color(v:uint):void {
			$color = v;
			dispatchEvent(CHANGE_EVENT);
		}
		public function get color():uint {
			return $color;
		}
		
	}
	
}
