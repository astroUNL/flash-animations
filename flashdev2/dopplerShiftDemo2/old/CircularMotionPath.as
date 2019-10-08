
package {

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.FocusEvent;
	
	public class CircularMotionPath extends Sprite {
				
				
		protected var _centerX:Number;
		protected var _centerY:Number;
		
		protected var _radius:Number;
		
		protected var _minRadius:Number = 20;
		protected var _maxRadius:Number = 300;
		
		protected var _state:int;
		
		protected var _direction:int;
		
		protected const _CCW:int = 0;
		protected const _CW:int = 1;
		
		protected const _Inactive:int = 0;
		protected const _RadiusDrag:int = 1;
		
		
		protected var _circleSP:Sprite;
		
		
		public function CircularMotionPath(cx:Number, cy:Number) {
			
			_circleSP = new Sprite();
			addChild(_circleSP);
			
			tabEnabled = true;
			
			_centerX = cx;
			_centerY = cy;
			_radius = _minRadius;
			_state = _RadiusDrag;
			_direction = _CCW;
			update();
			addEventListener("addedToStage", onAddedToStage);
			addEventListener("removedFromStage", onRemovedFromStage);
			
			
			
			addEventListener("focusIn", onFocusIn);
			addEventListener("focusOut", onFocusOut);
			
		}
		
		protected function onFocusIn(...ignored):void {
			trace("onFocusIn, "+this);
			stage.addEventListener("keyDown", onKeyDown);
			stage.addEventListener("keyUp", onKeyUp);
			addEventListener("keyFocusChange", onKeyFocusChange);
			
			
			update();
		}
		
		protected function onKeyFocusChange(evt:FocusEvent):void {
			
			if (evt.keyCode==Keyboard.UP || evt.keyCode==Keyboard.DOWN ||
				evt.keyCode==Keyboard.LEFT || evt.keyCode==Keyboard.RIGHT) evt.preventDefault();
			trace("onKeyFocusChange: "+evt.keyCode);
		}
		
		protected function onKeyDown(evt:KeyboardEvent):void {
			if (evt.keyCode==Keyboard.UP) {
				y -= 1;
			}
			else if (evt.keyCode==Keyboard.DOWN) {
				y += 1;
			}
			else if (evt.keyCode==Keyboard.LEFT) {
				x -= 1;				
			}
			else if (evt.keyCode==Keyboard.RIGHT) {
				x += 1;				
			}			
			
			trace(evt.keyCode);
		}
		
		protected function onKeyUp(evt:KeyboardEvent):void {
			//
		}
		
		protected function onFocusOut(...ignored):void {
			trace("onFocusOut, "+this);
			stage.removeEventListener("keyDown", onKeyDown);
			stage.removeEventListener("keyUp", onKeyUp);		
			removeEventListener("keyFocusChange", onKeyFocusChange);
			update();
			
		}
				
		protected function onAddedToStage(...ignored):void {
			stage.addEventListener("mouseUp", onMouseUp);
			stage.addEventListener("mouseMove", onMouseMove);
			_circleSP.addEventListener("mouseDown", onMouseDown);
			_circleSP.addEventListener("click", onClick);
			update();
		}
		
		protected function onRemovedFromStage(...ignored):void {
			stage.removeEventListener("mouseUp", onMouseUp);
			stage.removeEventListener("mouseMove", onMouseMove);
			_circleSP.removeEventListener("mouseDown", onMouseDown);
			trace("removed");
		}
		
		protected function onClick(...ignored):void {
			
			trace("onClick");
			
			stage.focus = this;			
			
		}
		
		
		
		
		
		
		protected function onMouseDown(...ignored):void {
			_state = _RadiusDrag;
			trace("onMouseDown called");
		}
		
		protected function onMouseUp(...ignored):void {
			_state = _Inactive;			
			trace("onMouseUp called");
		}
		
		protected function onMouseMove(evt:MouseEvent):void {
			if (_state==_RadiusDrag) {
				var dx:Number = mouseX - _centerX;
				var dy:Number = mouseY - _centerY;
				_radius = Math.sqrt(dx*dx + dy*dy);
				if (_radius<_minRadius) _radius = _minRadius;
				else if (_radius>_maxRadius) _radius = _maxRadius;
				update();
				evt.updateAfterEvent();
				trace("onMouseMove, state = radius drag");
			}
		}
		
		public function update():void {
			if (stage==null) return;
			
			graphics.clear();
			if (stage.focus==this) graphics.lineStyle(2, 0xff8080);
			else graphics.lineStyle(1, 0x8080ff);
			graphics.drawCircle(_centerX, _centerY, _radius);
		}
		
	}
	
}
