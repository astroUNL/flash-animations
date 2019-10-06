
package edu.unl.astro.utils {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import fl.data.DataProvider;
	import fl.events.DataChangeEvent; 

	public class PlotSeries extends EventDispatcher {
			
		// methods:
		//	refresh()
		//	loadSettings(settingsObj) (an object with 
		
		// properties:
		//	dataProvider
		//	showPoints
		//	showLines
		//	pointRadius
		//	pointFillColor
		//	pointFillAlpha
		//	pointOutlineThickness
		//	pointOutlineColor
		//	pointOutlineAlpha
		//	lineThickness
		//	lineColor
		//	lineAlpha
		//  xAxisPropertyName
		//	yAxisPropertyName
		
		// note that changes to the style properties (all properties except for dataProvider) will not
		// be observed unless refresh() is called or the data changes
		
		// refresh does not need to be called after changing or setting the dataProvider property; for
		// changes to the data provider use that class's methods
		
		// events:
		//	DATA_CHANGE - data has changed (identical to the DataProvider event)
		//  REFRESH_REQUESTED - need to redraw the series, either due a user request (the style may have
		//					changed) or due to the fact that a new data provider has been specified
		
		public var showPoints:Boolean = true;
		public var showLines:Boolean = false;
		public var pointRadius:Number = 2;
		public var pointFillColor:uint = 0xfafafa;
		public var pointFillAlpha:Number = 1;
		public var pointOutlineThickness:Number = 1;
		public var pointOutlineColor:uint = 0x909090;
		public var pointOutlineAlpha:Number = 1;
		public var lineThickness:Number = 1;
		public var lineColor:uint = 0xa0a0a0;
		public var lineAlpha:Number = 1;
		
		// if a series's property name string is empty (the default) then the plot's property name is used
		public var xAxisPropertyName:String = "";
		public var yAxisPropertyName:String = "";
		
		public static const REFRESH_REQUESTED:String = "refreshRequested";
		
		private var _dataProvider:DataProvider;
		
		public function PlotSeries(...argsList):void {
			dataProvider = new DataProvider();
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		public function loadSettings(...argsList):void {
			loadSettingsFromObjectsList(argsList)
		}
		
		private function loadSettingsFromObjectsList(objectsList:Array):void {
			var propName:String;
			for each (var item in objectsList) {
				if (item is Object) {
					for (propName in item) this[propName] = item[propName];					
				}
			}
		}
		
		public function refresh():void {
			dispatchEvent(new Event(PlotSeries.REFRESH_REQUESTED));
		}
		
		public function set dataProvider(arg:DataProvider):void {
			if (_dataProvider!=null) {
				_dataProvider.removeEventListener(fl.events.DataChangeEvent.DATA_CHANGE, onDataChanged);
			}
			_dataProvider = arg;
			if (_dataProvider!=null) {
				_dataProvider.addEventListener(fl.events.DataChangeEvent.DATA_CHANGE, onDataChanged);
			}
			dispatchEvent(new Event(PlotSeries.REFRESH_REQUESTED));
		}
		
		public function get dataProvider():DataProvider {
			return _dataProvider;
		}
		
		private function onDataChanged(evt:DataChangeEvent):void {
			dispatchEvent(evt);
		}
		
	}
}
