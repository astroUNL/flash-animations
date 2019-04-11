
package {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	
	
	public class EarthOrbitPlot extends Sprite {
		
		public const GM:Number = 6.673e-11*5.97e24;
		public const minR:Number = 6.378e6;
		public const maxR:Number = 450e6;
		
		protected var _plotWidth:Number = 600;
		protected var _plotHeight:Number = 400;
		
		protected var _yMargin:Number = 0.05;
		protected var _minP:Number;
		protected var _logMinP:Number;
		protected var _minR:Number;
		protected var _logMinR:Number;		
		protected var _xScale:Number;
		protected var _yScale:Number;
		
		protected var _xIsLog:Boolean = false;
		protected var _yIsLog:Boolean = false;
		
		protected var _curveColor:uint = 0x3299ff;
		protected var _curveThickness:Number = 2;
		
		public function get xIsLog():Boolean {
			return _xIsLog;			
		}
		
		public function get yIsLog():Boolean {
			return _yIsLog;			
		}
		
		public function set xIsLog(arg:Boolean):void {
			_xIsLog = arg;			
			if (_xIsLog) {
				_logMinR = Math.log(minR);
				_xScale = _plotWidth/(Math.log(maxR) - _logMinR);
			}
			else {
				_xScale = _plotWidth/(maxR - minR);				
			}
		}
		
		public function set yIsLog(arg:Boolean):void {
			_yIsLog = arg;
			var maxCurveP:Number = 2*Math.PI*Math.sqrt(maxR*maxR*maxR/GM);
			var minCurveP:Number = 2*Math.PI*Math.sqrt(minR*minR*minR/GM);
			var range:Number;
			if (_yIsLog) {
				range = (Math.log(maxCurveP) - Math.log(minCurveP))/(1 - 2*_yMargin);
				_logMinP = Math.log(minCurveP) - range*_yMargin;
				var logMaxP:Number = Math.log(maxCurveP) + range*_yMargin;
				_yScale = -_plotHeight/(logMaxP - _logMinP);
			}
			else {
				range = (maxCurveP - minCurveP)/(1 - 2*_yMargin);
				_minP = minCurveP - range*_yMargin;
				if (_minP<0) _minP = 0;
				var maxP:Number = maxCurveP + range*_yMargin;
				_yScale = -_plotHeight/(maxP - _minP);
			}
		}
		
		public function update():void {
			
			_curveSP.graphics.clear();
			_curveSP.graphics.lineStyle(_curveThickness, _curveColor, 1);
			
			var x:int;
			var y:Number;
			var P:Number;
			var R:Number;
			var logR:Number;
			
			x = 0;
			R = _xIsLog ? Math.exp(_logMinR + (x/_xScale)) : minR + x/_xScale;			
			P = 2*Math.PI*Math.sqrt(R*R*R/GM);
			y = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);			
			_curveSP.graphics.moveTo(x, y);
			
			for (x=1; x<=_plotWidth; x++) {
				R = _xIsLog ? Math.exp(_logMinR + (x/_xScale)) : minR + x/_xScale;			
				P = 2*Math.PI*Math.sqrt(R*R*R/GM);
				y = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);
				_curveSP.graphics.lineTo(x, y);
			}
			
			var i:int;
			
			_curveSP.graphics.lineStyle();
			_curveSP.graphics.beginFill(0xff0000);
			
			for (i=0; i<_specialPointsList.length; i++) {
				R = _specialPointsList[i].R;
				x = _xIsLog ? _xScale*(Math.log(R) - _logMinR) : _xScale*(R - minR);
				P = _specialPointsList[i].P;
				y = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);			
				
				_specialPointsList[i].obj.x = x;
				_specialPointsList[i].obj.y = y;
				
				_curveSP.graphics.drawCircle(x, y, 3);
			}
			
			for (i=0; i<_yTickmarksList.length; i++) {
				P = _yTickmarksList[i].P;
				y = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);
				_yTickmarksList[i].tickmark.y = y;
			}
			
			for (i=0; i<_xTickmarksList.length; i++) {
				R = _xTickmarksList[i].R;
				x = _xIsLog ? _xScale*(Math.log(R) - _logMinR) : _xScale*(R - minR);
				_xTickmarksList[i].tickmark.x = x;
			}
		}
		
		protected var _tickmarksSP:Sprite;
		protected var _curveSP:Sprite;
		protected var _readout:Readout;
		protected var _specialPointsSP:Sprite;
		
		protected var _readoutEaser:CubicEaser;
		protected var _timer:Timer;
		
		public function EarthOrbitPlot() {
			
			_readoutEaser = new CubicEaser(0);
			
			xIsLog = true;
			yIsLog = false;
			
			_tickmarksSP = new Sprite();
			addChild(_tickmarksSP);
			
			_curveSP = new Sprite();
			addChild(_curveSP);
			
			_readout = new Readout();
			_readout.alpha = 0;
			addChild(_readout);
			
			_specialPointsSP = new Sprite();
			addChild(_specialPointsSP);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			_timer = new Timer(30);
			_timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			_timer.start();
			
			addXTickmark(6378e3);
			addXTickmark(10000e3);
			addXTickmark(20000e3);
			addXTickmark(40000e3);
			addXTickmark(100000e3);
			addXTickmark(200000e3);
			addXTickmark(400000e3);
			
			addYTickmark(7);
			addYTickmark(14);
			addYTickmark(21);
			addYTickmark(28);
			addYTickmark(35);
			
			addSpecialPoint(6378e3, new NewtonsCannon());
			addSpecialPoint(6730e3, new ISS());			
			addSpecialPoint(26600e3, new GPS());
			addSpecialPoint(42164e3, new Geosynch());
			addSpecialPoint(384000e3, new Moon());
			
			update();
		}
		
		protected var _yTickmarksList:Array = [];
		
		public function addYTickmark(P_inDays:Number):void {
			var P = P_inDays*24*60*60;
			var y:Number = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);
			var tickmark:YTickmark = new YTickmark();
			tickmark.labelField.text = P_inDays.toString();
			tickmark.y = y;
			_tickmarksSP.addChild(tickmark);
			_yTickmarksList.push({P: P, tickmark: tickmark});
		}
		
		protected var _xTickmarksList:Array = [];
		
		public function addXTickmark(R:Number):void {
			var x:Number = _xIsLog ? _xScale*(Math.log(R) - _logMinR) : _xScale*(R - minR);
			var tickmark:XTickmark = new XTickmark();
			tickmark.labelField.text = (R/1000).toString();
			tickmark.x = x;
			_tickmarksSP.addChild(tickmark);
			_xTickmarksList.push({R: R, tickmark: tickmark});
		}
		
		protected var _specialPointsList:Array = [];
		
		public function addSpecialPoint(R:Number, obj:MovieClip):void {
			_specialPointsSP.addChild(obj);
			
			var x:Number = _xIsLog ? _xScale*(Math.log(R) - _logMinR) : _xScale*(R - minR);
			var P:Number = 2*Math.PI*Math.sqrt(R*R*R/GM);
			var y:Number = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);			
			
			obj.x = x;
			obj.y = y;
			obj.alpha = 0;
			
			graphics.lineStyle();
			graphics.beginFill(0xff0000);
			graphics.drawCircle(x, y, 3);
			
			if (obj.radiusField!=null) {
				obj.radiusField.text = (parseFloat(R.toPrecision(3))/1000).toString() + " km";
			}
			
			if (obj.periodField!=null) {
				if (P<=10800) {
					obj.periodField.text = (parseFloat((P/60).toPrecision(3))).toString() + " minutes";
				}
				else if (P<=86400) {
					obj.periodField.text = (parseFloat((P/3600).toPrecision(3))).toString() + " hours";
				}
				else {
					obj.periodField.text = (parseFloat((P/86400).toPrecision(3))).toString() + " days";
				}
			}
			
			if (obj.velocityField!=null) {
				var velocity:Number = Math.sqrt(GM/R);
				obj.velocityField.text = (parseFloat(velocity.toPrecision(3))/1000).toString() + " km/s";
			}
			
			_specialPointsList.push({R: R, P: P, obj: obj, easer: new CubicEaser(0)});			
		}
		
		protected function onTimerEvent(evt:TimerEvent):void {
			var timeNow:Number = getTimer();
			_readout.alpha = _readoutEaser.getValue(timeNow);
			for (var i:int = 0; i<_specialPointsList.length; i++) {
				_specialPointsList[i].obj.alpha = _specialPointsList[i].easer.getValue(timeNow);
			}
			evt.updateAfterEvent();
		}
		
		protected function onMouseMove(evt:MouseEvent):void {
			
			var R:Number, x:Number, y:Number, P:Number;
			var dx:Number, dy:Number, d2:Number;
			var minCurveD2:Number = Number.POSITIVE_INFINITY;
			var closestX:Number, closestR:Number, closestY:Number, closestP:Number;
			
			for (x=0; x<=_plotWidth; x++) {
				R = _xIsLog ? Math.exp(_logMinR + (x/_xScale)) : minR + x/_xScale;
				P = 2*Math.PI*Math.sqrt(R*R*R/GM);
				y = _yIsLog ? _yScale*(Math.log(P) - _logMinP) : _yScale*(P - _minP);
				dx = mouseX - x;
				dy = mouseY - y;
				d2 = dx*dx + dy*dy;
				if (d2<minCurveD2) {
					minCurveD2 = d2;
					closestX = x;
					closestY = y;
					closestR = R;
					closestP = P;
				}
			}
			
			var minPointD2:Number = Number.POSITIVE_INFINITY;
			var closestPoint:Sprite;
			
			var i:int;
			var obj:MovieClip;
			for (i=0; i<_specialPointsList.length; i++) {
				obj = _specialPointsList[i].obj;
				dx = closestX - obj.x;
				dy = closestY - obj.y;
				d2 = dx*dx + dy*dy;
				if (d2<minPointD2) {
					minPointD2 = d2;
					closestPoint = obj;
				}				
			}
			
			var timeNow:Number = getTimer();
			var timeThen:Number = timeNow + 200;
			
			if (minCurveD2<10000) {
				if (minPointD2<200) {
					_specialPointsSP.setChildIndex(closestPoint, _specialPointsSP.numChildren-1);
					for (i=0; i<_specialPointsList.length; i++) {
						if (_specialPointsList[i].obj!=closestPoint && _specialPointsList[i].easer.targetValue!=0) {
							_specialPointsList[i].easer.setTarget(timeNow, null, timeThen, 0);							
						}
						else if (_specialPointsList[i].obj==closestPoint && _specialPointsList[i].easer.targetValue!=1) {
							_specialPointsList[i].easer.setTarget(timeNow, null, timeThen, 1);							
						}
					}
					if (_readoutEaser.targetValue!=0) _readoutEaser.setTarget(timeNow, null, timeThen, 0);
				}
				else {
					for (i=0; i<_specialPointsList.length; i++) {
						if (_specialPointsList[i].easer.targetValue!=0) {
							_specialPointsList[i].easer.setTarget(timeNow, null, timeThen, 0);							
						}
					}
					if (_readoutEaser.targetValue!=1) _readoutEaser.setTarget(timeNow, null, timeThen, 1);
					
					_readout.x = closestX;
					_readout.y = closestY;
					_readout.radiusField.text = (parseFloat(closestR.toPrecision(3))/1000).toString() + " km";
					
					if (closestP<=10800) {
						_readout.periodField.text = (parseFloat((closestP/60).toPrecision(3))).toString() + " minutes";
					}
					else if (closestP<=86400) {
						_readout.periodField.text = (parseFloat((closestP/3600).toPrecision(3))).toString() + " hours";
					}
					else {
						_readout.periodField.text = (parseFloat((closestP/86400).toPrecision(3))).toString() + " days";
					}
					
					var velocity:Number = Math.sqrt(GM/closestR);
					
					_readout.velocityField.text = (parseFloat(velocity.toPrecision(3))/1000).toString() + " km/s";
				}
			}
			else {
				for (i=0; i<_specialPointsList.length; i++) {
					if (_specialPointsList[i].easer.targetValue!=0) {
						_specialPointsList[i].easer.setTarget(timeNow, null, timeThen, 0);							
					}
				}
				if (_readoutEaser.targetValue!=0) _readoutEaser.setTarget(timeNow, null, timeThen, 0);
			}
			
			evt.updateAfterEvent();
		}
		
	}
}

