
package {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	
	public class Scene3D extends Sprite {
		
		public const sceneWidth:Number = 600;
		public const sceneHeight:Number = 600;
		
		public var backgroundColor:uint = 0x000000;
		public var backgroundAlpha:Number = 1.0;
		
		public var t0:Number, t1:Number, t2:Number, t3:Number, t4:Number, t5:Number, t6:Number, t7:Number, t8:Number;
		public var it0:Number, it1:Number, it2:Number, it3:Number, it4:Number, it5:Number, it6:Number, it7:Number, it8:Number;
		
		protected var _backgroundSP:Sprite;
		
		protected var _objectsList:Array = [];
		public var _containerSP:Sprite;
		
		protected var _viewerPhi:Number = 0;
		protected var _viewerTheta:Number = 0;
		protected var _initMouseX:Number;
		protected var _initMouseY:Number;
		protected var _initTheta:Number;
		protected var _initPhi:Number;
		
		protected var _scale:Number = 100;
		
		public function Scene3D() {
			_backgroundSP = new Sprite();
			_containerSP = new Sprite();
			
			_containerSP.mouseEnabled = false;
			_containerSP.mouseChildren = false;
			
			addChild(_backgroundSP);
			addChild(_containerSP);
			init();
			_backgroundSP.addEventListener("mouseDown", onMouseDownFunc);
			
			setViewerThetaAndPhi(150, 20);
		}
		
		public function addObject(obj:IScene3DObject):void {
			_objectsList.push(obj);
			_containerSP.addChild(obj.displayObj);
		}
		
		public function init():void {
			_backgroundSP.graphics.moveTo(-sceneWidth/2, -sceneHeight/2);
			_backgroundSP.graphics.beginFill(backgroundColor, backgroundAlpha);
			_backgroundSP.graphics.lineTo(-sceneWidth/2, sceneHeight/2);
			_backgroundSP.graphics.lineTo(sceneWidth/2, sceneHeight/2);
			_backgroundSP.graphics.lineTo(sceneWidth/2, -sceneHeight/2);
			_backgroundSP.graphics.lineTo(-sceneWidth/2, -sceneHeight/2);
			_backgroundSP.graphics.endFill();
		}
		
		public function getScreenPoint(worldPt:Point3D):Point3D {
			return new Point3D(t0*worldPt.x + t1*worldPt.y + t2*worldPt.z,
							   t3*worldPt.x + t4*worldPt.y + t5*worldPt.z,
							   t6*worldPt.x + t7*worldPt.y + t8*worldPt.z);			
		}
		
		public function getWorldPoint(screenPt:Point3D):Point3D {
			return new Point3D(it0*screenPt.x + it1*screenPt.y + it2*screenPt.z,
							   it3*screenPt.x + it4*screenPt.y + it5*screenPt.z,
							   it6*screenPt.x + it7*screenPt.y + it8*screenPt.z);			
		}
		
		public function update():void {
//			var startTimer:Number = getTimer();
			dispatchEvent(new Event("preUpdate"));
			var i:int;
			var obj:IScene3DObject;
			for (i=0; i<_objectsList.length; i++) {
				obj = _objectsList[i];
				obj.screenX = t0*obj.worldX + t1*obj.worldY + t2*obj.worldZ;
				obj.screenY = t3*obj.worldX + t4*obj.worldY + t5*obj.worldZ;
				obj.screenZ = t6*obj.worldX + t7*obj.worldY + t8*obj.worldZ;
				obj.displayObj.x = obj.screenX;
				obj.displayObj.y = obj.screenY;
			}
			_objectsList.sortOn("screenZ", Array.NUMERIC);
			for (i=0; i<_objectsList.length; i++) {
				_containerSP.setChildIndex(_objectsList[i].displayObj, i);
			}
			
			// made this up since the transparency needs to set effects based
			// on position, but before the postUpdate (which causes the globe to be rendered)
			dispatchEvent(new Event("prePostUpdate"));

			dispatchEvent(new Event("postUpdate"));
//			trace("scene update: "+(getTimer()-startTimer));
		}
		
		public function get viewerTheta():Number {
			return _viewerTheta*180/Math.PI - 180;
		}
		
		public function get viewerPhi():Number {
			return _viewerPhi*180/Math.PI;
		}
			
		protected function onMouseDownFunc(...ignored):void {
			_initMouseX = mouseX;
			_initMouseY = mouseY;
			_initTheta = _viewerTheta;
			_initPhi = _viewerPhi;
			stage.addEventListener("mouseUp", onMouseUpFunc);
			stage.addEventListener("mouseMove", onMouseMoveFunc);
		}
		
		protected function onMouseUpFunc(...ignored):void {
			stage.removeEventListener("mouseUp", onMouseUpFunc);
			stage.removeEventListener("mouseMove", onMouseMoveFunc);
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {
			var theta:Number = (180/Math.PI)*(_initTheta - (mouseX - _initMouseX)/_scale) - 180;
			var phi:Number = (180/Math.PI)*(_initPhi + (mouseY - _initMouseY)/_scale);
			setViewerThetaAndPhi(theta, phi);
			
			dispatchEvent(new Event("mouseDrag"));
			
			evt.updateAfterEvent();
		}
				
		public function setViewerThetaAndPhi(theta:Number, phi:Number):void {
			
			_viewerTheta = (theta + 180)*Math.PI/180;
			_viewerPhi = phi*Math.PI/180;
			
			if (_viewerPhi>(Math.PI/2)) _viewerPhi = Math.PI/2;
			else if (_viewerPhi<(-Math.PI/2)) _viewerPhi = -Math.PI/2;
			
			calculateConstants();
			update();
		}
		
		public function calculateConstants():void {
			var ct:Number = Math.cos(_viewerTheta);
			var st:Number = Math.sin(_viewerTheta);
			var cp:Number = Math.cos(_viewerPhi);
			var sp:Number = Math.sin(_viewerPhi);
			t0 = _scale*st;
			t1 = -_scale*ct;
			t2 = 0;
			t3 = -_scale*ct*sp;
			t4 = -_scale*st*sp;
			t5 = -_scale*cp;
			t6 = -_scale*ct*cp;
			t7 = -_scale*st*cp;
			t8 = _scale*sp;
			
			it0 = t0/(_scale*_scale);
			it1 = t3/(_scale*_scale);
			it2 = t6/(_scale*_scale);
			it3 = t1/(_scale*_scale);
			it4 = t4/(_scale*_scale);
			it5 = t7/(_scale*_scale);
			it6 = t2/(_scale*_scale);
			it7 = t5/(_scale*_scale);
			it8 = t8/(_scale*_scale);
		}
		
				
		public function get scale():Number{
			return _scale;
		}
		
		public function set scale(arg:Number):void {
			_scale = arg;
			calculateConstants();
			update();
		}

			
		
		
	}
	
}