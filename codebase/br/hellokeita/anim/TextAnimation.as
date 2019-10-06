/**
 * @author		keita (keita.kun@gmail.com)
 * @svn			http://code.hellokeita.in/public
 * @url			http://labs.hellokeita.com/
 */

package br.hellokeita.anim{
    
    import flash.utils.*;
    import flash.text.*;
    
    import br.hellokeita.transitions.Equations;
    
    public class TextAnimation{
        private static var $defaultChars = "";
        init();
        
        private static function init(){
            var i;
            
            for(i = 33; i < 128; i++){
                $defaultChars += String.fromCharCode(i);
            }
        }
        public static function animate(from:String, to:String, param:Object = null){
            var i;
            
            var obj = new Object();
            for(i in param){
                obj[i] = param[i];
            }
            if(!obj.transition) obj.transition = "easeOutExpo";
            if(!obj.delay) obj.delay = 0;
            if(!obj.time) obj.time = 0;
            if(!obj.step) obj.step = 0;
            if(!obj.characters) obj.characters = $defaultChars;
            obj.from = from;
            obj.to = to;
            obj.fromArr = TextPattern.splitText(from);
            obj.toArr = TextPattern.splitText(to);
            obj.length = obj.fromArr.length + obj.toArr.length;
            
            obj.stepArray = new Array();
            
            obj.actual = from;
            obj.p = 0;
            if(obj.textField && (obj.textField is TextField) && !obj.textFormat){
                obj.textFormat = TextFormat(obj.textField.getTextFormat ());
            }
            
            obj.timeout = setTimeout(beginAnimation, obj.delay * 1000, obj);
        }
        private static function beginAnimation(obj){
            obj.startTime = getTimer();
            obj.interval = setInterval(animateObj, 30, obj);
        }
        private static function animateObj(obj){
            var i, l, s;
            
            var time = (getTimer() - obj.startTime ) / 1000;
            var p = Equations.getPosition(obj.transition, time, 0, 1, obj.time);
            if(p < 0) p = 0;
            if(p > 1) p = 1;
            
            p = Math.round(p * obj.length );
            var d = p - obj.fromArr.length;
            
            var t = "";
            for(i = 0; i <= p; i++){
                if(isNaN(obj.stepArray[i])) obj.stepArray[i] = obj.step;
            }
            if(d <= 0){
                l = obj.fromArr.length;
                for(i = 0; i < l; i++){
                    s = obj.stepArray[l - i];
                    if(isNaN(s)){
                        t += obj.fromArr[i];
                    }else if(s > 0){
                        t += randomChar(obj.characters);
                    }else{
                        break;
                    }
                }
            }else if(d > 0){
                l = obj.toArr.length;
                for(i = 0; i < l; i++){
                    s = obj.stepArray[i + obj.fromArr.length + 1];
                    if(isNaN(s)){
                        break;
                    }else if(s > 0){
                        t += randomChar(obj.characters);
                    }else{
                        t += obj.toArr[i];
                    }
                }
            }
            s = 0;
            for(i = 0; i < obj.stepArray.length; i++){
                if(obj.stepArray[i] > 0) obj.stepArray[i]--;
                s += obj.stepArray [i];
            }
            
            if(obj.textField) applyText(obj, t);
            
            if(obj.onUpdate) obj.onUpdate.apply(obj, [obj, t]);
            if(time >= obj.time && s == 0) animationComplete(obj);
        }
        private static function animationComplete(obj){
            clearInterval(obj.interval);
            var t = obj.toArr.join("");

            if(obj.textField) applyText(obj, t);
            if(obj.onComplete) obj.onComplete.apply(obj, [obj, t]);
        }
        private static function applyText(obj, t){
            obj.textField.htmlText = t;
            obj.textField.setTextFormat (obj.textFormat);
        }
        private static function randomChar(char:String){
            return char.charAt(Math.round(Math.random() * (char.length - 1)));
        }
    }
} 