
package {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.filters.BlurFilter;
	
	public class SHZDiagramScalebar extends Sprite {
		
		public const barHeight:Number = 5;
		public const barColor:uint = 0xffffff;
		public var minSpacing:Number = 15;
		
		protected var _diagram:SHZDiagram;
		protected var _labelField:TextField;
		protected var _labelField2:TextField;
				
		protected var _barAndLabelHaloSP:Sprite;
		protected var _barAndLabelSP:Sprite;

		public function SHZDiagramScalebar(diagram:SHZDiagram) {
			
			_diagram = diagram;
			
			var tf:TextFormat = new TextFormat("Verdana", 12, barColor, true);
			tf.align = "center";
			
			_barAndLabelHaloSP = new Sprite();
			_barAndLabelSP = new Sprite();
			
			_labelField = new TextField();
			_labelField.width = 105;
			_labelField.height = 0;
			_labelField.autoSize = "center";
			_labelField.embedFonts = true;
			_labelField.defaultTextFormat = tf;
			_labelField.selectable = false;
			_labelField.text = "AU";
			_labelField.x = -_labelField.width/2;
			_labelField.y = -_labelField.height;
			_barAndLabelSP.addChild(_labelField);
			
			tf.color = 0x000000;
			_labelField2 = new TextField();
			_labelField2.width = 105;
			_labelField2.height = 0;
			_labelField2.autoSize = "center";
			_labelField2.embedFonts = true;
			_labelField2.defaultTextFormat = tf;
			_labelField2.selectable = false;
			_labelField2.text = "AU";
			_labelField2.x = -_labelField2.width/2;
			_labelField2.y = -_labelField2.height;
			_barAndLabelHaloSP.addChild(_labelField2);			
			_barAndLabelHaloSP.filters = [new BlurFilter()];
						
			addChild(_barAndLabelHaloSP);
			addChild(_barAndLabelSP);
		}		
		
		public function update():void {
			
			var minX:Number = -_diagram.starX;
			var maxX:Number = _diagram.width - _diagram.starX;
			var minY:Number = -_diagram.height/2;
			var maxY:Number = _diagram.height/2;
			
			var m:Number = minSpacing/_diagram.scale;
			var lg:Number = Math.log(m)/Math.LN10;
			var k:int = Math.ceil(lg);
			
			var spacing:Number, belowSpacing:Number;
			var majorMultiple:uint;
			
			if ((k-lg)>(Math.log(2)/Math.LN10)) {
				// use 5*10^(k-1) as the spacing
				belowSpacing = Math.pow(10, k-1);
				spacing = 5*belowSpacing;
				majorMultiple = 2;
			}
			else {
				// use 10^k as the spacing
				spacing = Math.pow(10, k);
				belowSpacing = 0.5*spacing;
				majorMultiple = 5;
			}
			
			var halfBarWidth:Number = majorMultiple*spacing*_diagram.scale/2;
			
			with (_barAndLabelSP.graphics) {
				clear();
				moveTo(-halfBarWidth, 0);
				beginFill(barColor);
				lineTo(halfBarWidth, 0);
				lineTo(halfBarWidth, barHeight);
				lineTo(-halfBarWidth, barHeight);
				lineTo(-halfBarWidth, 0);
				endFill();				
			}
			
			with (_barAndLabelHaloSP.graphics) {
				clear();
				moveTo(-halfBarWidth, 0);
				beginFill(0x000000);
				lineTo(halfBarWidth, 0);
				lineTo(halfBarWidth, barHeight);
				lineTo(-halfBarWidth, barHeight);
				lineTo(-halfBarWidth, 0);
				endFill();				
			}			
			
			_labelField.text = String(majorMultiple*spacing) + " AU";
			_labelField2.text = String(majorMultiple*spacing) + " AU";			
		}
		
	}
}
