/**
 * @author		keita (keita.kun@gmail.com)
 * @svn			http://code.hellokeita.in/public
 * @url			http://labs.hellokeita.com/
 * 
 */

package br.hellokeita.utils{
	
	public dynamic class ColorUtils{
		public function ColorUtils(){
		}
		
		public static function getRGB(rgb){
			var r = rgb >> 16 & 0xff;
			var g = rgb >> 8 & 0xff;
			var b = rgb & 0xff;
			return {r:r, g:g, b:b};
		}
		public static function setRGB(r,g,b){
			var rgb = 0;
			rgb += (r<<16);
			rgb += (g<<8);
			rgb += (b);
			return rgb;
		}
		public static function getARGB(rgb){
			var a = rgb >> 24 & 0xff;
			var r = rgb >> 16 & 0xff;
			var g = rgb >> 8 & 0xff;
			var b = rgb & 0xff;
			return {a:a, r:r, g:g, b:b};
		}
		public static function setARGB(a,r,g,b){
			var argb = 0;
			argb += (a<<24);
			argb += (r<<16);
			argb += (g<<8);
			argb += (b);
			return argb;
		}
		public static function toGrayscale(c){
			var color = getARGB(c);
			var c = 0;
			c += color.r * .3;
			c += color.g * .59;
			c += color.b * .11;
			color.r = color.g = color.b = c;
			return setARGB(color.a, color.r, color.g, color.b);
		}
	}
}