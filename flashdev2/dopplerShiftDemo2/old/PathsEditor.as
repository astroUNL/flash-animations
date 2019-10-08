
package {
	
	import flash.display.Sprite;
	
	import flash.ui.Keyboard;
	
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	
	public class PathsEditor extends Sprite {
		
		protected var _backgroundSP:Sprite;
		
		protected var _shiftIsDown:Boolean = false;
		protected var _deleteIsDown:Boolean = false;
		
		protected var _pathsList:Array = [];
		
		
		
		
		
		
		public function PathsEditor(w:Number, h:Number) {
			
			addEventListener("addedToStage", onAddedToStage);
			
			_backgroundSP = new Sprite();
			addChild(_backgroundSP);
			
			_backgroundSP.addEventListener("mouseDown", onMouseDown);
			
			setDimensions(w, h);
		}
		
		protected function update():void {
			var i:int;
			for (i=0; i<_pathsList.length; i++) {
				
				_pathsList[i].update();
				
				
			}			
		}
		
		protected function onAddedToStage(...ignored):void {
			
			stage.addEventListener("mouseUp", onMouseUp);
			stage.addEventListener("mouseMove", onMouseMove);
			stage.addEventListener("keyDown", onKeyDown);
			stage.addEventListener("keyUp", onKeyUp);
		}
		
		
		protected function onMouseDown(...ignored):void {
			if (_shiftIsDown) {
				var p:CircularMotionPath = new CircularMotionPath(mouseX, mouseY);
				addChild(p);				
				trace("here");
			}			
		}
		
		protected function onMouseUp(...ignored):void {
			
			
		}
		
		protected function onMouseMove(evt:MouseEvent):void {
			
			
			
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode == Keyboard.SHIFT) {
				//if (!_shiftIsDown)
				_shiftIsDown = true;				
			}
			if (evt.keyCode == Keyboard.DELETE) {
				_deleteIsDown = true;
			}
		}
		
		protected function onKeyUp(evt:KeyboardEvent):void {			
			if (evt.keyCode == Keyboard.SHIFT) {
				_shiftIsDown = false;				
			}
			if (evt.keyCode == Keyboard.DELETE) {
				_deleteIsDown = false;
			}
		}
		
		
		
		public function setDimensions(w:Number, h:Number):void {
			_backgroundSP.graphics.clear();
			_backgroundSP.graphics.lineStyle(0, 0xd0d0d0);
			_backgroundSP.graphics.moveTo(0, 0);
			_backgroundSP.graphics.beginFill(0xe0e0ff);
			_backgroundSP.graphics.lineTo(w, 0);
			_backgroundSP.graphics.lineTo(w, h);
			_backgroundSP.graphics.lineTo(0, h);
			_backgroundSP.graphics.lineTo(0, 0);
			
		}
		
		
		
	}
	
}
