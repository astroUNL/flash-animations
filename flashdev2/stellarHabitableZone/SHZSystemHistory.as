
package {
	
	import flash.display.Sprite;
	import flash.display.Graphics;
	
	public class SHZSystemHistory extends Sprite {
		
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _barSP:Sprite;
		
		protected var _margin:Number = 2;
		
		
		protected var _planetLockedTag:SHZSystemHistoryTag;
		protected var _planetDestroyedTag:SHZSystemHistoryTag;
		protected var _starDeathTag:SHZSystemHistoryTag;
		protected var _endMainSeqTag:SHZSystemHistoryTag;
		
		protected var _cursorSP:Sprite;
		
		public function SHZSystemHistory(width:Number, height:Number):void {
			
			_width = width;
			_height = height;
			
			
			_planetLockedTag = new SHZSystemHistoryTag("below", "planet becomes\ntidally locked");
			_planetLockedTag.y = _height + _margin;
			addChild(_planetLockedTag);
			
			_planetDestroyedTag = new SHZSystemHistoryTag("below", "planet is\ndestroyed");
			_planetDestroyedTag.y = _height + _margin;
			addChild(_planetDestroyedTag);
			
			_starDeathTag = new SHZSystemHistoryTag("above", "star ist\nkaputt");
			_starDeathTag.y = -_margin;
			addChild(_starDeathTag);
			
			_endMainSeqTag = new SHZSystemHistoryTag("above", "star stops\nfusing H");
			_endMainSeqTag.y = -_margin;
			addChild(_endMainSeqTag);
			
			_barSP = new Sprite();
			addChild(_barSP);
			
			_cursorSP = new Sprite();
			addChild(_cursorSP);
			
			_cursorSP.graphics.clear();
			_cursorSP.graphics.lineStyle(2, 0xe03030, 0.5);
			_cursorSP.graphics.moveTo(0, -1);
			_cursorSP.graphics.lineTo(0, height+1);										 
		}
		
		
		public function setCursorTime(time:Number, timespan:Number):void {
			_cursorSP.x = time*_width/timespan;			
		}
		
		public function update(historyObj:Object):void {
			// the history object is expected to have the following properties
			//   planetDestroyed - time when planet is destroyed by star (may be POSITIVE_INFINITY if this never happens)
			//   planetLocked - time at which planet becomes tidally locked (may be very large)
			//   statesList - a list of objects with start, end, and state properties identifying the planet's habitability
			//                states over the star's timespan (-1 for too cold, 0 for habitable, 1 for too hot); this
			//                list does not take into account the possible destruction of the planet
			//   star - the star object
			
			
			var sL:Array = historyObj.statesList;
			
			var doomsday:Number = historyObj.planetDestroyed;
			
			var i:int;
			
			var xscale:Number = _width/historyObj.star.timespan;
			
			var g:Graphics = _barSP.graphics;
			g.clear();
			
			
			var left:Number, span:Number;
			var destroyedColor:uint = 0xa0a0a0;
			
			
			var colors:Array = [0x9cadeb, 0x6080d0, 0xfad2ac];//0x40a040
			var alphas:Array = [0.3, 0.9, 0.3];
			
		
			for (i=0; i<sL.length; i++) {
				left = xscale*sL[i].start;
				if (sL[i].end>doomsday) {
					// planet is destroyed in this time step, so draw the part up to doomsday, then draw the destroyed part, then break
					span = xscale*doomsday - left;
					g.beginFill(colors[sL[i].state+1], alphas[sL[i].state+1]);
					g.drawRect(left, 0, span, _height);
					g.endFill();
					
					left = xscale*doomsday;
					span = _width - left;
					g.beginFill(destroyedColor);
					g.drawRect(left, 0, span, _height);
					g.endFill();					
					
					break;					
				}
				else {
					span = xscale*sL[i].end - left;
					g.beginFill(colors[sL[i].state+1], alphas[sL[i].state+1]);
					g.drawRect(left, 0, span, _height);
					g.endFill();
				}
			}
			
			
			var eL:Array = historyObj.star.epochsList;
			
			_endMainSeqTag.x = eL[1].time*xscale;
			_starDeathTag.x = eL[eL.length-1].time*xscale;
			
			
			var endState:int = eL[eL.length-1].type;
			
			if (endState>=10 && endState<=12) {
				_starDeathTag.text = "star becomes\nwhite dwarf";
				_starDeathTag.update();
				_starDeathTag.visible = true;
			}
			else if (endState==13) {
				_starDeathTag.text = "star becomes\na neutron star";
				_starDeathTag.update();
				_starDeathTag.visible = true;
			}
			else if (endState==14) {
				_starDeathTag.text = "star becomes\na black hole";
				_starDeathTag.update();
				_starDeathTag.visible = true;
			}
			else if (endState==15) {
				_starDeathTag.text = "star destroyed\nin supernova";
				_starDeathTag.update();
				_starDeathTag.visible = true;
			}
			else {
				trace("WARNING, invalid end state in SHZSystemHistory.update");
				_starDeathTag.visible = false;
			}
			
			
			if (historyObj.planetDestroyed<historyObj.star.timespan) {
				_planetDestroyedTag.x = historyObj.planetDestroyed*xscale;
				_planetDestroyedTag.visible = true;
			}
			else {
				_planetDestroyedTag.visible = false;
			}
			
			if (historyObj.planetLocked<historyObj.star.timespan && historyObj.planetLocked<historyObj.planetDestroyed) {
				_planetLockedTag.x = historyObj.planetLocked*xscale;
				_planetLockedTag.visible = true;
			}
			else {
				_planetLockedTag.visible = false;
			}
			
			
			
			var sep:Number, minSep:Number;
			var maxMinSep:Number = 7;
			
			minSep = Math.min(maxMinSep, _starDeathTag.x - _endMainSeqTag.x);
			sep = (_starDeathTag.x - _endMainSeqTag.x) - ((_endMainSeqTag.width/2) + (_starDeathTag.width/2));
			
			if (sep<minSep) {
				
//				sep = minSep + (_endMainSeqTag.width/2) + (_starDeathTag.width/2);
//				(_endMainSeqTag.width/2) + (_starDeathTag.width/2)
//				
				
				_starDeathTag.offsetText((_starDeathTag.width/(_starDeathTag.width+_endMainSeqTag.width))*(minSep - sep));
				_endMainSeqTag.offsetText(-(_endMainSeqTag.width/(_starDeathTag.width+_endMainSeqTag.width))*(minSep - sep));
				
//				_starDeathTag.offsetText((minSep - sep)/2);
//				_endMainSeqTag.offsetText(-(minSep - sep)/2);
			}
			else {
				_starDeathTag.offsetText(0);
				_endMainSeqTag.offsetText(0);
			}
			
			
			minSep = Math.min(maxMinSep, Math.abs(_planetLockedTag.x - _planetDestroyedTag.x));
			sep = Math.abs(_planetLockedTag.x - _planetDestroyedTag.x) - ((_planetLockedTag.width/2) + (_planetDestroyedTag.width/2));
			
			if (_planetDestroyedTag.visible && _planetLockedTag.visible && sep<minSep) {
				if (_planetLockedTag.x<_planetDestroyedTag.x) {
					
				
					_planetDestroyedTag.offsetText((_planetDestroyedTag.width/(_planetDestroyedTag.width+_planetLockedTag.width))*(minSep - sep));
					_planetLockedTag.offsetText(-(_planetLockedTag.width/(_planetDestroyedTag.width+_planetLockedTag.width))*(minSep - sep));
					
//					_planetDestroyedTag.offsetText((minSep - sep)/2);
//					_planetLockedTag.offsetText(-(minSep - sep)/2);
				}
				else {
					
					_planetDestroyedTag.offsetText(-(_planetDestroyedTag.width/(_planetDestroyedTag.width+_planetLockedTag.width))*(minSep - sep));
					_planetLockedTag.offsetText((_planetLockedTag.width/(_planetDestroyedTag.width+_planetLockedTag.width))*(minSep - sep));
					
//					_planetDestroyedTag.offsetText(-(minSep - sep)/2);
//					_planetLockedTag.offsetText((minSep - sep)/2);
				}
			}
			else {
				_planetDestroyedTag.offsetText(0);
				_planetLockedTag.offsetText(0);
			}
			
			
			
		}
		
		
		
		
	}
		
}
