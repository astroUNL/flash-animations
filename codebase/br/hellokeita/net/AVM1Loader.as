/**
 * @author		keita (keita.kun@gmail.com)
 * @svn			http://code.hellokeita.in/public
 * @url			http://labs.hellokeita.com/
 * 
 * @inspired by	http://snippets.libspark.org/trac/wiki/yossy/ForcibleLoader
 */

package br.hellokeita.net{
	
	import flash.events.*;
	import flash.errors.EOFError;
	import flash.net.URLStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.display.Loader;
	
	public class AVM1Loader extends EventDispatcher{
		
		private var urlStream:URLStream;
		private var loader:Loader;
		private var timeout = 0;
		public var content;
		public var frameRate;
		public var bytesLoaded = 0;
		public var bytesTotal = 0;
		private var bArray:ByteArray;
		
		public function AVM1Loader(){
			urlStream = new URLStream();
			urlStream.addEventListener(Event.COMPLETE, streamComplete);
			urlStream.addEventListener(ProgressEvent.PROGRESS, streamProgress);
			
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, eventDispatcher);
			urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, eventDispatcher);
			
			loader = new Loader();
			loader.addEventListener(Event.COMPLETE, loaderComplete);
		}
		
		public function load(urlRequest:URLRequest):void{
			timeout = 0;
			urlStream.load(urlRequest);
		}
		public function unload(){
			try{
				loader.unload();
			}catch(e){
				
			}
		}
		
		// EVENTS
		private function streamProgress(ev):void{
			bytesLoaded = ev.bytesLoaded;
			bytesTotal = ev.bytesTotal;
			
			dispatchEvent(ev);
		}
		private function streamComplete(ev):void{
			var bArray:ByteArray = new ByteArray();
			urlStream.readBytes(bArray);
			urlStream.close();
			bArray.endian = Endian.LITTLE_ENDIAN;
			
			if(isCompressed(bArray)) uncompress(bArray);
			
			var version = uint(bArray[3]);
			
			if(version < 9) {
				if(version == 8) {
					flagSWF9Bit(bArray);
				}else if(version <= 7) {
					insertFileAttributesTag(bArray);
				}
				updateVersion(bArray, 9);
			}
			loader.loadBytes(bArray);
			loader.addEventListener(Event.ENTER_FRAME, checkLoader);
		}
		private function checkLoader(ev){
			if(ev.target.content){
				content = ev.target.content;
				loader.dispatchEvent(new Event(Event.COMPLETE));
				loader.removeEventListener(Event.ENTER_FRAME, checkLoader);
			}
			if(timeout > 10){
				loader.removeEventListener(Event.ENTER_FRAME, checkLoader);
			}
			bArray = null;
			timeout++;
		}
		private function loaderComplete(ev){
			dispatchEvent(ev);
		}
		
		private function eventDispatcher(ev):void{
			dispatchEvent(ev);
		}
		
		
		// Private internal use functions
		private function isCompressed(bytes:ByteArray):Boolean{
			return bytes[0] == 0x43;
		}
		private function uncompress(bytes:ByteArray):void{
			var cBytes:ByteArray = new ByteArray();
			cBytes.writeBytes(bytes, 8);
			bytes.length = 8;
			bytes.position = 8;
			cBytes.uncompress();
			bytes.writeBytes(cBytes);
			bytes[0] = 0x46;
			cBytes.length = 0;
			cBytes = null;
		}
		private function flagSWF9Bit(bytes:ByteArray):void{
			var pos = findFileAttributesPosition(getBodyPosition(bytes), bytes);
			if (!isNaN(pos)){
				bytes[pos + 2] |= 0x08;
			}
		}
		
		private function getBodyPosition(bytes:ByteArray):uint{
			var result:uint = 0;
			
			result += 3; // FWS/CWS
			result += 1; // version(byte)
			result += 4; // length(32bit-uint)
			
			var rectNBits:uint = bytes[result] >>> 3;
			result += (5 + rectNBits * 4) / 8; // stage(rect)
			
			result += 2;
			
			frameRate = bytes[result];
			result += 1; // frameRate(byte)
			result += 2; // totalFrames(16bit-uint)
			
			return result;
		}
		
		private function findFileAttributesPosition(offset:uint, bytes:ByteArray):uint{
			bytes.position = offset;
			
			try {
				for (;;) {
					var byte:uint = bytes.readShort();
					var tag:uint = byte >>> 6;
					if (tag == 69) {
						return bytes.position - 2;
					}
					var length:uint = byte & 0x3f;
					if (length == 0x3f) {
						length = bytes.readInt();
					}
					bytes.position += length;
				}
			}catch (e:EOFError) {
			}
			
			return Number.NaN;
		}
		private function insertFileAttributesTag(bytes:ByteArray):void {
			var pos:uint = getBodyPosition(bytes);
			var afterBytes:ByteArray = new ByteArray();
			afterBytes.writeBytes(bytes, pos);
			bytes.length = pos;
			bytes.position = pos;
			bytes.writeByte(0x44);
			bytes.writeByte(0x11);
			bytes.writeByte(0x08);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeByte(0x00);
			bytes.writeBytes(afterBytes);
			afterBytes.length = 0;
		}
		
		private function updateVersion(bytes:ByteArray, version:uint):void{
			bytes[3] = version;
		}
	}
}