
package {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.MovieClip;

	import flash.net.FileReference;
	import flash.net.FileFilter;
	
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	
	import flash.system.System;
	
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import flash.geom.Rectangle;
	
	import com.degrafa.geometry.*;
	import com.degrafa.geometry.command.*;
	import com.degrafa.paint.*;
	
	public class ZodiacGraphicsConverter extends Sprite {
		
		
		private var _fr:FileReference;
		
		private var _graphic:Shape;
		
		private var _paths:Vector.<Path>;
		
		private var _referenceContainer:Sprite;
		private var _reference:MovieClip;
		
		private var _graphicContainer:Sprite;
		
		
		public function ZodiacGraphicsConverter() {
			
			_referenceContainer = new Sprite();
			_referenceContainer.x = 410;
			_referenceContainer.y = 460;
			_referenceContainer.scaleX = _referenceContainer.scaleY = _referenceScaleFactor;
			addChildAt(_referenceContainer, 0);
			
			_graphicContainer = new Sprite();
			_graphicContainer.x = _referenceContainer.x;
			_graphicContainer.y = _referenceContainer.y;
			addChildAt(_graphicContainer, 1);
			
			_graphic = new Shape();
			_graphicContainer.addChild(_graphic);
			
			_fr = new FileReference();
			_fr.addEventListener(Event.SELECT, onSvgFileSelected);
			_fr.addEventListener(Event.CANCEL, onSvgFileOpenCancelled);
			_fr.addEventListener(Event.COMPLETE, onSvgFileLoadComplete);
			_fr.addEventListener(IOErrorEvent.IO_ERROR, onSvgFileLoadFail);
			
			openSvgFileButton.addEventListener(MouseEvent.CLICK, onOpenSvgFile);
			
			referenceChoiceComboBox.addEventListener(Event.CHANGE, onReferenceSelected);
			
			
			minusTenXPixelsButton.addEventListener(MouseEvent.CLICK, onMinusTenXPixelsButtonPressed);
			minusOneXPixelButton.addEventListener(MouseEvent.CLICK, onMinusOneXPixelButtonPressed);
			plusOneXPixelButton.addEventListener(MouseEvent.CLICK, onPlusOneXPixelButtonPressed);
			plusTenXPixelsButton.addEventListener(MouseEvent.CLICK, onPlusTenXPixelsButtonPressed);
			
			minusTenYPixelsButton.addEventListener(MouseEvent.CLICK, onMinusTenYPixelsButtonPressed);
			minusOneYPixelButton.addEventListener(MouseEvent.CLICK, onMinusOneYPixelButtonPressed);
			plusOneYPixelButton.addEventListener(MouseEvent.CLICK, onPlusOneYPixelButtonPressed);
			plusTenYPixelsButton.addEventListener(MouseEvent.CLICK, onPlusTenYPixelsButtonPressed);
			
			timesPointNineButton.addEventListener(MouseEvent.CLICK, onTimesPointNineButtonPressed);
			timesPointNineNineButton.addEventListener(MouseEvent.CLICK, onTimesPointNineNineButtonPressed);
			timesOnePointOhOneButton.addEventListener(MouseEvent.CLICK, onTimesOnePointOhOneButtonPressed);
			timesOnePointOneButton.addEventListener(MouseEvent.CLICK, onTimesOnePointOneButtonPressed);
			
			rotationSlider.addEventListener(Event.CHANGE, onRotationChanged); 
			
			minusDeltaRotationButton.addEventListener(MouseEvent.CLICK, onMinusDeltaRotationButtonPressed);
			plusDeltaRotationButton.addEventListener(MouseEvent.CLICK, onPlusDeltaRotationButtonPressed);
			
			copyCodeButton.addEventListener(MouseEvent.CLICK, onCopyCodeButtonPressed);
			
			update();
		}
		
		private var _referenceObject:Object;
		
		private function onReferenceSelected(...ignored):void {
			
			copyCodeButton.enabled = false;			
				
			if (referenceChoiceComboBox.selectedItem==null) {
				return;
			}
			
			if (_reference!=null) _referenceContainer.removeChild(_reference);
			_referenceObject = null;
			_reference = null;			
			
			var constName:String = (referenceChoiceComboBox.selectedItem.label as String);
			for each (var constObj:Object in _zodiacGraphics) {
				if (constObj.name==constName) {
					_referenceObject = constObj;
					_reference = new (getDefinitionByName(constName+"Reference") as Class);
					_reference.x = -constObj.centerX;
					_reference.y = -constObj.centerY;
					_referenceContainer.rotation = constObj.rotation*180/Math.PI;
					_referenceContainer.addChild(_reference);
					copyCodeButton.enabled = true;
					break;
				}				
			}
			
			update();
		}
		
		private function onOpenSvgFile(evt:Event):void {
			openSvgFileButton.enabled = false;
			_fr.browse([new FileFilter("SVG", "*.svg")]);			
		}
		
		private function onSvgFileSelected(evt:Event):void {
			reset();
			_fr.load();
		}
		
		private function onSvgFileLoadComplete(evt:Event):void {
			parseSvg(_fr.data.readUTFBytes(_fr.data.length));
			update();
			openSvgFileButton.enabled = true;
		}
		
		private function onSvgFileLoadFail(evt:IOErrorEvent):void {
			openSvgFileButton.enabled = true;
			displayError("could not load file -- io error");
		}
		
		private function onSvgFileOpenCancelled(evt:Event):void {
			openSvgFileButton.enabled = true;
		}
		
		private function reset():void {
			_graphic.graphics.clear();
			errorField.text = "";
			_scale = 1;
			_translationX = 0;
			_translationY = 0;
			_rotation = 0;
			update();			
		}
		
		private function displayError(str:String):void {
			errorField.text = str;			
		}
		
		private function parseSvg(rawSvg:String):void {
			var xml:XML;
			try {
				xml = XML(rawSvg);
			}
			catch (err:Error) {
				displayError("could not parse svg -- invalid xml");
				return;
			}
			
			var ns:Namespace = xml.namespace();
			
//			outputField.text = xml..ns::path.length();
			
			_ops = [];
			var op:Op;
			
			var usingFill:Boolean;
			var path:Path;
			
			for each (var p:XML in xml..ns::path) {
				path = new Path(p.@d);
				path.preDraw();
				
				usingFill = (String(p.@fill)!="none");
				if (usingFill) _ops.push({t: 3, c: parseInt(String(p.@fill.slice(1)), 16)});
				
				if (String(p.@stroke).length==7) _ops.push({t: 5, c: parseInt(String(p.@stroke.slice(1)), 16)});
				else _ops.push({t: 6});
				
				parseCommandStack(path.commandStack);
				
				if (usingFill) _ops.push({t: 4});
			}
			
			renderGraphic();
		}
		
		private function parseCommandStack(cmds:CommandStack):void {			
			var i:int;
			var cmd:CommandStackItem;
			for (i=0; i<cmds.length; i++) {
				cmd = cmds.getItem(i);
				switch (cmd.type) {
					case CommandStackItem.LINE_TO:
						_ops.push({t: 1, x: cmd.x, y: cmd.y});
						break;
					case CommandStackItem.MOVE_TO:
						_ops.push({t: 0, x: cmd.x, y: cmd.y});
						break;
					case CommandStackItem.CURVE_TO:
						_ops.push({t: 2, x: cmd.x1, y: cmd.y1, cx: cmd.cx, cy: cmd.cy});
						break;
					case CommandStackItem.COMMAND_STACK:
						parseCommandStack(cmd.commandStack);
						break;
					default:
						trace("unhandled command type: "+cmd.type);
						continue;
				}
			}
		}
				
		private var _ops:Array = [];
		
		private function renderGraphic():void {
			
			var g:Graphics = _graphic.graphics;
			g.clear();
			
			g.lineStyle(1, 0xff0000);
			
			trace("ops length: "+_ops.length);
			
			var startTimer:Number = getTimer();
			
			var op:Object;
			var i:int;
			for (i=0; i<_ops.length; i++) {
				op = _ops[i];
				switch (op.t) {
					case 0:
						// moveTo
						g.moveTo(op.x, op.y);
						break;
					case 1:
						// lineTo
						g.lineTo(op.x, op.y);
						break;
					case 2:
						// curveTo
						g.curveTo(op.cx, op.cy, op.x, op.y);
						break;
					case 3:
						// beginFill
						g.beginFill(op.c, 0.7);
						break;
					case 4:
						// endFill
						g.endFill();
						break;
					case 5:
						// lineStyle
						g.lineStyle(1, op.c, 0.7);
						break;
					case 6:
						// lineStyle()
						g.lineStyle();	
						break;
				}				
			}
			
			trace("renderGraphic: "+(getTimer()-startTimer));
		}
		
		private var _scale:Number = 1;
		private var _translationX:Number = 0;
		private var _translationY:Number = 0;
		private var _rotation:Number = 0;
		
	
		private function onTimesPointNineButtonPressed(...ignored):void {
			_scale *= 1/1.1;
			update();			
		}
		private function onTimesPointNineNineButtonPressed(...ignored):void {
			_scale *= 1/1.01;
			update();			
		}
		private function onTimesOnePointOhOneButtonPressed(...ignored):void {
			_scale *= 1.01;
			update();			
		}
		private function onTimesOnePointOneButtonPressed(...ignored):void {
			_scale *= 1.1;
			update();			
		}
		
		private function onMinusTenXPixelsButtonPressed(...ignored):void {
			_translationX += -10;
			update();			
		}
		private function onMinusOneXPixelButtonPressed(...ignored):void {
			_translationX += -1;
			update();			
		}
		private function onPlusOneXPixelButtonPressed(...ignored):void {
			_translationX += 1;
			update();			
		}
		private function onPlusTenXPixelsButtonPressed(...ignored):void {
			_translationX += 10;
			update();			
		}
		
		private function onMinusTenYPixelsButtonPressed(...ignored):void {
			_translationY += -10;
			update();			
		}
		private function onMinusOneYPixelButtonPressed(...ignored):void {
			_translationY += -1;
			update();			
		}
		private function onPlusOneYPixelButtonPressed(...ignored):void {
			_translationY += 1;
			update();			
		}
		private function onPlusTenYPixelsButtonPressed(...ignored):void {
			_translationY += 10;
			update();			
		}		

		private function onRotationChanged(...ignored):void {
			_rotation = rotationSlider.value;
			update();
		}
		
		private var _deltaRotation:Number = 0.1;
		
		private function onPlusDeltaRotationButtonPressed(...ignored):void {
			_rotation += _deltaRotation;
			update();			
		}
		private function onMinusDeltaRotationButtonPressed(...ignored):void {
			_rotation -= _deltaRotation;
			update();			
		}
		
		
		private var _referenceScaleFactor:Number = 1;
		
		
			
		private function update():void {
			
			rotationSlider.value = (_rotation%360 + 360)%360;
			
			_graphic.x = _translationX;
			_graphic.y = _translationY;
			_graphicContainer.scaleX = _graphicContainer.scaleY = _scale;
			_graphicContainer.rotation = rotationSlider.value;			
		}
		
		
		private var _convertedOps:Array;
		private var _r0:Number, _r1:Number, _r2:Number, _r3:Number;
		
		private function onCopyCodeButtonPressed(...ignored):void {
			
			
			_convertedOps = [];
			
			// scale in radians per px 
			var scale:Number = _scale*_referenceObject.relativeScale*(1/_referenceScaleFactor);
			
			var r:Number = _rotation*Math.PI/180;
			_r0 = _r3 = scale*Math.cos(r);
			_r1 = -scale*Math.sin(r);
			_r2 = -_r1;
			
			var tx:Number, ty:Number;
			var wx:Number, wy:Number;
			
			var ra:Number, dec:Number;
			var l:Number;
			
			var cop:Object;
			var op:Object;
			var i:int;
			for (i=0; i<_ops.length; i++) {
				op = _ops[i];
				cop = {t: op.t};
				
				switch (op.t) {
					case 0:
						// moveTo						
						tx = op.x + _translationX;
						ty = op.y + _translationY;
						wx = _r0*tx + _r1*ty;
						wy = _r2*tx + _r3*ty;
						ra = _referenceObject.ra - wx;
						dec = _referenceObject.dec - wy;
						l = Math.cos(dec);
						cop.x = l*Math.cos(ra);
						cop.y = l*Math.sin(ra);
						cop.z = Math.sin(dec);						
						break;
					case 1:
						// lineTo
						tx = op.x + _translationX;
						ty = op.y + _translationY;
						wx = _r0*tx + _r1*ty;
						wy = _r2*tx + _r3*ty;
						ra = _referenceObject.ra - wx;
						dec = _referenceObject.dec - wy;
						l = Math.cos(dec);
						cop.x = l*Math.cos(ra);
						cop.y = l*Math.sin(ra);
						cop.z = Math.sin(dec);						
						break;
					case 2:
						// curveTo
						tx = op.cx + _translationX;
						ty = op.cy + _translationY;
						wx = _r0*tx + _r1*ty;
						wy = _r2*tx + _r3*ty;
						ra = _referenceObject.ra - wx;
						dec = _referenceObject.dec - wy;
						l = Math.cos(dec);
						cop.cx = l*Math.cos(ra);
						cop.cy = l*Math.sin(ra);
						cop.cz = Math.sin(dec);						
						
						tx = op.x + _translationX;
						ty = op.y + _translationY;
						wx = _r0*tx + _r1*ty;
						wy = _r2*tx + _r3*ty;
						ra = _referenceObject.ra - wx;
						dec = _referenceObject.dec - wy;
						l = Math.cos(dec);
						cop.x = l*Math.cos(ra);
						cop.y = l*Math.sin(ra);
						cop.z = Math.sin(dec);						
						break;
					case 3:
						// beginFill
						cop.c = op.c;
						break;
					case 4:
						// endFill
						break;
					case 5:
						// lineStyle
						cop.c = op.c;
						break;
					case 6:
						// lineStyle()
						break;
				}		
				
				_convertedOps.push(cop);
			}
			
			// this is done after convertedOps has been calculated
			findCenterAndRadius();
			
			var output:String = "{name:\""+_referenceObject.name+"\",ra:"+_centerRa.toFixed(6)+
								",dec:"+_centerDec.toFixed(6)+",r:"+_radius.toFixed(6)+",\n";
			var line:String = "\tops:[";
			
			var prec:int = 4;
			
			for (i=0; i<_convertedOps.length; i++) {
				cop = _convertedOps[i];
				line += "{t:"+cop.t;
				switch (cop.t) {
					case 0:
						line += ",x:"+cop.x.toFixed(prec)+",y:"+cop.y.toFixed(prec)+",z:"+cop.z.toFixed(prec)+"}";
						break;
					case 1:
						// lineTo
						line += ",x:"+cop.x.toFixed(prec)+",y:"+cop.y.toFixed(prec)+",z:"+cop.z.toFixed(prec)+"}";
						break;
					case 2:
						// curveTo
						line += ",cx:"+cop.cx.toFixed(prec)+",cy:"+cop.cy.toFixed(prec)+",cz:"+cop.cz.toFixed(prec)+",x:"+cop.x.toFixed(prec)+",y:"+cop.y.toFixed(prec)+",z:"+cop.z.toFixed(prec)+"}";
						break;
					case 3:
						// beginFill
						line += ",c:0x"+cop.c.toString(16)+"}";
						break;
					case 4:
						// endFill
						line += "}";
						break;
					case 5:
						// lineStyle
						line += ",c:0x"+cop.c.toString(16)+"}";
						break;
					case 6:
						// lineStyle()
						line += "}";
						break;
				}				
				
				if (i<(_convertedOps.length-1)) line += ",";
				else line += "]},";
				
				if (line.length>80) {
					output += line + "\n";
					line = "\t";
				}				
			}
			
			output += line + "\n";
			
			trace("\n\n");
			trace(output);
			trace("");
			
			System.setClipboard(output);			
		}
		
		
		private var _centerRa:Number, _centerDec:Number, _radius:Number;
		
		private function findCenterAndRadius():void {
			var startTimer:Number = getTimer();
			// determine the center and radius by
			// searching for the pairwise most distant points
			
			var tx:Number, ty:Number;
			var wx:Number, wy:Number;
			var ra:Number, dec:Number;
			var l:Number;
			var x0:Number, y0:Number, z0:Number;
			var x1:Number, y1:Number, z1:Number;			
			var cx:Number, cy:Number, cz:Number;
			
			var i:int;
			var j:int;
			var count:int = 0;
			var op:Object;
			var d2:Number = 0;
			var maxD2:Number = 0;
			for (i=0; i<_convertedOps.length; i++) {
				op = _convertedOps[i];
				if (op.t==Op.LINE_TO || op.t==Op.MOVE_TO || op.t==Op.CURVE_TO) {
					x0 = op.x;
					y0 = op.y;
					z0 = op.z;				
				}
				else continue;
				for (j=i+1; j<_convertedOps.length; j++) {
					op = _convertedOps[j];
					if (op.t==Op.LINE_TO || op.t==Op.MOVE_TO || op.t==Op.CURVE_TO) {
						x1 = op.x;
						y1 = op.y;
						z1 = op.z;				
							
						d2 = (x1-x0)*(x1-x0) + (y1-y0)*(y1-y0) + (z1-z0)*(z1-z0);
						
						if (d2>maxD2) {							
							cx = 0.5*(x0+x1);
							cy = 0.5*(y0+y1);
							cz = 0.5*(z0+z1);							
							maxD2 = d2;
						}
						count++;
					}
					else continue;
				}
			}
						
			_radius = 0.5*Math.acos(1-0.5*maxD2);
			_centerRa = Math.atan2(cy, cx);
			_centerDec = Math.asin(cz/(cx*cx + cy*cy + cz*cz));			
			trace("findCenterAndRadius: "+(getTimer()-startTimer));
		}
	
		// ra, dec - the approximate center of constellation, ie. the point where the constellation is attached
		// centerX, centerY - the coordinates in the graphic corresponding to the ra and dec point
		// rotation - the cw rotation (in radians) to apply to the graphic so that the ncp is up
		// relativeScale - the relative scale of the graphic, in radians per px
		private const _zodiacGraphics:Array = [
							{name: "Leo", ra: 2.792527, dec: 0.286234, centerX: 384.4, centerY: 246.8, rotation: -6.161906, relativeScale: 0.0009997},
							{name: "Gemini", ra: 1.829105, dec: 0.397935, centerX: 345.8, centerY: 291.6, rotation: -1.027916, relativeScale: 0.0008589},
							{name: "Sagittarius", ra: 5.026548, dec: -0.537561, centerX: 515.6, centerY: 277.2, rotation: 0.156371, relativeScale: 0.001017},
							{name: "Capricorn", ra: 5.487315, dec: -0.279253, centerX: 389.5, centerY: 277.9, rotation: 0.322258, relativeScale: 0.0005769},
							{name: "Aries", ra: 0.649262, dec: 0.383972, centerX: 313.9, centerY: 306.2, rotation: 0.535498, relativeScale: 0.0008777},
							{name: "Cancer", ra: 2.247984, dec: 0.363028, centerX: 386.7, centerY: 187.8, rotation: -1.514086, relativeScale: 0.0007252},
							{name: "Virgo", ra: 3.525565, dec: -0.027925, centerX: 202.5, centerY: 260.0, rotation: 1.514994, relativeScale: 0.001780},
							{name: "Pisces", ra: 0.195477, dec: 0.167552, centerX: 326.1, centerY: 230.2, rotation: 1.178905, relativeScale: 0.001654},
							{name: "Scorpio", ra: 4.349360, dec: -0.523599, centerX: 348.3, centerY: 269.7, rotation: -0.836808, relativeScale: 0.0007465},
							{name: "Aquarius", ra: 5.815437, dec: -0.118682, centerX: 200.3, centerY: 328.1, rotation: 0.739613, relativeScale: 0.001631},
							{name: "Taurus", ra: 1.144936, dec: 0.265290, centerX: 338.4, centerY: 347.2, rotation: -0.367903, relativeScale: 0.0009337},
							{name: "Libra", ra: 4.000295, dec: -0.307178, centerX: 219.8, centerY: 305.0, rotation: 0.180040, relativeScale: 0.0006109}];
	}
}

internal class Op {
	public static const MOVE_TO:int = 0;
	public static const LINE_TO:int = 1;
	public static const CURVE_TO:int = 2;	
	public var lineColor:uint = 0;
	public var fillColor:uint = 0;
 	public var type:int = 0;
	public var x:Number, y:Number;
	public var cx:Number, cy:Number;	
}
