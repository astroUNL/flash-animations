
package {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	public class SHZHRDiagram extends MovieClip {
		
		
		public const diagramWidth:Number = 130;
		public const diagramHeight:Number = 140;
		
		public var backgroundColor:uint = 0xffffff;
		public var borderColor:uint = 0x808080;
		public var borderThickness:Number = 1;
		
		protected var _backgroundSP:Sprite;
		protected var _curveSP:Sprite;
		protected var _maskSP:Sprite;
		protected var _borderSP:Sprite;
		protected var _labelsSP:Sprite;
		
		public function SHZHRDiagram() {
						
			
			_curveSP = new Sprite();
			addChild(_curveSP);
			
			_maskSP = new Sprite();
			addChild(_maskSP);
			
			_borderSP = new Sprite();
			addChild(_borderSP);
			
			_curveSP.mask = _maskSP;
			
			drawBorderAndBackground();
		}
		
		public var minLogTemp:Number = Math.log(2500)/Math.LN10;
		public var maxLogTemp:Number = Math.log(50000)/Math.LN10;
		public var minLogLum:Number = -4;
		public var maxLogLum:Number = 7;
		
		public function update(star:Object, currData:Object):void {
			
			var i:int;
			
			_curveSP.graphics.clear();
			
			var dT:Array = star.dataTable;
			var currTime:Number = currData.time;
			
			var xScale:Number = diagramWidth/(maxLogTemp - minLogTemp);
			var yScale:Number = -diagramHeight/(maxLogLum - minLogLum);
			
			_curveSP.graphics.clear();
			
			
			var logTemp:Number;
			var logLum:Number;
			
			
			
			_curveSP.graphics.lineStyle(1, 0xb8b8b8);
			
			i = 0;
			logTemp = minLogTemp + (maxLogTemp - minLogTemp)*(1 - (i/diagramWidth));
			logLum = getLogLumFromLogTempAndClass(logTemp);
			_curveSP.graphics.lineTo(diagramWidth - xScale*(logTemp - minLogTemp), diagramHeight + yScale*(logLum - minLogLum));
			for (i=1; i<=diagramWidth; i++) {
				logTemp = minLogTemp + (maxLogTemp - minLogTemp)*(1 - (i/diagramWidth));
				logLum = getLogLumFromLogTempAndClass(logTemp);				
				_curveSP.graphics.lineTo(diagramWidth - xScale*(logTemp - minLogTemp), diagramHeight + yScale*(logLum - minLogLum));
			}
			
			
			_curveSP.graphics.lineStyle(1, 0xff9090);			
			_curveSP.graphics.moveTo(diagramWidth - xScale*(dT[0].logTemp-minLogTemp), diagramHeight + yScale*(dT[0].logLum-minLogLum));
			for (i=1; i<dT.length; i++) {
				_curveSP.graphics.lineTo(diagramWidth - xScale*(dT[i].logTemp-minLogTemp), diagramHeight + yScale*(dT[i].logLum-minLogLum));
				if (dT[i].time>=currTime) {
					_curveSP.graphics.lineTo(diagramWidth - xScale*(currData.logTemp-minLogTemp), diagramHeight + yScale*(currData.logLum-minLogLum));
					_curveSP.graphics.moveTo(diagramWidth - xScale*(currData.logTemp-minLogTemp), diagramHeight + yScale*(currData.logLum-minLogLum));
					_curveSP.graphics.lineStyle();
					_curveSP.graphics.beginFill(0xe03030);
					_curveSP.graphics.drawCircle(diagramWidth - xScale*(currData.logTemp-minLogTemp), diagramHeight + yScale*(currData.logLum-minLogLum), 3);
					_curveSP.graphics.endFill();
					break;
				}
			}
			
			
		}
		
		
		
		public function drawBorderAndBackground():void {
			
			_maskSP.graphics.clear();
			_maskSP.graphics.beginFill(0xff0000);
			_maskSP.graphics.drawRect(0, 0, diagramWidth, diagramHeight);
			_maskSP.graphics.endFill();
			
			_borderSP.graphics.clear();
			_borderSP.graphics.lineStyle(borderThickness, borderColor);
			_borderSP.graphics.drawRect(0, 0, diagramWidth, diagramHeight);
		}
		
		
		

		public function getLogLumFromLogTempAndClass(x:Number, lumClass:uint=5):Number {
			// this function from hrDiagramComponent043
			switch (lumClass) {
				case 1:
					if (x<4.1476) return 44.8387+x*(-30.1309+x*(7.59468+x*-0.636977));
					else return -459.5864+x*(334.7205+x*(-80.37116+x*6.432557));
					break;
				case 2:
					if (x<4.0358) return -36.2843+x*(39.6781+x*(-12.54500+x*1.280459));
					else return -37.0612+x*(40.2556+x*(-12.68811+x*1.292279));
					break;
				case 3:
					if (x<3.9092) return -53.8721+x*(59.2071+x*(-19.71611+x*2.108195));
					else return 161.9073+x*(-106.3856+x*(22.64341+x*-1.503738));
					break;
				case 4:
					if (x<4.1372) return -167.2560+x*(125.2710+x*(-31.96691+x*2.804002));
					else return 54.5670+x*(-35.5787+x*(6.91186+x*-0.328444));
					break;
				default:
					if (x<3.5081) return -4686.7070+x*(4157.5332+x*(-1232.05177+x*121.875554));
					else if (x<3.5799) return 22801.9307+x*(-19349.4898+x*(5468.65774+x*-514.806626));
					else if (x<3.7280) return -9950.2659+x*(8097.5483+x*(-2198.40972+x*199.100683));
					else if (x<3.8287) return 10594.1896+x*(-8435.0942+x*(2236.33537+x*-197.427256));
					else if (x<3.9156) return -7990.8168+x*(6127.2576+x*(-1567.12652+x*133.707956));
					else if (x<4.2129) return 277.0365+x*(-207.2491+x*(50.62412+x*-4.009536));
					else if (x<4.6015) return -280.4460+x*(189.7309+x*(-43.60490+x*3.446011));
					else return -9724.5727+x*(6346.9359+x*(-1381.69136+x*100.377185));
			}
		}		
		
	}
	
}

