
package {

	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import flash.display.Sprite;
	
	/*
	
		This hacked cell renderer serves two purposes: it lets us show individually disabled
		items in the observations list (ie. ones that have already been added to the queue),
		and it lets us show an icon next to the currently displayed item in the queue list.		
	
	*/
	
	public class HackedCellRenderer extends CellRenderer implements ICellRenderer {
		
		var _emptyIcon:Sprite;
		var _displayedIcon:Sprite;
		
		public function HackedCellRenderer() {
			
			// we have to use an 'empty' icon since a bug in LabelButton makes it impossible
			// to remove an icon once attached; also, the 'empty' icon actually has a transparent
			// fill so that it maintains proper spacing (you can't adjust the label placement in
			// the CellRenderer class even though that functionality is in LabelButton)
			
			var r:Number = 4; // icon (bullet) radius
			var m:Number = 2; // icon left margin
			
			_emptyIcon = new Sprite();
			_emptyIcon.graphics.lineStyle();
			_emptyIcon.graphics.beginFill(0xff0000, 0);
			_emptyIcon.graphics.drawCircle(m+r, r, r);
			_emptyIcon.graphics.endFill();
			
			_displayedIcon = new Sprite();
			_displayedIcon.graphics.lineStyle();
			_displayedIcon.graphics.beginFill(0xff3030, 1);
			_displayedIcon.graphics.drawCircle(m+r, r, r);
			_displayedIcon.graphics.endFill();
			
			super();
		}
		
		override protected function draw():void {
			
			// One reason for hacking the cell renderer class is to allow individual items
			// in the data provider to be disabled. This is accomplished by having a property
			// called inUse set to true when we want that item to appear disabled.
			
			enabled = (!_data.inUse); 
			
			// For showing an icon next to the displayed item in the queue list we introduce
			// the displayed property. This property will be undefined for items in the observations
			// list.
			
			if (_data.displayed!=undefined) {
				if (_data.displayed) setStyle("icon", _displayedIcon);
				else setStyle("icon", _emptyIcon);
			}
			
			// Note that the 'enabled' setter and the setStyle function (both in UIComponent) will
			// weed out unneccessary updates by checking to see if the values have really changed.
			// So it's something we don't need to worry about.
			
			super.draw();
		}
		
	}
}
