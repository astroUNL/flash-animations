
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	
	public class PopupManager extends Sprite {
				
		var _bounds:Rectangle;
		var _popups:Vector.<PopupWindow>;
		
		public function PopupManager(initBounds:Rectangle=null) {
			_bounds = initBounds;
			_popups = new Vector.<PopupWindow>();
		}
		
		public function addPopup(popup:PopupWindow):void {
			popup.close();
			addChild(popup);
			_popups.push(popup);
			popup.manager = this;
			popup.keepInBounds();
		}
		
		public function hideAllButOne(popupToShow:PopupWindow):void {
			for each (var popup:PopupWindow in _popups) {
				if (popup==popupToShow) popup.open();
				else popup.close();
			}
		}
		
		public function hideAll():void {
			for each (var popup:PopupWindow in _popups) popup.close();
		}
		
		public function get bounds():Rectangle {
			return _bounds;
		}
		
		public function set bounds(b:Rectangle):void {
			_bounds = b;
			for each (var popup:PopupWindow in _popups) popup.keepInBounds(popup.isOpen);
		}
	}
	
}
