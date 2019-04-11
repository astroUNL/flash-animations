
package {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class SHZDiagramZone extends Sprite {
		
		protected var _diagram:SHZDiagram;
		
		
		
		public function SHZDiagramZone(diagram:SHZDiagram, name:String, innerRadius:Number, outerRadius:Number) {
			_diagram = diagram;
			this.name = name;
			this.innerRadius = innerRadius;
			this.outerRadius = outerRadius;	
			
			_labelBaseX = 200;
			_labelBaseY = -((_diagram.height/2) - 35);
			_labelBaseR = Math.sqrt(_labelBaseX*_labelBaseX + _labelBaseY*_labelBaseY);
			_labelCurveX = _labelBaseX/4;
			
			_KX1 = 2*_labelCurveX;
			_KX2 = _labelBaseX - 2*_labelCurveX;
			_KY1 = 2*_labelBaseY;
			_KY2 = _labelBaseY - 2*_labelBaseY;
			
			var tf:TextFormat = new TextFormat("Verdana", 10, labelColor, true, false);
			
			labelField = new TextField();
			labelField.width = 0;
			labelField.height = 0;
			labelField.autoSize = "center";
			labelField.embedFonts = true;
			labelField.defaultTextFormat = tf;
			labelField.text = "Habitable Zone";
			labelField.selectable = false;
			
			label = new Sprite();
			
			_labelMaxX = _diagram.width - _diagram.starX - labelField.width - 27;
			label.addChild(labelField);
			
			_arrowMaxThreshold = _diagram.width - _diagram.starX - 7;
			_arrowMinThreshold = 22;
			
			arrow = new SHZDiagramZoneArrow();
			label.addChild(arrow);
		}
		
		public var label:Sprite;
		
		public var arrow:SHZDiagramZoneArrow;
		public var labelField:TextField;
		
		public var innerRadius:Number = 1;
		public var outerRadius:Number = 1.1;
		
		public var labelColor:uint = 0x6080d0;
		
		public var fillColor:uint = 0x6080d0;
		public var fillAlpha:Number = 0.5;
		
		public var lineThickness:Number = 0;
		public var lineColor:uint = 0x6080d0;
		public var lineAlpha:Number = 0.75;
		
		protected var _labelBaseR:Number;
		protected var _labelBaseY:Number;
		protected var _labelBaseX:Number;		
		protected var _labelCurveX:Number;
		protected var _labelMaxX:Number;
		protected var _KX1:Number, _KX2:Number, _KY1:Number, _KY2:Number;
		
		protected var _arrowMaxThreshold:Number;
		protected var _arrowMinThreshold:Number;
		
		public function update():void {
			
			var r:Number = (innerRadius + (outerRadius - innerRadius)/2)*_diagram.scale;
			
			
			if (r<_labelBaseR) {
				// solve for point on bezier
				
				var i:int;
				var ox:Number, ux:Number, uy:Number, ur:Number;
				
				var u:Number = 0.5;
				var uStep:Number = 0.25;
				
				for (i=0; i<12; i++) {
					ux = u*(_KX1 + u*_KX2);
					uy = u*(_KY1 + u*_KY2);					
					ur = Math.sqrt(ux*ux + uy*uy);
					if (ur>r) u -= uStep;
					else u += uStep;					
					uStep *= 0.5;
				}	
				
				labelField.x = ux - (labelField.width/2);
				labelField.y = uy - (uy - _labelBaseY)/2.3;
				
			}
			else {
				labelField.x = Math.sqrt(r*r - _labelBaseY*_labelBaseY) - (labelField.width/2);
				labelField.y = _labelBaseY;
				
				if (labelField.x>_labelMaxX) {
					labelField.x = _labelMaxX;
				}
				
				
			}
			
			if ((innerRadius*_diagram.scale)>_arrowMaxThreshold) {					
				arrow.x = labelField.x + labelField.width + 5;
				arrow.y = labelField.y + labelField.height/2;
				arrow.rotation = 0;					
				arrow.visible = true;
			}
			else if ((outerRadius*_diagram.scale)<_arrowMinThreshold) {
				arrow.x = labelField.x + labelField.width/2;
				arrow.y = labelField.y + labelField.height - 2;
				arrow.rotation = 180 + (180/Math.PI)*Math.atan2(arrow.y, arrow.x);					
				arrow.visible = true;
			}
			else {
				arrow.visible = false;
			}
			
			
			graphics.clear();
			
			if ((innerRadius*_diagram.scale)>_diagram.safeRadius) return;
			
			with (graphics) {
				clear();
				lineStyle(lineThickness, lineColor, lineAlpha);
				beginFill(fillColor, fillAlpha);
				drawCircle(0, 0, outerRadius*_diagram.scale);
				drawCircle(0, 0, innerRadius*_diagram.scale);
				endFill();
			}
			
		}
		
		
	}
	
}
