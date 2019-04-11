
package {
	
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class SHZHabitabilityPlot extends MovieClip {
		
		
		public var plotWidth:Number = 100;
		public var plotHeight:Number = 30;
		
		public const coldColor:uint = 0x9cadeb;
		public const hotColor:uint = 0xfad2ac;
		
		public const cursorThickness:Number = 2;
		public const cursorColor:uint = 0xe03030;
		public const cursorAlpha:Number = 0.5;
		
		protected var _backgroundSP:Sprite;
		protected var _curveSP:Sprite;
		protected var _curveMaskSP:Sprite;
		protected var _shadingSP:Sprite;
		protected var _labelsSP:Sprite;
		protected var _coldLabel:TextField;
		protected var _hotLabel:TextField;
		protected var _borderSP:Sprite;
		protected var _destroyedSP:Sprite;
		protected var _cursorSP:Sprite;
		
		public function SHZHabitabilityPlot(w:Number, h:Number) {
						
			_backgroundSP = new Sprite();
			addChild(_backgroundSP);
			
			_curveSP = new Sprite();
			addChild(_curveSP);
			
			_curveMaskSP = new Sprite();
			addChild(_curveMaskSP);
			
			_shadingSP = new Sprite();
			addChild(_shadingSP);

			_labelsSP = new Sprite();
			addChild(_labelsSP);
			
			_destroyedSP = new Sprite();
			addChild(_destroyedSP);
			
			_borderSP = new Sprite();
			addChild(_borderSP);
			
			_cursorSP = new Sprite();
			addChild(_cursorSP);
			
			var tf:TextFormat = new TextFormat("Verdana", 10, 0x000000, false, true);
			
			_curveMaskSP.visible = false;
			_curveSP.mask = _curveMaskSP;
			
			_coldLabel = new TextField();
			tf.color = 0x658ADE;
			_coldLabel.defaultTextFormat = tf;
			_coldLabel.selectable = false;
			_coldLabel.embedFonts = true;
			_coldLabel.width = 0;
			_coldLabel.height = 0;
			_coldLabel.autoSize = "left";
			_coldLabel.text = "too cold";
			
			_hotLabel = new TextField();
			tf.color = 0xF19538;
			_hotLabel.defaultTextFormat = tf;
			_hotLabel.selectable = false;
			_hotLabel.embedFonts = true;
			_hotLabel.width = 0;
			_hotLabel.height = 0;
			_hotLabel.autoSize = "left";
			_hotLabel.text = "too hot";
			
			
			_labelsSP.addChild(_coldLabel);
			_labelsSP.addChild(_hotLabel);
			
			plotWidth = w;
			plotHeight = h;			
			drawStaticContent();
		}
		
		public function setCursorTime(time:Number, timespan:Number):void {
			_cursorSP.x = time*plotWidth/timespan;			
		}
		
		public function plotDataTable(dT:Array, timespan:Number, timeDestroyed:Number):void {
			
			var g:Graphics = _curveSP.graphics;
			
			g.clear();
			g.lineStyle(1, 0x505050);
			
			
			var xScale:Number = plotWidth/timespan;
			var yScale:Number = -(plotHeight - 2*shadingExtent);
			var yOffset:Number = plotHeight - shadingExtent;
						
			var i:int;
			
			var nx:Number;
			var ny:Number;
			var npos:int;
			
			var lx:Number;
			var ly:Number;
			var lpos:int;
			
			lx = xScale*dT[0].time;
			ly = yScale*dT[0].shzTemp + yOffset;
			
			if (ly<0) lpos = 1;
			else if (ly>plotHeight) lpos = -1;
			else lpos = 0;
			
			var topLimit:Number = -10;
			var bottomLimit:Number = plotHeight + 10;
			
			if (ly<topLimit) ly = topLimit;
			else if (ly>bottomLimit) ly = bottomLimit;
			
			if (lpos==0) g.moveTo(lx, ly);
						
			for (i=1; i<dT.length; i++) {
				
				nx = xScale*dT[i].time;
				ny = yScale*dT[i].shzTemp + yOffset;
				
				if (ny<0) npos = 1;
				else if (ny>plotHeight) npos = -1;
				else npos = 0;
				
				if (ny<topLimit) ny = topLimit;
				else if (ny>bottomLimit) ny = bottomLimit;
					
				if (lpos==0) {
					// the last point was in bounds, so we need to draw the segment (no moveTo needed)
					g.lineTo(nx, ny);
				}
				else if (lpos!=npos) {
					// the last point was out of bounds and the current point is either in bounds, or it
					// is out of bounds in the other out of bounds region; either way, we do a moveTo and lineTo
					g.moveTo(lx, ly);
					g.lineTo(nx, ny);
				}
				
				lx = nx;
				ly = ny;
				lpos = npos;				
			}
			
			
			g = _destroyedSP.graphics;
			g.clear();
			
			var xDestroyed:Number = xScale*timeDestroyed;
			if (xDestroyed<plotWidth) {
				g.beginFill(0x000000, 0.15);
				g.drawRect(xDestroyed, 0, plotWidth-xDestroyed, plotHeight);
				g.endFill();
			}
		}
		
		public const shadingExtent:Number = 5;
		
		public function drawStaticContent():void {
			
			var g:Graphics;
			
			
			g = _backgroundSP.graphics;
			g.clear();
			g.beginFill(0xffffff);
			g.drawRect(0, 0, plotWidth, plotHeight);			
			g.endFill();
						
			g = _curveMaskSP.graphics;
			g.clear();
			g.beginFill(0xff0000);
			g.drawRect(0, 0, plotWidth, plotHeight);
			g.endFill();
  			
			g = _shadingSP.graphics;
			g.clear();
			
			
			var fillType:String = "linear";
			var colors:Array = [hotColor, hotColor];
			var alphas:Array = [1.0, 0.2];
			var ratios:Array = [0x00, 0xFF];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(plotWidth, shadingExtent, 90*Math.PI/180, 0, 0);
			
			g.beginGradientFill(fillType, colors, alphas, ratios, matrix);
			g.drawRect(0, 0, plotWidth, shadingExtent);
			g.endFill();
			
			colors = [coldColor, coldColor];
			matrix.createGradientBox(plotWidth, shadingExtent, 270*Math.PI/180, 0, plotHeight-shadingExtent);
			
			g.beginGradientFill(fillType, colors, alphas, ratios, matrix);
			g.drawRect(0, plotHeight-shadingExtent, plotWidth, shadingExtent);
			g.endFill();
			
			
			g = _borderSP.graphics;
			
			g.clear();
			g.lineStyle(1, 0xe0e0e0);
			g.drawRect(0, 0, plotWidth, plotHeight);
			
			
			g = _cursorSP.graphics;
			g.clear();
			g.lineStyle(cursorThickness, cursorColor, cursorAlpha);
			g.moveTo(0, 0);
			g.lineTo(0, plotHeight);
			
			
			_coldLabel.x = plotWidth - _coldLabel.width;
			_coldLabel.y = plotHeight - _coldLabel.height + 3 - shadingExtent;
			
			_hotLabel.x = plotWidth - _hotLabel.width;
			_hotLabel.y = -4 + shadingExtent;
			
		}
		
	}
	
}
