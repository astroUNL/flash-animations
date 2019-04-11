
package {
	
	import flash.display.MovieClip;
	
	public class SHZDiagramPlanet extends MovieClip {
		
		public var diagram:SHZDiagram;
		
		public function SHZDiagramPlanet(diagram:SHZDiagram) {
			
			this.diagram = diagram;
			
			
			stop();
		}
		
		
		protected var _isDestroyed:Boolean = false;
		protected var _isTidallyLocked:Boolean = false;
		
		
		public function setState(isDestroyed:Boolean, isTidallyLocked:Boolean, temperature:Number):void {
			if (isDestroyed) {
				gotoAndStop("destroyed");				
			}
			else if (isTidallyLocked) {
				gotoAndStop("tidallyLocked");
			}
			else if (temperature<0) {
				gotoAndStop("tooCold");
			}
			else if (temperature>1) {
				gotoAndStop("tooHot");
			}
			else {
				gotoAndStop("justRight");
			}				
		}
		
	}
}
