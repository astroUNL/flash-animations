
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	public class OrbitView extends Sprite {
		
		public function OrbitView() {
			_orbitRadius = orbit.width/2;			
			
			globeAndFigure.buttonMode = true;
			globeAndFigure.tabEnabled = false;
			globeAndFigure.useHandCursor = true;
			
			globeAndFigure.globe.addEventListener(MouseEvent.MOUSE_OVER, onGlobeMouseOver);
			globeAndFigure.globe.addEventListener(MouseEvent.MOUSE_UP, onGlobeMouseUp);
			globeAndFigure.globe.addEventListener(MouseEvent.MOUSE_OUT, onGlobeMouseOut);
			globeAndFigure.globe.addEventListener(MouseEvent.MOUSE_DOWN, onGlobeMouseDown);
			
			globeAndFigure.figure.addEventListener(MouseEvent.MOUSE_OVER, onFigureMouseOver);
			globeAndFigure.figure.addEventListener(MouseEvent.MOUSE_UP, onFigureMouseUp);
			globeAndFigure.figure.addEventListener(MouseEvent.MOUSE_OUT, onFigureMouseOut);
			globeAndFigure.figure.addEventListener(MouseEvent.MOUSE_DOWN, onFigureMouseDown);
			
			setGlobeActive(false);
			setFigureActive(false);
		}
		
		public var onDragged:Function;
		
		public var tropicalYear:Number;
		public var siderealPerSolar:Number;
		
		protected var _orbitRadius:Number;
		
		protected const _angleOfEarthAtEquinox:Number = -Math.PI/2;
		protected const _globeRotationOffset:Number = 180;
		
		public function setTime(solarTime:Number, solarDaysSinceLastVernalEquinox:Number):void {
			//var angle:Number = (arg/Main.YEAR_IN_SOLAR_DAYS)*(2*Math.PI);
			var angle:Number = (solarDaysSinceLastVernalEquinox/tropicalYear)*(2*Math.PI);
			var globeAngle:Number = angle + _angleOfEarthAtEquinox;
			globeAndFigure.x = _orbitRadius*Math.cos(globeAngle);
			globeAndFigure.y = -_orbitRadius*Math.sin(globeAngle);
			globeAndFigure.rotation = _globeRotationOffset - (solarTime%1)*360 - angle*(180/Math.PI);
		}
		
		protected function setGlobeActive(arg:Boolean):void {
			globeAndFigure.globe.gotoAndStop((arg) ? "mouseOver" : "mouseOut");
			globeDragInstructions.visible = arg;
		}
		
		protected function setFigureActive(arg:Boolean):void {
			globeAndFigure.figure.gotoAndStop((arg) ? "mouseOver" : "mouseOut");
			figureDragInstructions.visible = arg;
		}
		
		protected var _globeMouseOffset:Number;
		protected var _figureMouseOffset:Number;
		
		
		protected var _mouseIsOverGlobe:Boolean = false;
		protected var _mouseIsOverFigure:Boolean = false;
		
		protected function onGlobeMouseOver(evt:MouseEvent):void {
			_mouseIsOverGlobe = true;
			if (!evt.buttonDown) setGlobeActive(true);			
		}
		
		protected function onGlobeMouseUp(evt:MouseEvent):void {
			if (_mouseIsOverGlobe) setGlobeActive(true);
		}
		
		protected function onGlobeMouseOut(evt:MouseEvent):void {
			_mouseIsOverGlobe = false;
			if (!evt.buttonDown) setGlobeActive(false);			
		}
		
		protected function onGlobeMouseDown(evt:MouseEvent):void {
			if (onDragged!=null) onDragged(0); // this stops any animation
			_globeMouseOffset = Math.atan2(mouseY, mouseX) - Math.atan2(globeAndFigure.y, globeAndFigure.x);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFuncForGlobe);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFuncForGlobe);
		}
		
		protected function onStageMouseMoveFuncForGlobe(evt:MouseEvent):void {
			var angleDelta:Number = -(Math.atan2(mouseY, mouseX) - Math.atan2(globeAndFigure.y, globeAndFigure.x) - _globeMouseOffset);
			angleDelta = (angleDelta%(2*Math.PI) + (2*Math.PI))%(2*Math.PI);
			if (angleDelta>Math.PI) angleDelta -= 2*Math.PI;
			
			var timeDelta:Number = angleDelta*tropicalYear/(2*Math.PI);
			
			if (evt.shiftKey) {
				timeDelta = timeDelta*siderealPerSolar;
				timeDelta = Math.round(timeDelta);
				timeDelta = timeDelta/siderealPerSolar;
			}
			else {
				timeDelta = Math.round(timeDelta);
			}
			
			
			if (onDragged!=null) onDragged(timeDelta);
			evt.updateAfterEvent();
		}
		
		protected function onStageMouseUpFuncForGlobe(evt:MouseEvent):void {
			if (!_mouseIsOverGlobe) setGlobeActive(false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFuncForGlobe);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFuncForGlobe);
		}
		
		protected function onFigureMouseOver(evt:MouseEvent):void {
			_mouseIsOverFigure = true;
			if (!evt.buttonDown) setFigureActive(true);			
		}
		
		protected function onFigureMouseUp(evt:MouseEvent):void {
			if (_mouseIsOverFigure) setFigureActive(true);
		}
		
		protected function onFigureMouseOut(evt:MouseEvent):void {
			_mouseIsOverFigure = false;
			if (!evt.buttonDown) setFigureActive(false);			
		}
		
		
		protected function onFigureMouseDown(evt:MouseEvent):void {
			if (onDragged!=null) onDragged(0); // this stops any animation
			_figureMouseOffset = Math.atan2(mouseY-globeAndFigure.y, mouseX-globeAndFigure.x)*(180/Math.PI) - globeAndFigure.rotation;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFuncForFigure);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFuncForFigure);
		}
		
		protected function onStageMouseMoveFuncForFigure(evt:MouseEvent):void {
			var rotationDelta:Number = -(Math.atan2(mouseY-globeAndFigure.y, mouseX-globeAndFigure.x)*(180/Math.PI) - globeAndFigure.rotation - _figureMouseOffset);
			rotationDelta = (rotationDelta%360 + 360)%360;
			if (rotationDelta>180) rotationDelta -= 360;
			
			var timeDelta:Number = rotationDelta/360;		
			if (onDragged!=null) onDragged(timeDelta);
			evt.updateAfterEvent();
		}
		
		protected function onStageMouseUpFuncForFigure(evt:MouseEvent):void {
			if (!_mouseIsOverFigure) setFigureActive(false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMoveFuncForFigure);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUpFuncForFigure);
		}
		
	}
}

