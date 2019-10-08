
package {
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	public class simple extends Sprite {
		
		protected var _obsIcon:ObserverIcon;
		protected var _srcIcon:SourceIcon;
		
		protected var _obsTrack:Sprite;
		protected var _srcTrack:Sprite;
		
		
		protected var _obsCount:int;
		
		public function simple() {
			
			_obsTrack = new Sprite();
			_srcTrack = new Sprite();
			
			addChild(_obsTrack);
			addChild(_srcTrack);			
			
			_obsIcon = new ObserverIcon();
			_srcIcon = new SourceIcon();
			
			_obsIcon.setPosition(50, 50);
			_srcIcon.setPosition(100, 100);
			
			addChild(_obsIcon);
			addChild(_srcIcon);
			
			_obsTrack.graphics.lineStyle(1, 0xff6060);
			_srcTrack.graphics.lineStyle(1, 0x6060ff);
			
			_obsTrack.graphics.moveTo(_obsIcon.x, _obsIcon.y);
			_srcTrack.graphics.moveTo(_srcIcon.x, _srcIcon.y);
			
			_obsIcon.addEventListener("iconDragged", onObsDragged);
			_srcIcon.addEventListener("iconDragged", onSrcDragged);
			
			_obsCount = 0;
			
			
			addEventListener("enterFrame", onEnterFrameFunc);
		}
		
		protected var _timeLast:Number = 0;
		
		protected function onEnterFrameFunc(...ignored):void {
			
			var startTimer:Number = getTimer();
			
			var i:int;
			var hL:Array;
			var hI:int;
			var hLen:int;
			var hP:HistoryPoint;
			
			var T:Number = getTimer();
			//var pastLimit:Number = T - 27000;
			
			var v:Number = 32/1000;
			
			var pastLimit:Number = T - Math.sqrt(stage.stageWidth*stage.stageWidth + stage.stageHeight*stage.stageHeight)/v;
			
			// draw the observer track
			_obsTrack.graphics.clear();
			_obsTrack.graphics.lineStyle(1, 0xff6060);
			hI = _obsIcon._historyIndex;
			hL = _obsIcon._historyList;
			hLen = hL.length;
			hP = hL[hI];
			_obsTrack.graphics.moveTo(hP.x, hP.y);		
			for (i=1; i<hLen; i++) {
				hP = hL[(hI-i+hLen)%hLen];
				if (hP.time<pastLimit) break;
				_obsTrack.graphics.lineTo(hP.x, hP.y);
			}
			
			// draw the source track
			_srcTrack.graphics.clear();
			_srcTrack.graphics.lineStyle(1, 0x6060ff);
			hI = _srcIcon._historyIndex;
			hL = _srcIcon._historyList;
			hLen = hL.length;
			hP = hL[hI];
			_srcTrack.graphics.moveTo(hP.x, hP.y);			
			for (i=1; i<hLen; i++) {
				hP = hL[(hI-i+hLen)%hLen];
				if (hP.time<pastLimit) break;
				_srcTrack.graphics.lineTo(hP.x, hP.y);
			}
		
			
			
			var x0:Number = _obsIcon.x;
			var y0:Number = _obsIcon.y;

			var q:Number;
			var w:Number = 2*Math.PI/1200;
			
			var phP:HistoryPoint;
			
			var t:Number;
			
			for (i=0; i<hLen; i++) {
				
				// evaluate q at each historical point, going backwards from most recent;
				// when q is positive it means the signal emitted by the source at that time has
				// not yet reached the observer; if it is negative the signal has gone past the 
				// observer; our goal is to find the emission time of the signal just now reaching
				// the observer, ie. q(t) = 0
				
				hP = hL[(hI-i+hLen)%hLen];
				
				q = Math.sqrt((hP.x-x0)*(hP.x-x0) + (hP.y-y0)*(hP.y-y0)) - v*(T-hP.time);
				
				if (q<0) {
					// this means that t is more recent than hP.time
					
					if (i>0) {
						// so t is between the current historical point (hP.time) and the previous historical
						// point (phP.time, which is more recent); we use the bisection method to find q(t) = 0
											
						var left:Number = 0;
						var right:Number = 1;
						
						var midpoint:Number;
						var u:Number;
						var tx:Number;
						var ty:Number;
						var qLeft:Number;
						var qRight:Number;
						var qMidpoint:Number;
						
						u = left;
						t = hP.time + u*(phP.time - hP.time);
						tx = hP.x + u*(phP.x - hP.x);
						ty = hP.y + u*(phP.y - hP.y);
						qLeft = Math.sqrt((tx-x0)*(tx-x0) + (ty-y0)*(ty-y0)) - v*(T-t);
						
						u = right;
						t = hP.time + u*(phP.time - hP.time);
						tx = hP.x + u*(phP.x - hP.x);
						ty = hP.y + u*(phP.y - hP.y);
						qRight = Math.sqrt((tx-x0)*(tx-x0) + (ty-y0)*(ty-y0)) - v*(T-t);
						
						for (i=0; i<50; i++) {
							
							midpoint = (left + right)/2;
							u = midpoint;
							t = hP.time + u*(phP.time - hP.time);
							tx = hP.x + u*(phP.x - hP.x);
							ty = hP.y + u*(phP.y - hP.y);
							qMidpoint = Math.sqrt((tx-x0)*(tx-x0) + (ty-y0)*(ty-y0)) - v*(T-t);
							
							if (qLeft*qMidpoint>0) {
								left = midpoint;
								qLeft = qMidpoint;
							}
							else {
								right = midpoint;
								qRight = qMidpoint;
							}
						}
						
						u = midpoint;
						t = hP.time + u*(phP.time - hP.time);
						//tx = hP.x + u*(phP.x - hP.x);
						//ty = hP.y + u*(phP.y - hP.y);
						//q = Math.sqrt((tx-x0)*(tx-x0) + (ty-y0)*(ty-y0)) - v*(T-t);						
						
						
						trace("q': "+q);
						trace("t: "+t);
						trace("phP.time: "+phP.time);
						trace("hP.time: "+hP.time);
					}
					else {
						
						
						trace("bob smith");
					}
					
					break;
				}
				
				phP = hP;
			}
			
			trace("onEnterFrameFunc: "+(getTimer()-startTimer));
		}
		
		protected function onObsDragged(...ignored):void {
			
			//_obsCount++;
			
			//if (_obsCount%100==0) trace(_obsCount);
			
		}
		
		protected function onSrcDragged(...ignored):void {
			
			
		}
		
	}
	
}

