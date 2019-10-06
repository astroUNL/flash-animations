
package edu.unl.astro.utils {
	
	import flash.display.Sprite;
	
	/*
	import edu.unl.astro.utils.PlotSeries;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import fl.events.DataChangeEvent;
	import fl.data.DataProvider;
	import fl.motion.easing.Cubic;
	*/
		
	public class FocusWindow extends Sprite {
		
		private var _windowWidth:Number = 100;
		private var _windowHeight:Number = 100;
		
		
		private var _backgroundMouseAreaSP:Sprite;
		
		private var _corner1SP:Sprite;
		private var _corner2SP:Sprite;
		private var _corner3SP:Sprite;
		private var _corner4SP:Sprite;
		private var _side1SP:Sprite;
		private var _side2SP:Sprite;
		private var _side3SP:Sprite;
		private var _side4SP:Sprite;
		
		public function FocusWindow(...argsList):void {
			
			_backgroundMouseAreaSP = new Sprite();
			
			
			addChild(_backgroundMouseAreaSP);
			
			
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		public function updateBackground():void {
			
			_backgroundMouseAreaSP.graphics.clear();
			_backgroundMouseAreaSP.beginFill(0xff0000, 0.2);
			_backgroundMouseAreaSP.drawRect(0, -_windowHeight, _windowWidth, _windowHeight);
			_backgroundMouseAreaSP.endFill();
			
			
			
			
			
		}
		
		public function loadSettings(...argsList):void {
			// this function can be used to set any number of the public properties of the plot
			// component; these properties should be passed as properties of an object or objects
			// passed as arguments; this works the same as the constructor initialization
			loadSettingsFromObjectsList(argsList)
		}
		
		protected function loadSettingsFromObjectsList(objectsList:Array):void {
			// this utility function does the actual work of parsing the arguments
			// from loadSettings and the constructor
			var propName:String;
			for each (var item in objectsList) {
				if (item is Object) {
					for (propName in item) this[propName] = item[propName];
				}
			}
		}
		
		public function clear():void {
			
			
			
		}
		
		
		
		public function get windowWidth():Number {
			return _windowWidth;
		}
		
		public function set windowWidth(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0 || arg>3000) return;
			_windowWidth = arg;
		}
		
		public function get windowHeight():Number {
			return _windowWidth;
		}
		
		public function set windowHeight(arg:Number):void {
			if (isNaN(arg) || !isFinite(arg) || arg<=0 || arg>3000) return;
			_windowHeight = arg;
		}		
		
	}
	
	
}
