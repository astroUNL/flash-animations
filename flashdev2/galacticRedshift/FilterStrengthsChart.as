
package {
	
	import flash.display.MovieClip;
	
	
	public class FilterStrengthsChart extends MovieClip {
		
		public function setMagnitudes(mags:Object):void {
			
			var min:Number = 1.0;
			var max:Number = 4.8;
			
			var range:Number = max - min;
			
			uBar.scaleY = (-mags.U - min)/range;
			bBar.scaleY = (-mags.B - min)/range;
			vBar.scaleY = (-mags.V - min)/range;
			rBar.scaleY = (-mags.R - min)/range;
		}
		
	}

}