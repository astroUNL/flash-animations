
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	public class StarField3D extends Sprite {
		
		
		protected var _mouseArea:Sprite;
		
		
		protected var _starsList:Array;
		protected var _numStars:int = 20000;
		
		protected var _starsBM:Bitmap;
		protected var _starsBMD:BitmapData;
		
		public function StarField3D() {
			
			
			_stars = new Sprite();
			addChild(_stars);
			
			_starsBMD = new BitmapData(_sceneWidth, _sceneHeight, true, 0x0);
			_starsBM = new Bitmap(_starsBMD);
			_starsBM.x = -_sceneWidth/2;
			_starsBM.y = -_sceneHeight/2;
			_stars.addChild(_starsBM);
			
			_mouseArea = new Sprite();
			addChild(_mouseArea);
			
			
			var sx:Number, sy:Number, sz:Number, sn2:Number;
			
//			_starsList = [];
//			for (var i:int = 0; i<_numStars; i++) {
//				do {
//					sx = 0.5-Math.random();
//					sy = 0.5-Math.random();
//					sz = 0.5-Math.random();
//					sn2 = sx*sx + sy*sy + sz*sz;
//				} while (sn2>0.25);
//				_starsList[i] = new Star(sx, sy, sz, 6*Math.random());
//			}
			
			_starsList = [];
			var realData:Array = [[1, 1],[0, 0],[1, 1],[0, 0],[2, 2],[3, 3],[2, 3],[2, 1],[4, 4],[5, 4],[3, 4],[9, 8],[17, 19],
				[23, 22],[24, 21],[28, 31],[57, 50],[48, 50],[65, 63],[92, 97],[147, 134],[154, 150],[241, 236],
				[291, 290],[438, 436],[562, 565],[674, 692],[955, 965],[1181, 1228],[1494, 1585],[1728, 1739]];
			var i:int, j:int;
			var m:Number = -1;
			for (i=0; i<realData.length; i++) {
				for (j=0; j<realData[i][1]; j++) {
					do {
						sx = 0.5-Math.random();
						sy = 0.5-Math.random();
						sz = 0.5-Math.random();
						sn2 = sx*sx + sy*sy + sz*sz;
					} while (sn2>0.25);
					
					_starsList.push(new Star(sx, sy, sz, m));
				}
				m += 0.25;
			}
			_numStars = _starsList.length;
						
						
			_mouseArea.addEventListener("mouseDown", onMouseDownFunc);
			
			init();
			
		}
		
		protected var _stars:Sprite;
		
		
		protected const _sceneWidth:Number = 760;
		protected const _sceneHeight:Number = 760;
		
		protected var _scale:Number = 760;
		
		protected var _viewerTheta:Number = 0;
		protected var _viewerPhi:Number = 0;
		
		protected var _dragMouseX:Number;
		protected var _dragMouseY:Number;
		protected var _dragTheta:Number;
		protected var _dragPhi:Number;
		
		
		public function init():void {
			_mouseArea.graphics.moveTo(-_sceneWidth/2, -_sceneHeight/2);
			_mouseArea.graphics.beginFill(0xffffff, 0);
			_mouseArea.graphics.lineTo(-_sceneWidth/2, _sceneHeight/2);
			_mouseArea.graphics.lineTo(_sceneWidth/2, _sceneHeight/2);
			_mouseArea.graphics.lineTo(_sceneWidth/2, -_sceneHeight/2);
			_mouseArea.graphics.lineTo(-_sceneWidth/2, -_sceneHeight/2);
			_mouseArea.graphics.endFill();
		}
		
		protected function onMouseDownFunc(...ignored):void {
			_dragMouseX = mouseX;
			_dragMouseY = mouseY;
			_dragTheta = _viewerTheta;
			_dragPhi = _viewerPhi;
			stage.addEventListener("mouseUp", onMouseUpFunc);
			stage.addEventListener("mouseMove", onMouseMoveFunc);			
		}
		
		protected function onMouseMoveFunc(evt:MouseEvent):void {
			
			var theta:Number = (180/Math.PI)*(_dragTheta - (mouseX - _dragMouseX)/_scale) - 180;
			var phi:Number = (180/Math.PI)*(_dragPhi + (mouseY - _dragMouseY)/_scale);
			setViewerThetaAndPhi(theta, phi);
			
			//dispatchEvent(new Event("mouseDrag"));
			
			evt.updateAfterEvent();
		}
		
		
		protected function onMouseUpFunc(...ignored):void {
			stage.removeEventListener("mouseUp", onMouseUpFunc);
			stage.removeEventListener("mouseMove", onMouseMoveFunc);			
		}
		
		
		public function update(...ignored):void {
			
			var star:Star;
			
			_stars.graphics.clear();
			
			_starsBMD.fillRect(_starsBMD.rect, 0x0);
			
			var i:int;
			for (i=0; i<_numStars; i++) {
				star = _starsList[i];
				
//				_starsBMD.setPixel32(t0*star.x + t1*star.y + t2*star.z + _sceneWidth/2, t3*star.x + t4*star.y + t5*star.z + _sceneHeight/2, 0x50ffffff);
				
				
				
				
				_stars.graphics.beginFill(0xffffff);
				_stars.graphics.drawCircle(t0*star.x + t1*star.y + t2*star.z, t3*star.x + t4*star.y + t5*star.z, 0.2*(7.5-star.m));
				_stars.graphics.endFill();
				
				
			}
			
			
//			_stars.graphics.moveTo(0, 0);
//			_stars.graphics.lineStyle(1, 0xff0000);
//			_stars.graphics.lineTo(0.5*t0, 0.5*t3);
//			
//			_stars.graphics.moveTo(0, 0);
//			_stars.graphics.lineStyle(1, 0x00ff00);
//			_stars.graphics.lineTo(0.5*t1, 0.5*t4);
//						
//			_stars.graphics.moveTo(0, 0);
//			_stars.graphics.lineStyle(1, 0x0000ff);
//			_stars.graphics.lineTo(0.5*t2, 0.5*t5);

			
//			obj.screenX = t0ldZ;
//			obj.screenY = t3*obj.worldX + t4*obj.worldY + t5*obj.worldZ;
//			obj.screenZ = t6*obj.worldX + t7*obj.worldY + t8*obj.worldZ;
//			
//			obj.screenX = t0*obj.worldX + t1*obj.worldY + t2*obj.worldZ;
//			obj.screenY = t3*obj.worldX + t4*obj.worldY + t5*obj.worldZ;
//			obj.screenZ = t6*obj.worldX + t7*obj.worldY + t8*obj.worldZ;
//			
//			obj.screenX = t0*obj.worldX + t1*obj.worldY + t2*obj.worldZ;
//			obj.screenY = t3*obj.worldX + t4*obj.worldY + t5*obj.worldZ;
//			obj.screenZ = t6*obj.worldX + t7*obj.worldY + t8*obj.worldZ;
//			
//			obj.screenX = t0*obj.worldX + t1*obj.worldY + t2*obj.worldZ;
//			obj.screenY = t3*obj.worldX + t4*obj.worldY + t5*obj.worldZ;
//			obj.screenZ = t6*obj.worldX + t7*obj.worldY + t8*obj.worldZ;
			
//			obj.screenX = t0*obj.worldX + t1*obj.worldY + t2*obj.worldZ;
//			obj.screenY = t3*obj.worldX + t4*obj.worldY + t5*obj.worldZ;
//			obj.screenZ = t6*obj.worldX + t7*obj.worldY + t8*obj.worldZ;
			
			
			
		}
		
		
		public function setViewerThetaAndPhi(theta:Number, phi:Number):void {
			
			_viewerTheta = (theta + 180)*Math.PI/180;
			_viewerPhi = phi*Math.PI/180;
			
			if (_viewerPhi>(Math.PI/2)) _viewerPhi = Math.PI/2;
			else if (_viewerPhi<(-Math.PI/2)) _viewerPhi = -Math.PI/2;
			
			calculateConstants();
			update();
		}
		
		public var t0:Number, t1:Number, t2:Number, t3:Number, t4:Number, t5:Number, t6:Number, t7:Number, t8:Number;
		
		
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
		}
		
		
	}
}
