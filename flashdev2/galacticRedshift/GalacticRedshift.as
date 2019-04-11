
package {
	
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	import astroUNL.utils.easing.CubicEaser;
	import astroUNL.naap.NAAPTitleBar;
	
	
	public class GalacticRedshift extends Sprite {
		
		// the included file defines _redshiftOffset and _data (an array of objects with w and f properties)		
		include "m32.as";
		
		// the filters file defines the _filterSet array
		include "filters.as";
		
		protected var _graph:SpectrumGraph;
		protected var _visualization:SpectrumVisualization;
		
		protected var _minWavelength:Number;
		protected var _maxWavelength:Number;
		
		protected var _filtersTimer:Timer;
		protected var _filtersEaser:CubicEaser;
		
		protected var _filtersEaseDuration:Number = 200;
		protected var _filtersButtonX0:Number = 617;
		protected var _filtersButtonWidth0:Number = 120;
		protected var _filtersButtonX1:Number = 736;
		protected var _filtersButtonWidth1:Number = 42;		
		
		
		public function GalacticRedshift() {			
		
			_filtersEaser = new CubicEaser(0);
			_filtersTimer = new Timer(10);
			_filtersTimer.addEventListener(TimerEvent.TIMER, onFiltersTimer);
						
			titlebar.addEventListener(NAAPTitleBar.RESET, reset);
			
			zSlider.setValueFormat("fixed digits", 2);
			zSlider.setValueRange(0, 1);			
			zSlider.addEventListener("sliderChange", onZChanged);
			
			var spectrumWidth:Number = 700;
			var spectrumHeight:Number = 300;
			var visualizationHeight:Number = 30;
			
			_minWavelength = 250;
			_maxWavelength = 950;
			
			_graph = new SpectrumGraph(spectrumWidth, spectrumHeight, _data, _minWavelength, _maxWavelength, 1.05, _filterSet);
			_graph.x = 60;
			_graph.y = 555;
			_graph.addTickmarks([{w: 250}, {w: 300, label: "300 nm"}, {w: 350},
										   {w: 400, label: "400 nm"}, {w: 450},
										   {w: 500, label: "500 nm"}, {w: 550},
										   {w: 600, label: "600 nm"}, {w: 650},
										   {w: 700, label: "700 nm"}, {w: 750},
										   {w: 800, label: "800 nm"}, {w: 850},
										   {w: 900, label: "900 nm"}, {w: 950}]);
			addChild(_graph);
			
			var visualSpectrumWidth:Number = (SpectrumVisualization.visualMax - SpectrumVisualization.visualMin)*(spectrumWidth/(_maxWavelength - _minWavelength));
			
			_visualization = new SpectrumVisualization(visualSpectrumWidth, visualizationHeight, _data, SpectrumVisualization.visualMin, SpectrumVisualization.visualMax, 1.0);
			_visualization.x = _graph.x + (SpectrumVisualization.visualMin - _minWavelength)*(spectrumWidth/(_maxWavelength - _minWavelength));
			_visualization.y = _graph.y - spectrumHeight - 10;
			addChild(_visualization);
			
			setChildIndex(titlebar, numChildren-1);
			
			showHideFiltersButton.addEventListener(MouseEvent.CLICK, onShowHideFilters);
			
			import fl.managers.StyleManager;									   
			StyleManager.setStyle("disabledTextFormat", new TextFormat("Verdana", 11, 0x606060));
			StyleManager.setStyle("textFormat", new TextFormat("Verdana", 11, 0x000000));
			StyleManager.setStyle("embedFonts", true);
			StyleManager.setStyle("focusRectSkin", NAAP_focusRectSkin);
			
			addEventListener(Event.ADDED_TO_STAGE, reset);
		}
		
		protected function onShowHideFilters(evt:Event):void {
			showFilters = !showFilters;			
		}
		
		protected function get showFilters():Boolean {
			return (_filtersEaser.targetValue==1);			
		}
		
		protected function set showFilters(arg:Boolean):void {
			if (arg!=showFilters) {
				var timeNow:Number = getTimer();
				_filtersEaser.setTarget(timeNow, null, timeNow+_filtersEaseDuration, arg ? 1 : 0);
				_filtersTimer.start();
			}
			updateFiltersButtonLabel();
			updateFiltersTransition();
		}
		
		protected function setShowFilters(arg:Boolean, doEasing:Boolean=true):void {
			if (doEasing) {
				showFilters = arg;				
			}
			else {
				_filtersTimer.stop();
				_filtersEaser.init(arg ? 1 : 0);
				
				updateFiltersButtonLabel();
				updateFiltersTransition();
			}			
		}
		
		protected function onFiltersTimer(evt:TimerEvent):void {
			updateFiltersTransition();
			evt.updateAfterEvent();
		}
		
		protected function updateFiltersButtonLabel():void {
			showHideFiltersButton.label = (showFilters) ? "hide" : "show filter details";
		}
		
		protected function updateFiltersTransition():void {
			
			var timeNow:Number = getTimer();
			
			var u:Number;
			if (timeNow>_filtersEaser.targetTime) {
				u = _filtersEaser.targetValue;
				_filtersEaser.init(_filtersEaser.targetValue);
				_filtersTimer.stop();
			}
			else u = _filtersEaser.getValue(timeNow);				
			if (u<0) u = 0;
			else if (u>1) u = 1;
			
			showHideFiltersButton.x = _filtersButtonX0 + u*(_filtersButtonX1 - _filtersButtonX0);
			showHideFiltersButton.width = _filtersButtonWidth0 + u*(_filtersButtonWidth1 - _filtersButtonWidth0);
			
			filterStrengthsChart.alpha = u;
			filterLabels.alpha = u;
			_graph.setFiltersAlpha(u);
		}
		
		protected function reset(evt:Event=null):void {
			setShowFilters(false, false);
			zSlider.value = 0;	
			onZChanged();
		}
		
		protected function onZChanged(evt:Event=null):void {
			_graph.redshift = _visualization.redshift = zSlider.value + _redshiftOffset;
			filterStrengthsChart.setMagnitudes(_graph.getMagnitudes());
		}
		
	}	
}
