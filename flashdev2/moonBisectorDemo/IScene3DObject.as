
package {
	import flash.display.DisplayObject;
	public interface IScene3DObject {
		function set worldX(arg:Number):void;
		function get worldX():Number;
		function set worldY(arg:Number):void;
		function get worldY():Number;
		function set worldZ(arg:Number):void;
		function get worldZ():Number;
		function set screenX(arg:Number):void;
		function get screenX():Number;
		function set screenY(arg:Number):void;
		function get screenY():Number;
		function set screenZ(arg:Number):void;
		function get screenZ():Number;
		function get displayObj():DisplayObject;
	}	
}
