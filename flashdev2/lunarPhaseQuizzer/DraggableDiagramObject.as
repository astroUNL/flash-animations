
package {
	
	import flash.display.Sprite;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.events.MouseEvent;	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.ui.Keyboard;
	
	
	public class DraggableDiagramObject extends Sprite {
				
		public var diagram:Diagram;
		public var eventType:String;
		public var propertyName:String;
		
		protected var _initAngle:Number;
		protected var _angleOffset:Number;
		
		protected var _mouseIsOver:Boolean;
		protected var _dragIsInProgress:Boolean;
		
		protected var _incrementStep:Number = 0.01;		
		protected var _snapInterval:Number = (2*Math.PI)/8;
		
		
		public function DraggableDiagramObject() {
			
			focusIndicator.visible = false;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFunc);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFunc);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownFunc);
			
			addEventListener(FocusEvent.FOCUS_IN, onFocusInFunc);
			addEventListener(FocusEvent.FOCUS_OUT, onFocusOutFunc);
			addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChangeFunc);
			addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, onMouseFocusChangeFunc);
			
			tabEnabled = true;
			mouseEnabled = true;
			
			focusRect = false;
			tabChildren = false;
			mouseChildren = false;
		}
		
		protected function onMouseFocusChangeFunc(evt:FocusEvent):void {
			if (stage.focus==this) stage.focus = null;
		}
		
		protected function onKeyFocusChangeFunc(evt:FocusEvent):void {
			if (evt.keyCode==Keyboard.LEFT || evt.keyCode==Keyboard.RIGHT 
					|| evt.keyCode==Keyboard.UP || evt.keyCode==Keyboard.DOWN) evt.preventDefault();
		}
		
		protected function onFocusInFunc(evt:FocusEvent):void {
			focusIndicator.visible = true;
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc, false, 0, true);
		}
		
		protected function onFocusOutFunc(evt:FocusEvent):void {
			focusIndicator.visible = false;
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDownFunc, false);
		}
		
		protected function onKeyDownFunc(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.LEFT || evt.keyCode==Keyboard.DOWN) {
				if (evt.shiftKey) diagram[propertyName] = _snapInterval*(Math.round(diagram[propertyName]/_snapInterval) - 1);
				else diagram[propertyName] -= _incrementStep;
				diagram.dispatchEvent(new Event(eventType));
				diagram.hideFirstRunInstructions();
			}
			else if (evt.keyCode==Keyboard.RIGHT || evt.keyCode==Keyboard.UP) {
				if (evt.shiftKey) diagram[propertyName] = _snapInterval*(Math.round(diagram[propertyName]/_snapInterval) + 1);
				else diagram[propertyName] += _incrementStep;
				diagram.dispatchEvent(new Event(eventType));
				diagram.hideFirstRunInstructions();
			}
		}
		
		protected function onMouseOverFunc(evt:MouseEvent):void {		
			_mouseIsOver = true;
			updateDragIndicators();
		}
		
		protected function onMouseOutFunc(evt:MouseEvent):void {
			_mouseIsOver = false;
			updateDragIndicators();
		}
		
		protected function updateDragIndicators():void {
			if (_dragIsInProgress) Mouse.cursor = MouseCursor.HAND;
			else if (_mouseIsOver) Mouse.cursor = MouseCursor.HAND;
			else Mouse.cursor = MouseCursor.AUTO;
		}
		
		protected function onMouseDownFunc(evt:MouseEvent):void {
			_dragIsInProgress = true;
			updateDragIndicators();
			_angleOffset = diagram[propertyName] - Math.atan2(-diagram.mouseY, diagram.mouseX);	
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc, false, 0, true);
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {
			var angle:Number = Math.atan2(-diagram.mouseY, diagram.mouseX) + _angleOffset;
			if (evt.shiftKey) angle = _snapInterval*Math.round(angle/_snapInterval);
			diagram[propertyName] = angle;
			diagram.dispatchEvent(new Event(eventType));
			diagram.hideFirstRunInstructions();
			evt.updateAfterEvent();
		}
		
		protected function onMouseUpFunc(evt:MouseEvent):void {
			_dragIsInProgress = false;
			updateDragIndicators();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMoveFunc, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpFunc, false);
		}
		
	}
}
