
package {
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Sprite;
	import edu.unl.astro.utils.Plot;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	
	public class DeltaMagOverlay extends Sprite {
		
		private var _linkedPlot:Plot;
		private var _mouseAreaSP:Sprite;
		private var _checkeredPatternSP:Sprite;
		private var _checkeredPatternMaskSP:Sprite;
		private var _deltaMagBar1SP:Sprite;
		private var _deltaMagBar2SP:Sprite;
		private var _activeBar:Sprite = null;
		private var _checkeredPatternBMD:BitmapData;
		private var _differenceTextField:TextField;
		private var _limit1:Number = -50;
		private var _limit2:Number = -100;
		private var _yOffset:Number = 0;
		private var _deltaMagDefined:Boolean = false;
		private var _plotWidth:Number;
		private var _plotHeight:Number;
		private var _enabled:Boolean = true;
		
		public var normalBarThickness:Number = 1;
		public var normalBarColor:uint = 0x909090;
		public var normalBarAlpha:Number = 1;
		public var activeBarThickness:Number = 3;
		public var activeBarColor:uint = 0x909090;
		public var activeBarAlpha:Number = 1;
		public var checkeredPatternColor1:uint = 0x50f0f0f0;
		public var checkeredPatternColor2:uint = 0x50c0c0c0;
		public var checkeredPatternSize:uint = 4;
		public var textFormat:TextFormat;
		public var textBorderColor = 0x80808080;
		public var textBackgroundColor = 0x80ffffff;
		
		public function DeltaMagOverlay(...argsList):void {
			_mouseAreaSP = new Sprite();
			_checkeredPatternSP = new Sprite();
			_checkeredPatternMaskSP = new Sprite();
			_deltaMagBar1SP = new Sprite();
			_deltaMagBar2SP = new Sprite();
			
			textFormat = new TextFormat("Verdana", 12, 0x000000);
			
			addChild(_checkeredPatternSP);
			addChild(_checkeredPatternMaskSP);
			addChild(_mouseAreaSP);
			addChild(_deltaMagBar1SP);
			addChild(_deltaMagBar2SP);
			
			_checkeredPatternSP.mask = _checkeredPatternMaskSP;
			
			setEnabled(true);
			
			_deltaMagBar1SP.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownOnBar);
			_deltaMagBar1SP.addEventListener(MouseEvent.ROLL_OVER, onRollOverBar);
			_deltaMagBar1SP.addEventListener(MouseEvent.ROLL_OUT, onRollOutFromBar);
			
			_deltaMagBar2SP.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownOnBar);
			_deltaMagBar2SP.addEventListener(MouseEvent.ROLL_OVER, onRollOverBar);
			_deltaMagBar2SP.addEventListener(MouseEvent.ROLL_OUT, onRollOutFromBar);
			
			if (argsList.length>0) setLinkedPlot(argsList[0]);
		}
		
		public function setLinkedPlot(arg:Plot):void {
			_linkedPlot = arg;
			
			x = _linkedPlot.x;
			y = _linkedPlot.y;
			
			var dim:Object = _linkedPlot.getPlotDimensions();
			_plotWidth = dim.width;
			_plotHeight = dim.height;
			
			_mouseAreaSP.graphics.clear();
			_mouseAreaSP.graphics.moveTo(0, 0);
			_mouseAreaSP.graphics.beginFill(0xff0000, 0);
			_mouseAreaSP.graphics.lineTo(0, -_plotHeight);
			_mouseAreaSP.graphics.lineTo(_plotWidth, -_plotHeight);
			_mouseAreaSP.graphics.lineTo(_plotWidth, 0);
			_mouseAreaSP.graphics.lineTo(0, 0);
			_mouseAreaSP.graphics.endFill();
			
			
			var fillRect:Rectangle = new Rectangle(0, 0, checkeredPatternSize, checkeredPatternSize);
			var patternBMD:BitmapData = new BitmapData(2*checkeredPatternSize, 2*checkeredPatternSize, true);
			patternBMD.fillRect(fillRect, checkeredPatternColor1);
			fillRect.x = checkeredPatternSize;
			patternBMD.fillRect(fillRect, checkeredPatternColor2);
			fillRect.y = checkeredPatternSize;
			patternBMD.fillRect(fillRect, checkeredPatternColor1);
			fillRect.x = 0;
			patternBMD.fillRect(fillRect, checkeredPatternColor2);
			
			
			_checkeredPatternSP.graphics.clear();
			_checkeredPatternSP.graphics.moveTo(0, 0);
			_checkeredPatternSP.graphics.beginBitmapFill(patternBMD);		
			_checkeredPatternSP.graphics.lineTo(0, -_plotHeight);
			_checkeredPatternSP.graphics.lineTo(_plotWidth, -_plotHeight);
			_checkeredPatternSP.graphics.lineTo(_plotWidth, 0);
			_checkeredPatternSP.graphics.lineTo(0, 0);
			_checkeredPatternSP.graphics.endFill();
		
			update();
		}
		
		public function setEnabled(arg:Boolean):void {
			_enabled = arg;
			if (_enabled) _mouseAreaSP.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownOverMouseArea);
			else _mouseAreaSP.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownOverMouseArea);
			update();
		}
		
		public function update():void {
			
			_deltaMagBar1SP.graphics.clear();
			_deltaMagBar2SP.graphics.clear();
			_checkeredPatternMaskSP.graphics.clear();
			
			if (_differenceTextField!=null) removeChild(_differenceTextField);
						
			_deltaMagBar1SP.graphics.lineStyle(normalBarThickness, normalBarColor, normalBarAlpha, false, "normal", "none");
			_deltaMagBar2SP.graphics.lineStyle(normalBarThickness, normalBarColor, normalBarAlpha, false, "normal", "none");
			
			if (_activeBar!=null) {
				_activeBar.graphics.lineStyle(activeBarThickness, activeBarColor, activeBarAlpha, false, "normal", "none");
			}
			
			if (_linkedPlot!=null && !isNaN(_limit1) && !isNaN(_limit2)) {
				// draw the limit bars
				_deltaMagBar1SP.graphics.moveTo(0, _limit1);
				_deltaMagBar1SP.graphics.lineTo(_plotWidth, _limit1);
				_deltaMagBar2SP.graphics.moveTo(0, _limit2);
				_deltaMagBar2SP.graphics.lineTo(_plotWidth, _limit2);
				
				// now draw the checkered pattern masks
				var y1:Number = -_plotHeight;
				var y2:Number = Math.min(_limit1, _limit2);
				var y3:Number = Math.max(_limit1, _limit2);
				var x1:Number = _plotWidth;
				_checkeredPatternMaskSP.graphics.moveTo(0, y1);
				_checkeredPatternMaskSP.graphics.beginFill(0x0000ff, 1);
				_checkeredPatternMaskSP.graphics.lineTo(x1, y1);
				_checkeredPatternMaskSP.graphics.lineTo(x1, y2);
				_checkeredPatternMaskSP.graphics.lineTo(0, y2);
				_checkeredPatternMaskSP.graphics.lineTo(0, y1);
				_checkeredPatternMaskSP.graphics.endFill();
				_checkeredPatternMaskSP.graphics.moveTo(0, y3);
				_checkeredPatternMaskSP.graphics.beginFill(0x00ff00, 1);
				_checkeredPatternMaskSP.graphics.lineTo(x1, y3);
				_checkeredPatternMaskSP.graphics.lineTo(x1, 0);
				_checkeredPatternMaskSP.graphics.lineTo(0, 0);
				_checkeredPatternMaskSP.graphics.lineTo(0, y3);
				_checkeredPatternMaskSP.graphics.endFill();
				
				// update the text display
				var range:Object = _linkedPlot.getYAxisRange();
				var diff:Number = (range.max-range.min)*((y3-y2)/_plotHeight)
				_differenceTextField = new TextField();
				_differenceTextField.autoSize = "left";
				_differenceTextField.defaultTextFormat = textFormat;
				_differenceTextField.embedFonts = true;
				_differenceTextField.text = " " + diff.toFixed(2) + " mag ";
				_differenceTextField.selectable = false;
				_differenceTextField.background = true;
				_differenceTextField.border = true;
				_differenceTextField.borderColor = textBorderColor;
				_differenceTextField.backgroundColor = textBackgroundColor;
				_differenceTextField.x = (_plotWidth/2) - (_differenceTextField.width/2);
				_differenceTextField.y = y2 - 1.3*_differenceTextField.height;
				addChild(_differenceTextField);
			}
		}
		
		private function onMouseDownOverMouseArea(...ignored):void {
			var d1:Number = Math.abs(mouseY-_limit1);
			var d2:Number = Math.abs(mouseY-_limit2);
			if (d1<d2) {
				_limit1 = mouseY;
				_activeBar = _deltaMagBar1SP;
			}
			else {
				_limit2 = mouseY;
				_activeBar = _deltaMagBar2SP;				
			}
			startBarDragging(_activeBar);
		}
		
		private function onRollOverBar(evt:MouseEvent):void {
			if (_barBeingDragged) return;
			_activeBar = (evt.target as Sprite);
			update();
		}
		
		private function onRollOutFromBar(evt:MouseEvent):void {
			if (_barBeingDragged) return;
			_activeBar = null;
			update();
		}
		
		private function onMouseDownOnBar(evt:MouseEvent):void {
			startBarDragging(evt.target as Sprite);
		}
		
		private function startBarDragging(bar:Sprite):void {
			var limit:Number = (_activeBar==_deltaMagBar1SP) ? _limit1 : _limit2;
			_yOffset = mouseY - limit;
			_activeBar = bar;
			_barBeingDragged = true;
			update();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpFromBar);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveWithBar);
		}
		
		private function onMouseMoveWithBar(evt:MouseEvent):void {
			var limit:Number = mouseY - _yOffset;
			if (limit>0) limit = 0;
			else if (limit<-_plotHeight) limit = -_plotHeight;
			if (_activeBar==_deltaMagBar1SP) _limit1 = limit;
			else _limit2 = limit;
			update();
			evt.updateAfterEvent();
		}
		
		private function onMouseUpFromBar(...ignored):void {
			_barBeingDragged = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpFromBar);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveWithBar);
			var stagePt:Point = _activeBar.localToGlobal(new Point(_activeBar.mouseX, _activeBar.mouseY));
			if (!_activeBar.hitTestPoint(stagePt.x, stagePt.y, true)) {
				_activeBar = null;
				update();
			}
		}
		
		private var _barBeingDragged:Boolean = false;
	}
	
}
