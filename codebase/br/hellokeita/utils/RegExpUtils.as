/**
 * @author		keita (keita.kun@gmail.com)
 * @svn			http://code.hellokeita.in/public
 * @url			http://labs.hellokeita.com/
 * 
 */

package br.hellokeita.utils{
	
	public class RegExpUtils{
		
		public static function getFileExtension(fileName:String):String{
			var regExp:RegExp = new RegExp("^.+\\.([^.]+)$", "\\1");
			var fileParts:Array = regExp.exec(fileName);
			if(fileParts) return fileParts[fileParts.length - 1];
			return null;
		}
	}
}