/**
 * @author		keita (keita.kun@gmail.com)
 * @svn			http://code.hellokeita.in/public
 * @url			http://labs.hellokeita.com/
 */

package br.hellokeita.anim{
	
	public class TextPattern{
		
		private static var patterns:Array = new Array();
		patterns.push(/<(.*)[^<^\/]*>.{1}<\/\1>/g);
		patterns.push(/<(.*)[^<^\/]*>.*<\/\1>/g);
		patterns.push(/.\n/g);
		patterns.push(/./g);
		
		public function TextPattern(){
			trace("This is a static class, do not instantiate!");
		};
		
		public static function splitText(text:String){
			var tempArray:Array;
			var strArray:Array = new Array();
			strArray.push(text);
			
			var a;
			for(var i = 0; i < patterns.length; i++){
				tempArray = new Array();
				patterns[i].lastIndex = 0;
				for(var j = 0; j < strArray.length; j++){
					var str = strArray[j];
					if(!(str is String)){
						tempArray.push(str);
						continue;
					}
					var index = 0;
					while(a = patterns[i].exec(str)){
						if(a.index > index) tempArray.push(str.substring(index, a.index));
						var match = str.substring(a.index, a.index + a.toString().length);
						if(i == 1 || i == 3){
							var fs = match.substring(0, match.indexOf(">") + 1);
							var fe = match.substring(match.lastIndexOf("<"));
							var split = match.substring(match.indexOf(">") + 1, match.lastIndexOf("<"));
							for(var c = 0; c < split.length; c++){
								tempArray.push({value: fs + split.charAt(c) + fe});
							}
						}else{
							tempArray.push({value: match});
						}
						index = a.index + a.toString().length;
					}
			
					if(index < str.length) tempArray.push(str.substr(index));
				}
				strArray = tempArray;
			}
			
			tempArray = new Array();
			for(var k = 0; k < strArray.length; k++){
				var value = strArray[k];
				if(!(value is String)) value = value.value;
				tempArray.push(value);
			}
			
			strArray = tempArray;
			return strArray;
		}
	}
}