
package {
	
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	import flash.utils.getTimer;
	
	public class SHZDiagramRefOrbits extends Sprite {
		
		public var lineThickness:Number = 1;
		public var lineColor:uint = 0x909090; //0x8060a0;
		public var lineAlpha:Number = 0.8;
		
		public var highlightLineThickness:Number = 1.5;
		public var highlightLineColor:uint = 0xff60a0;
		public var highlightLineAlpha:Number = 0.8;
		
		protected const _ptsPerOrbit:int = 12;
		
		protected var _diagram:SHZDiagram;
		protected var _labelTextFormat:TextFormat;
		protected var _labelsSP:Sprite;
		protected var _orbitsList:Array;
		
		protected var _labelBaseX:Number;
		protected var _labelBaseY:Number;
		protected var _labelBaseR:Number;
		protected var _labelCurveX:Number;
		protected var _KX1:Number, _KY1:Number, _KX2:Number, _KY2:Number;
		
		public function SHZDiagramRefOrbits(diagram:SHZDiagram, normalColor:uint=0, highlightColor:uint=0, baseOffset:Number=25) {
			
			if (normalColor!=0) lineColor = normalColor;
			if (highlightColor!=0) highlightLineColor = highlightColor;
			
			_diagram = diagram;
			
			_labelTextFormat = new TextFormat("Verdana", 11, lineColor, true);
			_labelTextFormat.align = "center";
			
			_labelsSP = new Sprite();
			addChild(_labelsSP);
			
			_orbitsList = [];
			
			_labelBaseX = 200;
			_labelBaseY = (_diagram.height/2) - baseOffset;
			_labelBaseR = Math.sqrt(_labelBaseX*_labelBaseX + _labelBaseY*_labelBaseY);
			_labelCurveX = _labelBaseX/4;
			_KX1 = 2*_labelCurveX;
			_KX2 = _labelBaseX - 2*_labelCurveX;
			_KY1 = 2*_labelBaseY;
			_KY2 = _labelBaseY - 2*_labelBaseY;
		}
		
		public function setList(list:Array):void {
			_orbitsList = [];
			
			var t:TextField;
			var i:int;
			var orb:Object;
			
			var j:int;
			var step:Number = 2*Math.PI/_ptsPerOrbit;
			var c:Number = 1/Math.cos(step/2);
			
			var a:Number, e:Number, b:Number, o:Number;
		
			var pts:Array;
	
			var cAngle:Number, aAngle:Number;
					
			
			for (i=_labelsSP.numChildren-1; i>=0; i--) _labelsSP.removeChildAt(i);
			
			for (i=0; i<list.length; i++) {
				
				orb = {};
				a = orb.a = list[i].a;
				e = orb.e = list[i].e;
			
				// initialize the orbit points
				b = a*Math.sqrt(1-e*e);
				o = e*a;
				pts = [];
				cAngle = step/2;
				aAngle = step;
				for (j=0; j<_ptsPerOrbit; j++) {							
					pts[j] = {cx: -o+a*c*Math.cos(cAngle), cy: b*c*Math.sin(cAngle), ax: -o+a*Math.cos(aAngle), ay: b*Math.sin(aAngle)};
					cAngle += step;
					aAngle += step;
				}
				orb.pts = pts;
				orb.k = Math.sqrt(1-e*e);
				
				// add the label field, if neccessary
				if (list[i].label is String) {
					t = new TextField();
					t.width = 0;
					t.height = 0;
					t.autoSize = "center";
					t.embedFonts = true;
					t.defaultTextFormat = _labelTextFormat;
					t.selectable = false;
					t.text = list[i].label;
					_labelsSP.addChild(t);
					orb.labelField = t;
				}
				
				_orbitsList.push(orb);
			}
			
			update();
		}
		
		public function get showLabels():Boolean {
			return _labelsSP.visible;
		}
		
		public function set showLabels(arg:Boolean):void {
			_labelsSP.visible = arg;
			update();
		}
		
		
		public var labelMargin:Number = 0;
		
		public var highlightedOrbit:int = -1;

		
		public function update():void {
			
			var i:int, j:int;
			
			var r:Number;
			
			var orb:Object;
						
			var u:Number;
			var z:Number;
			
			var ux:Number;
			var uy:Number;
			
			var ox:Number;
			
			var labelX:Number;
			
			var angle:Number, sinAngle:Number;
			var noIntersection:Boolean;
						
			var s:Number = _diagram.scale;
			
			graphics.clear();
			
			for (i=0; i<_orbitsList.length; i++) {
			
				orb = _orbitsList[i];
				
				r = orb.a*s;
				
				if (r<_diagram.safeRadius) {
					
					if (i==highlightedOrbit) {
						graphics.lineStyle(highlightLineThickness, highlightLineColor, highlightLineAlpha);
						orb.labelField.textColor = highlightLineColor;
					}
					else {
						graphics.lineStyle(lineThickness, lineColor, lineAlpha);
						orb.labelField.textColor = lineColor;
					}
					
					// draw the orbit
					graphics.moveTo(s*orb.pts[_ptsPerOrbit-1].ax, s*orb.pts[_ptsPerOrbit-1].ay);
					for (j=0; j<_ptsPerOrbit; j++) graphics.curveTo(s*orb.pts[j].cx, s*orb.pts[j].cy, s*orb.pts[j].ax, s*orb.pts[j].ay);						
					
					// position the label
					if (orb.labelField!=undefined && _labelsSP.visible) {
						
						// when the orbits are large (in screen dimensions) the labels are placed on a line (the label base);
						// as the orbits get smaller the labels follow a quadratic bezier into the star; the anchor points
						// for the bezier are <0,0> (the star) and <labelBaseX,labelBaseY>, and the control point is <0,labelBaseY>
						
						// note that the orbit size considered is the screen size of the orbit expanded by the label margin
						
						// first see if the orbit intersects the label base line beyond labelBaseX
						// if it does position the label, otherwise set the noIntersection flag to true
						sinAngle = _labelBaseY/((labelMargin + s*orb.a)*orb.k);
						noIntersection = (sinAngle>1 || sinAngle<-1);
						if (!noIntersection) {
							labelX = (labelMargin + s*orb.a)*(-orb.e + Math.cos(Math.asin(sinAngle)));
							noIntersection = (labelX<_labelBaseX);
							if (!noIntersection) {
								orb.labelField.scaleX = orb.labelField.scaleY = 1;
								orb.labelField.x = labelX;
								orb.labelField.y = _labelBaseY;
							}
						}
						
						// if there is no intersection then we must solve for the point on the bezier curve that
						// also intersects the orbit (plus margin); for this we use bisection
						if (noIntersection) {
							
							u = 0.5;
							z = 0.5;
							
							for (j=0; j<12; j++) {
								
								z *= 0.5;
								
								// the sample point on the bezier curve
								ux = u*(_KX1 + u*_KX2);
								uy = u*(_KY1 + u*_KY2);
								
								// determine the angle on the orbit that has this y point
								// (arcsin gives the angle between 0 and 90 degrees, which is what we want)
								sinAngle = uy/((labelMargin + s*orb.a)*orb.k);
								
								if (sinAngle>1) {
									// this means the sample point is beyond the orbit, so we need
									// to sample closer to the star next time
									sinAngle = 1;									
									u -= z;
									continue;
								}
								else if (sinAngle<-1) {
									// I don't think this should happen
									sinAngle = -1;
								}
								
								// now determine the x corresponding to the angle determined above
								ox = (labelMargin + s*orb.a)*(-orb.e + Math.cos(Math.asin(sinAngle)));
								
								// if the orbit x point is greater than the sample x point that means
								// the sample point is inside the orbit
								if (ox>ux) u += z;
								else u -= z;
							}
							
							orb.labelField.scaleX = orb.labelField.scaleY = Math.pow(Math.sqrt(ux*ux + uy*uy)/_labelBaseR, 0.4);
							orb.labelField.x = ux;
							orb.labelField.y = uy;
							
						}
						
						// hack!
						if (orb.labelField.text=="Neptune") orb.labelField.x -= 1.15*orb.labelField.width;
					
						orb.labelField.visible = true;						
					}					
					
				}
				else if (orb.labelField!=undefined && _labelsSP.visible) orb.labelField.visible = false;
			}
		}
		
	}
	
}