
package {
	
	public class PositionLog {
		
		protected var _entries:Array;
		
		public function PositionLog() {
			clear();
		}		
		
		public function clear():void {
			_entries = [];
		}
		
		public function expireForward(expTime:Number):uint {
			// removes all entries with times greater than the given time
			var oldLen:int = _entries.length;
			for (var i:int = 0; i<oldLen; i++) {
				if (expTime<=_entries[i].time) {
					_entries.splice(i);
					break;
				}
			}
			return oldLen-_entries.length;			
		}
		
		public function expire(expTime:Number):uint {
			// removes unnecessary entries with times earlier than the given time
			// returns the number of entries removed
			for (var delCount:uint = 0; delCount<_entries.length; delCount++) {
				if (_entries[delCount].time>=expTime) break;				
			}
			if (delCount>0) {
				// we need to keep the last entry before the expiration time so that we know where
				// the object was at the expiration time; also, we want to be sure to leave at least one entry
				delCount--;
				_entries.splice(0, delCount);
			}
			return delCount;		
		}
		
		public function addEntry(pos:Position):void {
			_entries.push(pos);
		}
		
		public function getPosition(time:Number):Position {
			var p:Position = new Position(time);
			
			if (time<=_entries[0].time) {
				p.x = _entries[0].x;
				p.y = _entries[0].y;
			}
			else if (time>=_entries[_entries.length-1].time) {
				p.x = _entries[_entries.length-1].x;
				p.y = _entries[_entries.length-1].y;
			}
			else {
				var i:int = _entries.length - 1;
				var pe:Position;
				var ce:Position;
				ce = _entries[i];
				for (i--; i>=0; i--) {
					pe = ce;
					ce = _entries[i];
					if (ce.time<=time) {
						var u:Number = (time-ce.time)/(pe.time-ce.time);
						p.x = ce.x + u*(pe.x - ce.x);
						p.y = ce.y + u*(pe.y - ce.y);
						break;
					}					
				}
			}
				
			return p;
		}
		
		public function getPositions(posList:Array):void {
			// each position in posList will have its x and y properties set to
			// correspond to the time property
			var p:Position;
			for (var i:int = 0; i<posList.length; i++) {
				p = getPosition(posList[i].time);
				posList[i].x = p.x;
				posList[i].y = p.y;
			}
		}
		
		public function getRawLog():Array {
			// this function is for the benefit of the controller, which needs to efficiently 
			// solve for source positions
			return _entries;
		}
		
		public function toString():String {
			var str:String = "position log, " + _entries.length.toString() + " entries:";
			for (var i:int = 0; i<_entries.length; i++) {
				str += "\n " + i.toString() + ": " + _entries[i].toString();			
			}
			return str;
		}
		
	}	
}

