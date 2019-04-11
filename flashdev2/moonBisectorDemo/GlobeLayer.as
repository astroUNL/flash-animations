
package {
	
	import flash.display.Graphics;
	
	public class GlobeLayer {
		public var fillsList:Array = [];
		public var color:uint = 0xffffff;
		public var alpha:Number = 1.0;
		function GlobeLayer(color:uint=0xffffff, alpha:Number=1.0, fillsList:Array=null) {
			this.color = color;
			this.alpha = alpha;
			if (fillsList!=null) this.fillsList = fillsList;
		}
	}
}
