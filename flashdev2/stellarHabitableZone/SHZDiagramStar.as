
package {
	
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Matrix;
	
	import flash.filters.BlurFilter;
	
	public class SHZDiagramStar extends Sprite {
		
		protected var _diagram:SHZDiagram;

		protected var halo:Shape;
		protected var disc:Shape;
		
		protected var _blur:BlurFilter;
		
		public const AUperSolarRadius:Number = 0.00465;
		public const SolarTemperature:Number = 5808;
		
		
		public var radius:Number = 1;
		public var temperature:Number = 5808.3;
		
		
		
		public function SHZDiagramStar(diagram:SHZDiagram) {			
			_diagram = diagram;
			
			halo = new Shape();
			addChild(halo);
			
			disc = new Shape();
			addChild(disc);
			
			_blur = new BlurFilter(4, 4, 1);
		}
		
		public const MinDiscSize:Number = 1.2;
		
		
		public function update():void {
			
			var starColor:uint = getColorFromTemp(temperature);
			
			var rDisc:Number = radius*AUperSolarRadius*_diagram.scale;
			if (rDisc<MinDiscSize) rDisc = MinDiscSize;
			
			var rDiscLimited:Number = rDisc; // limited by the safe radius (beyond which there's no reason to draw)
			if (rDiscLimited>_diagram.safeRadius) rDiscLimited = _diagram.safeRadius;
			
			var haloMultiplier:Number = 2;
			haloMultiplier = 1.2 + 1.4*(Math.log(temperature)-Math.log(1000))/(Math.log(40000) - Math.log(1000));
			//var extraM:Number = 30*(1 - (Math.log(rDisc) - Math.log(MinDiscSize))/(Math.log(6) - Math.log(MinDiscSize)));
			//if (extraM<1) extraM = 1;
			//haloMultiplier *= extraM;
			
			var rHalo:Number = haloMultiplier*rDisc;
			var rHaloLimited:Number = rHalo;
			
			var whitening:Number = 0.6;
			
			var haloAlpha:Number = 0.3 + 0.2*(Math.log(temperature)-Math.log(1000))/(Math.log(40000) - Math.log(1000));
			if (haloAlpha>0.7) haloAlpha = 0.7;
			
			var colors:Array;
			var alphas:Array;
			var ratios:Array;
			var matrix:Matrix = new Matrix();
			var r:uint, g:uint, b:uint, c:uint;
			
			// draw the halo			
			
			halo.graphics.clear();
			graphics.clear();
			if (rDiscLimited!=_diagram.safeRadius) {
				
				if (rHaloLimited>_diagram.safeRadius) rHaloLimited = _diagram.safeRadius;
				
				matrix.createGradientBox(2*rHalo, 2*rHalo, 0, -rHalo, -rHalo);
				ratios = [0, int(255/haloMultiplier)-1, 255];
				
				// do the light shading
				
				r = (starColor >> 16) & 0xff;
				g = (starColor >> 8) & 0xff;
				b = starColor & 0xff;
				
				r = r + whitening*(255-r);
				g = g + whitening*(255-g);
				b = b + whitening*(255-b);
				
				if (r>255) r = 255;
				if (g>255) g = 255;
				if (b>255) b = 255;
				
				c = (r << 16) | (g << 8) | b;				
	
				colors = [c, c, 0xffffff];
				alphas = [haloAlpha, haloAlpha, 0];
				halo.graphics.beginGradientFill("radial", colors, alphas, ratios, matrix);
				halo.graphics.drawCircle(0, 0, rHaloLimited);
				halo.graphics.endFill();				
			}
			
						
			// now do the disc			
			
			var blurAmount:Number = 2 + 3*(rDiscLimited - 2)/(_diagram.safeRadius-2);
			if (blurAmount>5) blurAmount = 5;
			_blur.blurX = _blur.blurY = blurAmount;
			
			disc.filters = [_blur];
			
			disc.graphics.clear();
			
			// since we apply a blur to the star disc we need to keep its dimensions reasonably small
			// (using just a mask can cause a noticable slowdown when the disc gets large)
			var m:Number = 5; // the excess margin, might be good to make this match the max blur amount
			var xLeft:Number = m + _diagram.starX;
			var xRight:Number = _diagram.width - _diagram.starX + m;
			var y:Number = m + _diagram.height/2;
			var x:Number = Math.sqrt(rDisc*rDisc - y*y);
			
			if (isNaN(x)) {
				// draw the whole disc -- the star's height is within bounds
				
				// draw the color for the star circle
				disc.graphics.beginFill(starColor);
				disc.graphics.drawCircle(0, 0, rDisc);
				disc.graphics.endFill();
				
				colors = [0xffffff, 0xffffff, 0xffffff];
				alphas = [0.95, 0.8, 0.6];
				ratios = [0, 170, 255];
				matrix.createGradientBox(2*rDisc, 2*rDisc, 0, -rDisc, -rDisc);
				
				// draw the white shading for the star circle
				disc.graphics.beginGradientFill("radial", colors, alphas, ratios, matrix);
				disc.graphics.drawCircle(0, 0, rDiscLimited);
				disc.graphics.endFill();
			}
			else {
				// draw only a portion of the disc
				
				var theta:Number = Math.asin(y/rDisc);
				
				
				disc.graphics.beginFill(starColor);
				
				disc.graphics.moveTo(Math.min(x, xRight), y);
				if (x<xRight) drawArc(disc.graphics, 0, 0, rDisc, -theta, theta);
				else disc.graphics.lineTo(xRight, -y);
				disc.graphics.lineTo(Math.max(-x, -xLeft), -y);
				if (-x>-xLeft) drawArc(disc.graphics, 0, 0, rDisc, Math.PI-theta, Math.PI+theta);
				else disc.graphics.lineTo(-xLeft, y);
				disc.graphics.lineTo(Math.min(x, xRight), y);
				
				disc.graphics.endFill();
				
				colors = [0xffffff, 0xffffff, 0xffffff];
				alphas = [0.95, 0.8, 0.6];
				ratios = [0, 170, 255];
				matrix.createGradientBox(2*rDisc, 2*rDisc, 0, -rDisc, -rDisc);
				
				// draw the white shading for the star circle
				disc.graphics.beginGradientFill("radial", colors, alphas, ratios, matrix);
				
				disc.graphics.moveTo(Math.min(x, xRight), y);
				if (x<xRight) drawArc(disc.graphics, 0, 0, rDisc, -theta, theta);
				else disc.graphics.lineTo(xRight, -y);
				disc.graphics.lineTo(Math.max(-x, -xLeft), -y);
				if (-x>-xLeft) drawArc(disc.graphics, 0, 0, rDisc, Math.PI-theta, Math.PI+theta);
				else disc.graphics.lineTo(-xLeft, y);
				disc.graphics.lineTo(Math.min(x, xRight), y);
				
				disc.graphics.endFill();
				
				
			}
		}
		
		protected function drawArc(g:Graphics, x:Number, y:Number, radius:Number, startAngle:Number=0, endAngle:Number=2*Math.PI, skipMoveTo:Boolean=true):void {
			var maxArcStep:Number = 0.5;
			if (startAngle<0) startAngle = startAngle%(2*Math.PI) + (2*Math.PI);
			else startAngle = startAngle%(2*Math.PI);
			if (endAngle<0) endAngle = endAngle%(2*Math.PI) + (2*Math.PI);
			else endAngle = endAngle%(2*Math.PI);
			var range:Number = endAngle - startAngle;
			if (range<0) range = (2*Math.PI)+range;
			var n:int = Math.ceil(range/maxArcStep);
			var step:Number = range/n;
			var half:Number = step/2;
			var cRadius:Number = radius/Math.cos(half);
			var aAngle:Number = startAngle;
			var cAngle:Number = startAngle - half;
			if (!skipMoveTo) g.moveTo(x + radius*Math.cos(startAngle), y - radius*Math.sin(startAngle));
			for (var i:int = 0; i<n; i++) {
				aAngle += step;
				cAngle += step;
				g.curveTo(x + cRadius*Math.cos(cAngle), y - cRadius*Math.sin(cAngle), x + radius*Math.cos(aAngle), y - radius*Math.sin(aAngle));
			}
		}
		
		protected function getColorFromTemp(temp:Number):uint {
			// - this function takes a temperature and returns the associated blackbody color
			// - the polynomial coefficients were derived from the blackbody curve color data
			//   found at http://www.vendian.org/mncharity/dir3/blackbody/
			
			if (temp<1000) temp = 1000;
			else if (temp>40000) temp = 40000;
			
			var logT:Number = Math.log(temp)/Math.LN10;
			var logT2:Number = logT*logT;
			var logT3:Number = logT*logT2;
			
			var r:Number = 22686.34111 - logT*15082.52755 + logT2*3375.333832 - logT3*252.4073853;
			if (r<0) r = 0;
			else if (r>255) r = 255;
			
			var g:Number;
			if (temp<=6500) g = -811.6499145 + logT*36.97365953 + logT2*160.7861677 - logT3*25.57573664;
			else g = 13836.23586 - logT*9069.078214 + logT2*2015.254756 - logT3*149.7766966;
			
			var b:Number = -11545.34298 + logT*8529.658165 - logT2*2150.198586 + logT3*190.0306573;
			if (b<0) b = 0;
			else if (b>255) b = 255;
			
			return (uint(r)<<16 | uint(g)<<8 | uint(b));
		}
		
	}
}
