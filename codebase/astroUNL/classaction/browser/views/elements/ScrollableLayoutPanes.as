
package astroUNL.classaction.browser.views.elements {
	
	import flash.display.Sprite;	
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	// ScrollableLayoutPanes
	
	public class ScrollableLayoutPanes extends ScrollablePanes {
		
		protected var _cursorX:Number, _cursorY:Number;
		protected var _column:int;
		protected var _currPane:Sprite;
		
		public function ScrollableLayoutPanes(width:Number=0, height:Number=0, spacing:Number=0, fadeDistance:Number=0, params:Object=null) {
			super(width, height, spacing, fadeDistance);
			setParams(params);
		}
		
		public function setParams(params:Object=null):void {
			if (params!=null) {
				if (params.leftMargin!=undefined) _leftMargin = params.leftMargin;
				if (params.rightMargin!=undefined) _rightMargin = params.rightMargin;
				if (params.topMargin!=undefined) _topMargin = params.topMargin;
				if (params.bottomMargin!=undefined) _bottomMargin = params.bottomMargin;
				if (params.columnSpacing!=undefined) _columnSpacing = params.columnSpacing;
				if (params.numColumns!=undefined) _numColumns = params.numColumns;
				reset();
			}
		}
		
		

		public function getCurrentPane():Sprite {
			return _currPane;
		}
		
		public function reset():void {
			_columnWidth = (_width - _leftMargin - _rightMargin - (_numColumns - 1)*_columnSpacing)/_numColumns;
			_columnBottomY = _height - _bottomMargin;
			clearAllPanes(false);
			startNewPane();
		}
		
		public function getColumnNum():int {
			return _column+1;
		}
		
		public function startNewPane():void {
			_column = 0;
			_cursorX = _leftMargin;
			_cursorY = _topMargin;
			_currPane = new Sprite();
			appendPane(_currPane);
			
			
//			// this puts a red border around the columns
//			var columnHeight:Number = _height - _bottomMargin - _topMargin;
//			with (_currPane.graphics) {
//				lineStyle(1, 0xff0000);
//				for (var i:int = 0; i<_numColumns; i++) {
//					drawRect(_leftMargin + i*(_columnWidth + _columnSpacing), _topMargin, _columnWidth, columnHeight);					
//				}
//			}
			
		}
		
		public function get cursorY():Number {
			return _cursorY;			
		}
		
		public function advanceColumn():void {
			_column++;
			if (_column>=_numColumns) startNewPane();
			else {
				_cursorX = _leftMargin + _column*(_columnWidth + _columnSpacing);
				_cursorY = 0;//_topMargin;
			}
		}
		
		public function addPadding(padding:Number):void {
			_cursorY += padding;
			if (_cursorY>_columnBottomY) advanceColumn();			
		}
		
		public function addContent(obj:DisplayObject, params:Object=null, allowSpillOver:Boolean=true):Boolean {
			// the top and bottom margins refer to the vertical spacing inserted
			// before and after the object (except there is no top margin inserted when
			// the cursor is at the top of the column); the 'leftover' refers to the amount
			// of vertical space in the column that remains after adding the 
			// object (with margins); if this value is less than minLeftOver then the
			// object is moved to the next column; the allowSpillOver option determines whether
			// this function should add the object to the next column if it does not belong in this
			// one; the function returns a boolean indicating whether the object was added
			// the height parameter allows overriding the object's self reported height
			var topMargin:Number = 0;
			var bottomMargin:Number = 0;
			var leftMargin:Number = 0;
			var minLeftOver:Number = 0;
			var columnTopMargin:Number = 0;
			var objHeight:Number = obj.height;
			if (params!=null) {
				topMargin = (params.topMargin!=undefined) ? params.topMargin : 0;
				bottomMargin = (params.bottomMargin!=undefined) ? params.bottomMargin : 0;
				leftMargin = (params.leftMargin!=undefined) ? params.leftMargin : 0;
				minLeftOver = (params.minLeftOver!=undefined) ? params.minLeftOver : 0;
				columnTopMargin = (params.columnTopMargin!=undefined) ? params.columnTopMargin : 0;
				objHeight = (params.height!=undefined) ? params.height : obj.height;
			}
			
			if (_cursorY<=columnTopMargin) {
				_cursorY = columnTopMargin;
				topMargin = 0;
			}
			
			var leftOver:Number = _columnBottomY - (_cursorY + topMargin + objHeight + bottomMargin);
			if (leftOver<minLeftOver) {
				if (allowSpillOver) {
					advanceColumn();
					_cursorY = columnTopMargin;
					topMargin = 0;
				}
				else return false;
			}
				
			obj.x = _cursorX + leftMargin;
			obj.y = _cursorY + topMargin;
			_currPane.addChild(obj);
			
			_cursorY += topMargin + objHeight + bottomMargin;
			if (_cursorY>_columnBottomY) advanceColumn();		
			
			return true;
		}
		
		protected var _leftMargin:Number = 15;
		protected var _rightMargin:Number = 15;
		protected var _topMargin:Number = 15;
		protected var _bottomMargin:Number = 15;
		protected var _columnSpacing:Number = 15;
		protected var _numColumns:Number = 3;
		protected var _columnWidth:Number, _columnBottomY:Number; // derived
		
		public function get columnWidth():Number {
			return _columnWidth;
		}
		
		override protected function redrawMasks():void {
			// this clears all content
			super.redrawMasks();
			reset();
		}
		
	}
}

