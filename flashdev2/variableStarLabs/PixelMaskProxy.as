
package {

	import edu.unl.astro.starField.PixelMask;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class PixelMaskProxy extends Sprite {
		
		// the bounds rectangle limits the range of the proxy; if null, no limits are enforced
		private var _boundsRect:Rectangle;
		
		// the color of the outline
		private var _outlineColor:uint = 0xffcc00;
		
		// pixelMask specifies the pixel mask that this component is acting
		// as the draggable proxy for; it is that data array of the pixel mask
		// that determines the outline
		private var _pixelMask:PixelMask;
		
		// the x and y offsets are used when dragging
		private var _xOffset:Number;
		private var _yOffset:Number;
		private var _mouseDown:Boolean = false;
		
		public var outlinePointsList:Array;
				
		public var focusRectMargin:Number = 3;
		public var focusRectLineThickness:Number = 3;
		public var focusRectLineColor:uint = 0x9090ff;
		
		private var _discSP:Sprite;
		private var _focusRectSP:Sprite;
		private var _labelTextField:TextField;
		
		public var label:String = "";
		public var labelTextFormat:TextFormat;
		
		public function PixelMaskProxy(...argsList):void {
			
			labelTextFormat = new TextFormat("Verdana", 16, null, true);
			
			_labelTextField = new TextField();
			addChild(_labelTextField);
			
			_discSP = new Sprite();
			addChild(_discSP);
			
			_focusRectSP = new Sprite();
			addChild(_focusRectSP);
			
			_labelTextField.visible = false;
			
			loadSettingsFromObjectsList(argsList);
				
			tabEnabled = false;
			tabChildren = false;
		
			// the reason we don't do mouseChildren=false is that we need the disc to
			// take mouse presses so we know when to set focus without doing the focus
			// rect box (which is also why the disc sprite exists separately from its parent)
			_focusRectSP.mouseEnabled = false;
			
			focusRect = {};
			_focusRectSP.visible = false;
		}
		
		public function loadSettings(...argsList):void {
			if (argsList.length>0) loadSettingsFromObjectsList(argsList);
		}
		
		private function loadSettingsFromObjectsList(objectsList):void {
			var propName:String;
			for each (var item in objectsList) {
				if (item is Object) {
					for (propName in item) this[propName] = item[propName];					
				}
			}
			redrawOutline();
		}
		
		// focus is acheived in two ways:
		// - keyboard navigation
		// - clicking on the object
		
		// focus is lost through
		// - keyboard navigation
		// - releasing outside of the disc area
		
		// note that the focus rectange is shown only if focus came via keyboard navigation		
		
		public function get enabled():Boolean {
			return tabEnabled;
		}
		
		public function set enabled(arg:Boolean):void {
			if (!tabEnabled && arg) {
				addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChanged);
				_discSP.addEventListener(MouseEvent.MOUSE_DOWN, onDiscMouseDownFunc);
			}
			else if (tabEnabled && !arg) {
				removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChanged);
				_discSP.removeEventListener(MouseEvent.MOUSE_DOWN, onDiscMouseDownFunc);
			}		
			tabEnabled = arg;
		}
		
		private function onFocusIn(evt:FocusEvent):void {
			_focusRectSP.visible = !_mouseDown;
			stage.addEventListener("keyDown", onKeyDownFunc);
		}
		
		private function onFocusOut(...ignored):void {
			_focusRectSP.visible = false;
			stage.removeEventListener("keyDown", onKeyDownFunc);
		}
		
		private function onKeyFocusChanged(evt:FocusEvent):void {
			// don't allow the focus to be changed by the arrow keys
			if (evt.keyCode>=37 && evt.keyCode<=40) evt.preventDefault();
		}
				
		private function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==37) {
				// left arrow
				moveTo(new Point(x-1, y));
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==38) {
				// up arrow
				moveTo(new Point(x, y-1));
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==39) {
				// right arrow
				moveTo(new Point(x+1, y));
				evt.updateAfterEvent();
			}
			else if (evt.keyCode==40) {
				// bottom arrow
				moveTo(new Point(x, y+1));
				evt.updateAfterEvent();
			}
		}
				
		private function onDiscMouseDownFunc(...ignored):void {
			// this function is called when the mouse is pressed on the disc,
			
			_mouseDown = true;
			
			_focusRectSP.visible = false;
			
			stage.focus = this;
			
			_xOffset = x - parent.mouseX;
			_yOffset = y - parent.mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFunc);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFunc);
			
			parent.setChildIndex(this, parent.numChildren-1);
		}
		
		private function onStageMouseUpFunc(...ignored):void {
			_mouseDown = false;
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFunc);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFunc);		
			
			if (stage.focus==this && !hitTestPoint(stage.mouseX, stage.mouseY, true)) {
				// if the object is released with the mouse outside the disc area then 
				// lose the focus (assuming it hasn't already been transferred elsewhere)
				stage.focus = null;
			}
		}
		
		private function onStageMouseMoveFunc(evt:MouseEvent):void {
			moveTo(new Point(_xOffset+parent.mouseX, _yOffset+parent.mouseY));
			evt.updateAfterEvent();
		}
		
		public function moveTo(pt:Point):void {
			var nx:Number = pt.x;
			var ny:Number = pt.y;
			
			if (_boundsRect!=null) {
				if (nx<_boundsRect.left) nx = _boundsRect.left;
				else if (nx>_boundsRect.right) nx = _boundsRect.right;
				if (ny<_boundsRect.top) ny = _boundsRect.top;
				else if (ny>_boundsRect.bottom) ny = _boundsRect.bottom;
			}
			
			nx = Math.round(nx);
			ny = Math.round(ny);
			
			if (nx!=x || ny!=y) {
				x = nx;
				y = ny;
				dispatchEvent(new Event("pixelMaskProxyMoved"));
			}
		}
				
		public function get bounds():Rectangle {
			return _boundsRect.clone();			
		}
	
		public function set bounds(arg:Rectangle):void {
			_boundsRect = arg.clone();
			moveTo(new Point(x, y));
		}
			
		public function get outlineColor():uint {
			return _outlineColor;			
		}
		
		public function set outlineColor(arg:uint):void {
			_outlineColor = arg;
			redrawOutline();
		}		
		
		public function get pixelMask():PixelMask {
			return _pixelMask;
		}
		
		public function set pixelMask(arg:PixelMask) {
			_pixelMask = arg;
			redrawOutline();
		}
				
		private function redrawOutline():void {
			// this function draws the outline of the box as well as the 
			// fill that lets the user drag the box around; it also generates
			// the outline points list and draws the focus box
			
			_discSP.graphics.clear();
			_focusRectSP.graphics.clear();
			
			outlinePointsList = [];
			
			if (_pixelMask==null) return;
			
			var i:int;
			var j:int;
			var n:int = _pixelMask.width;
			var m:int = _pixelMask.height;
			
			// starting from the top left corner look for a point that is in the mask,
			// this will be the starting point for the outline
			searchLoop: for (i=0; i<n; i++) {
				for (j=0; j<m; j++) {
					if (_pixelMask.data[i][j]) break searchLoop;
				}
			}
			
			var si:int = i;
			var sj:int = j;
			
			var counter:int;
			var lineNum:int = 0;
			var k:int;
			
			var ai:int;
			var aj:int;
			var bi:int;
			var bj:int;
			var aInBounds:Boolean;
			var bInBounds:Boolean;
			
			_discSP.graphics.lineStyle(0, _outlineColor, 1);
			_discSP.graphics.moveTo(i-_pixelMask.radius, j-_pixelMask.radius);
			_discSP.graphics.beginFill(0xffffff, 0);
			
			outlinePointsList.push({x: i, y: j});
			
			// draw the outline (an arbitrary limit is imposed to prevent possible infinite loops)
			for (counter=0; counter<1000; counter++) {
				
				// adding 2 to the line number now, along with adding 1 when we start the search
				// loop, means that the line segment that was just drawn (that is, after the first iteration)
				// will be the last to be checked (we don't want to retrace the path)
				lineNum = (lineNum+2)%4;
				
				// from any given point there are four directions that the next
				// line segment can go to, so check each of these directions to
				// see if it defines the boundary between points that are part of the
				// mask and points that are not
				for (k=0; k<4; k++) {
					
					// we need to add one to lineNum at the start of the loop
					// (see comment above where two is added to lineNum)
					lineNum = (lineNum+1)%4;
					
					// for any potential line segment there's a point to the left (a) and
					// a point to the right (b)
					switch (lineNum) {
						case 0:
							ai = i-1;
							aj = j-1;
							bi = i;
							bj = j-1;
							break;
						case 1:
							ai = i;
							aj = j-1;
							bi = i;
							bj = j;
							break;
						case 2:
							ai = i;
							aj = j;
							bi = i-1;
							bj = j;
							break;
						case 3:
							ai = i-1;
							aj = j;
							bi = i-1;
							bj = j-1;
							break;
					}
					
					aInBounds = !(ai<0 || ai>=n || aj<0 || aj>=m);
					bInBounds = !(bi<0 || bi>=n || bj<0 || bj>=m);
					
					// break if the potential line segment separates a point that is part
					// of the mask and a point that is not part of the mask					
					if (aInBounds && bInBounds && (_pixelMask.data[ai][aj] ^ _pixelMask.data[bi][bj])) break;
					else if (aInBounds && !bInBounds && _pixelMask.data[ai][aj]) break;
					else if (!aInBounds && bInBounds && _pixelMask.data[bi][bj]) break;		
				}
				
				// move to the new point
				if (lineNum==0) j--;
				else if (lineNum==1) i++;
				else if (lineNum==2) j++;
				else i--;
				
				// draw the line
				_discSP.graphics.lineTo(i-_pixelMask.radius, j-_pixelMask.radius);
				
				outlinePointsList.push({x: i, y: j});
				
				// stop if we've come back to the beginning
				if (i==si && j==sj) break;
			}
			
			_discSP.graphics.endFill();
			
			// you could the commented out lines below to draw a regular circle instead of the jagged
			// one as above; when zoomed at %100 you can't tell that the circle cuts through pixels
			// instead of between them; you would still need to calculate the outlinePointsList for the
			// benefit of the custom markings of the zoom window pixel displays
			//graphics.lineStyle(0, 0xff0000, 1);
			//graphics.drawCircle(0.5, 0.5, _pixelMask.radius);
			
			// now draw the focus rectangle
			var margin:Number = focusRectMargin;
			_focusRectSP.graphics.lineStyle(focusRectLineThickness, focusRectLineColor);
			_focusRectSP.graphics.drawRect(-(_pixelMask.width/2)-margin, -(_pixelMask.height/2)-margin,
											_pixelMask.width+2*margin, _pixelMask.height+2*margin);
			
			// update the label
			labelTextFormat.color = _outlineColor;
			_labelTextField.embedFonts = true;
			_labelTextField.defaultTextFormat = labelTextFormat;
			_labelTextField.autoSize = "left";
			_labelTextField.text = label;
			_labelTextField.x = -(_labelTextField.width/2) + (_labelTextField.width-_labelTextField.textWidth)/4;
			_labelTextField.y = -(_pixelMask.width/2) - margin - _labelTextField.textHeight - 2;
			_labelTextField.selectable = false;
			_labelTextField.tabEnabled = false;
			_labelTextField.mouseEnabled = false;
		}
				
		public function get showLabel():Boolean {
			return _labelTextField.visible;
		}
		
		public function set showLabel(arg:Boolean):void {
			_labelTextField.visible = arg;
		}
		
	}
	
}
	