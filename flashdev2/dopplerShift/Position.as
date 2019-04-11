
package {
	public class Position {
		public var time:Number;
		public var x:Number;
		public var y:Number;
		public var value:Number;
		public var intensity:Number;
		public function Position(time:Number=Number.NaN, x:Number=Number.NaN, y:Number=Number.NaN, value:Number=Number.NaN, intensity:Number=Number.NaN) {
			this.time = time;
			this.x = x;
			this.y = y;
			this.value = value;
			this.intensity = intensity;
		}
		public function toString():String {
			return time.toString() + ", " + x.toString() + ", " + y.toString()+", "+value.toString();
		}
	}
}
