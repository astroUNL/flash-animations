package br.hellokeita.transitions{
	
	public class Equations {
		
		private static const easingList:Object = new Object();
		easingList["easenone"] = easeNone;
		easingList["linear"] = easeNone;
		
		easingList["easeinquad"] = easeInQuad;
		easingList["easeoutquad"] = easeOutQuad;
		easingList["easeinoutquad"] = easeInOutQuad;
		easingList["easeoutinquad"] = easeOutInQuad;
		
		easingList["easeincubic"] = easeInCubic;
		easingList["easeoutcubic"] = easeOutCubic;
		easingList["easeinoutcubic"] = easeInOutCubic;
		easingList["easeoutincubic"] = easeOutInCubic;
		
		easingList["easeinquart"] = easeInQuart;
		easingList["easeoutquart"] = easeOutQuart;
		easingList["easeinoutquart"] = easeInOutQuart;
		easingList["easeoutinquart"] = easeOutInQuart;
		
		easingList["easeinquint"] = easeInQuint;
		easingList["easeoutquint"] = easeOutQuint;
		easingList["easeinoutquint"] = easeInOutQuint;
		easingList["easeoutinquint"] = easeOutInQuint;
		
		easingList["easeinsine"] = easeInSine;
		easingList["easeoutsine"] = easeOutSine;
		easingList["easeinoutsine"] = easeInOutSine;
		easingList["easeoutinsine"] = easeOutInSine;
		
		easingList["easeincirc"] = easeInCirc;
		easingList["easeoutcirc"] = easeOutCirc;
		easingList["easeinoutcirc"] = easeInOutCirc;
		easingList["easeoutincirc"] = easeOutInCirc;
		
		easingList["easeinexpo"] = easeInExpo;
		easingList["easeoutexpo"] = easeOutExpo;
		easingList["easeinoutexpo"] = easeInOutExpo;
		easingList["easeoutinexpo"] = easeOutInExpo;
		
		easingList["easeinelastic"] = easeInElastic;
		easingList["easeoutelastic"] = easeOutElastic;
		easingList["easeinoutelastic"] = easeInOutElastic;
		easingList["easeoutinelastic"] = easeOutInElastic;
		
		easingList["easeinback"] = easeInBack;
		easingList["easeoutback"] = easeOutBack;
		easingList["easeinoutback"] = easeInOutBack;
		easingList["easeoutinback"] = easeOutInBack;
		
		easingList["easeinbounce"] = easeInBounce;
		easingList["easeoutbounce"] = easeOutBounce;
		easingList["easeinoutbounce"] = easeInOutBounce;
		easingList["easeoutinbounce"] = easeOutInBounce;

		public static function getPosition(transition:String, t:Number, b:Number, c:Number, d:Number):Number{
			transition = transition.toLowerCase();
			if(!easingList[transition]) transition = "easeinoutexpo";
			return easingList[transition](t, b, c, d);
		}
		public static function equationExists(eqName:String){
			return Boolean(easingList[eqName.toLowerCase()]);
		}
		public static function easeNone (t:Number, b:Number, c:Number, d:Number):Number {
			return c*t/d + b;
		}
		public static function easeInQuad (t:Number, b:Number, c:Number, d:Number):Number {
			return c*(t/=d)*t + b;
		}
		public static function easeOutQuad (t:Number, b:Number, c:Number, d:Number):Number {
			return -c *(t/=d)*(t-2) + b;
		}
		public static function easeInOutQuad (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d/2) < 1) return c/2*t*t + b;
			return -c/2 * ((--t)*(t-2) - 1) + b;
		}
		public static function easeOutInQuad (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutQuad (t*2, b, c/2, d);
			return easeInQuad((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInCubic (t:Number, b:Number, c:Number, d:Number):Number {
			return c*(t/=d)*t*t + b;
		}
		public static function easeOutCubic (t:Number, b:Number, c:Number, d:Number):Number {
			return c*((t=t/d-1)*t*t + 1) + b;
		}
		public static function easeInOutCubic (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d/2) < 1) return c/2*t*t*t + b;
			return c/2*((t-=2)*t*t + 2) + b;
		}
		public static function easeOutInCubic (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutCubic (t*2, b, c/2, d);
			return easeInCubic((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInQuart (t:Number, b:Number, c:Number, d:Number):Number {
			return c*(t/=d)*t*t*t + b;
		}
		public static function easeOutQuart (t:Number, b:Number, c:Number, d:Number):Number {
			return -c * ((t=t/d-1)*t*t*t - 1) + b;
		}
		public static function easeInOutQuart (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
			return -c/2 * ((t-=2)*t*t*t - 2) + b;
		}
		public static function easeOutInQuart (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutQuart (t*2, b, c/2, d);
			return easeInQuart((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInQuint (t:Number, b:Number, c:Number, d:Number):Number {
			return c*(t/=d)*t*t*t*t + b;
		}
		public static function easeOutQuint (t:Number, b:Number, c:Number, d:Number):Number {
			return c*((t=t/d-1)*t*t*t*t + 1) + b;
		}
		public static function easeInOutQuint (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
			return c/2*((t-=2)*t*t*t*t + 2) + b;
		}
		public static function easeOutInQuint (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutQuint (t*2, b, c/2, d);
			return easeInQuint((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInSine (t:Number, b:Number, c:Number, d:Number):Number {
			return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
		}
		public static function easeOutSine (t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sin(t/d * (Math.PI/2)) + b;
		}
		public static function easeInOutSine (t:Number, b:Number, c:Number, d:Number):Number {
			return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
		}
		public static function easeOutInSine (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutSine (t*2, b, c/2, d);
			return easeInSine((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInExpo (t:Number, b:Number, c:Number, d:Number):Number {
			return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b - c * 0.001;
		}
		public static function easeOutExpo (t:Number, b:Number, c:Number, d:Number):Number {
			return (t==d) ? b+c : c * 1.001 * (-Math.pow(2, -10 * t/d) + 1) + b;
		}
		public static function easeInOutExpo (t:Number, b:Number, c:Number, d:Number):Number {
			if (t==0) return b;
			if (t==d) return b+c;
			if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b - c * 0.0005;
			return c/2 * 1.0005 * (-Math.pow(2, -10 * --t) + 2) + b;
		}
		public static function easeOutInExpo (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutExpo (t*2, b, c/2, d);
			return easeInExpo((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInCirc (t:Number, b:Number, c:Number, d:Number):Number {
			return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
		}
		public static function easeOutCirc (t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
		}
		public static function easeInOutCirc (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
			return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
		}
		public static function easeOutInCirc (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutCirc (t*2, b, c/2, d);
			return easeInCirc((t*2)-d, b+c/2, c/2, d);
		}
		public static function easeInElastic (t:Number, b:Number, c:Number, d:Number, a:Number = Number.NaN, p:Number = Number.NaN):Number {
			if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
			var s:Number;
			if (!a || a < Math.abs(c)) { a=c; s=p/4; }
			else s = p/(2*Math.PI) * Math.asin (c/a);
			return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
		}
		public static function easeOutElastic (t:Number, b:Number, c:Number, d:Number, a:Number = Number.NaN, p:Number = Number.NaN):Number {
			if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
			var s:Number;
			if (!a || a < Math.abs(c)) { a=c; s=p/4; }
			else s = p/(2*Math.PI) * Math.asin (c/a);
			return (a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b);
		}
		public static function easeInOutElastic (t:Number, b:Number, c:Number, d:Number, a:Number = Number.NaN, p:Number = Number.NaN):Number {
			if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
			var s:Number;
			if (!a || a < Math.abs(c)) { a=c; s=p/4; }
			else s = p/(2*Math.PI) * Math.asin (c/a);
			if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
			return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
		}
		public static function easeOutInElastic (t:Number, b:Number, c:Number, d:Number, a:Number = Number.NaN, p:Number = Number.NaN):Number {
			if (t < d/2) return easeOutElastic (t*2, b, c/2, d, a, p);
			return easeInElastic((t*2)-d, b+c/2, c/2, d, a, p);
		}
		public static function easeInBack (t:Number, b:Number, c:Number, d:Number, s:Number = Number.NaN):Number {
			if (!s) s = 1.70158;
			return c*(t/=d)*t*((s+1)*t - s) + b;
		}
		public static function easeOutBack (t:Number, b:Number, c:Number, d:Number, s:Number = Number.NaN):Number {
			if (!s) s = 1.70158;
			return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
		}
		public static function easeInOutBack (t:Number, b:Number, c:Number, d:Number, s:Number = Number.NaN):Number {
			if (!s) s = 1.70158;
			if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
			return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
		}
		public static function easeOutInBack (t:Number, b:Number, c:Number, d:Number, s:Number = Number.NaN):Number {
			if (t < d/2) return easeOutBack (t*2, b, c/2, d, s);
			return easeInBack((t*2)-d, b+c/2, c/2, d, s);
		}
		public static function easeInBounce (t:Number, b:Number, c:Number, d:Number):Number {
			return c - easeOutBounce (d-t, 0, c, d) + b;
		}
		public static function easeOutBounce (t:Number, b:Number, c:Number, d:Number):Number {
			if ((t/=d) < (1/2.75)) {
				return c*(7.5625*t*t) + b;
			} else if (t < (2/2.75)) {
				return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
			} else if (t < (2.5/2.75)) {
				return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
			} else {
				return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
			}
		}
		public static function easeInOutBounce (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeInBounce (t*2, 0, c, d) * .5 + b;
			else return easeOutBounce (t*2-d, 0, c, d) * .5 + c*.5 + b;
		}
		public static function easeOutInBounce (t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d/2) return easeOutBounce (t*2, b, c/2, d);
			return easeInBounce((t*2)-d, b+c/2, c/2, d);
		}
	}
}
